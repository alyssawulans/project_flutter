import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:project_flutter/config/app_settings.dart';
import 'package:project_flutter/models/aqi_station_model.dart';

class MapsView extends StatefulWidget {
  const MapsView({super.key});

  @override
  State<MapsView> createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  final Color primaryTeal = const Color(0xFF0F4C43);
  final Color activeTeal = const Color(0xFF0D9488);
  final Color textDark = const Color(0xFF0F172A);

  bool _isSyncing = false;
  DateTime _lastUpdated = DateTime.now();
  String _selectedFilter = 'Semua';
  AqiStation? _selectedStation;

  final List<AqiStation> _stations = List.from(AqiStation.defaultStations);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _searchAndFetchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final client = HttpClient();
      
      // 1. Fetch from Nominatim
      final encodedQuery = Uri.encodeComponent(query);
      final nomReq = await client.getUrl(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=1'))
          .timeout(const Duration(seconds: 4));
      nomReq.headers.add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) LatihanFlutterD7/1.0');
      
      final nomRes = await nomReq.close();
      if (nomRes.statusCode == 200) {
        final nomBody = await nomRes.transform(utf8.decoder).join();
        final List decoded = json.decode(nomBody);
        
        if (decoded.isNotEmpty) {
          final firstResult = decoded[0];
          final double lat = double.parse(firstResult['lat']);
          final double lon = double.parse(firstResult['lon']);
          final String name = firstResult['name'] ?? query;
          final String region = firstResult['display_name'] ?? 'Indonesia';

          // 2. Fetch AQI from Open-Meteo
          int fetchedAqi = 50; // fallback
          try {
            final aqiReq = await client.getUrl(Uri.parse(
                'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi'))
                .timeout(const Duration(seconds: 4));
            final aqiRes = await aqiReq.close();
            if (aqiRes.statusCode == 200) {
              final aqiBody = await aqiRes.transform(utf8.decoder).join();
              final aqiDecoded = json.decode(aqiBody);
              if (aqiDecoded['current'] != null && aqiDecoded['current']['us_aqi'] != null) {
                fetchedAqi = (aqiDecoded['current']['us_aqi'] as num).toInt();
              }
            }
          } catch (_) {}

          // 3. Add to map and move
          if (mounted) {
            setState(() {
              final newStation = AqiStation(
                name: name,
                region: region.split(',').last.trim(),
                aqi: fetchedAqi,
                position: LatLng(lat, lon),
                distance: 'Hasil Pencarian',
                temp: 30,
                humidity: 70,
              );
              
              // Prevent duplicates
              _stations.removeWhere((s) => s.name == newStation.name);
              _stations.insert(0, newStation);
              _selectedStation = newStation;
            });
            _mapController.move(LatLng(lat, lon), 13.0);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lokasi ditemukan: $name'),
                backgroundColor: activeTeal,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lokasi tidak ditemukan.'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencari lokasi. Periksa koneksi internet.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _simulateSync() async {
    setState(() {
      _isSyncing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    final random = Random();
    for (var station in _stations) {
      int delta = random.nextInt(31) - 15;
      station.aqi = (station.aqi + delta).clamp(15, 195);
    }

    if (mounted) {
      setState(() {
        _lastUpdated = DateTime.now();
        _isSyncing = false;
        if (_selectedStation != null) {
          _selectedStation = _stations.firstWhere(
            (s) => s.name == _selectedStation!.name,
          );
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Data AQI Nasional Berhasil Diperbarui'),
            ],
          ),
          backgroundColor: activeTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  List<AqiStation> get _filteredStations {
    final query = _searchController.text.toLowerCase();
    return _stations.where((station) {
      final matchesQuery =
          station.name.toLowerCase().contains(query) ||
          station.region.toLowerCase().contains(query);

      bool matchesFilter = true;
      if (_selectedFilter == 'Baik') {
        matchesFilter = station.aqi <= 50;
      } else if (_selectedFilter == 'Sedang') {
        matchesFilter = station.aqi > 50 && station.aqi <= 100;
      } else if (_selectedFilter == 'Tidak Sehat') {
        matchesFilter = station.aqi > 100;
      }

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: AppSettingsController.instance.settingsNotifier,
      builder: (context, settings, _) {
        final isEn = settings.languageCode == 'en';
        final filtered = _filteredStations;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
        final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
        final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final Color textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
        final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final List<Marker> mapMarkers = filtered.map((s) {
      final isSelected =
          _selectedStation != null && _selectedStation!.name == s.name;
      return Marker(
        point: s.position,
        width: 140.0,
        height: 64.0,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedStation = s;
            });
            _mapController.move(s.position, 10.5);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: s.color,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2.0)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: s.color.withValues(alpha: 0.4),
                      blurRadius: isSelected ? 12 : 6,
                      spreadRadius: isSelected ? 3 : 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${s.aqi}',
                        style: TextStyle(
                          color: s.color,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: const Size(8, 4),
                painter: PinPointerPainter(color: s.color),
              ),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: s.color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                'assets/images/logo_ruas.png',
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(activeTeal),
                    ),
                  )
                : Icon(Icons.sync_rounded, color: activeTeal),
            tooltip: 'Sinkronisasi API',
            onPressed: _isSyncing ? null : _simulateSync,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Full Screen Interactive Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-2.5, 118.0), // Center on Indonesia
                initialZoom: 4.8,
                minZoom: 3.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ruas.id',
                ),
                MarkerLayer(markers: mapMarkers),
              ],
            ),
          ),

          // 2. Floating Search Bar & Filters Section (at the top)
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEn ? 'Air Quality Map' : 'Peta Kualitas Udara',
                            style: TextStyle(
                              color: isDark ? activeTeal : primaryTeal,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTime(_lastUpdated),
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) => _searchAndFetchLocation(value),
                          style: TextStyle(
                            fontSize: 13,
                            color: textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: isEn ? 'Search address, city, or province...' : 'Cari alamat, kota, atau provinsi...',
                            hintStyle: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: activeTeal,
                              size: 18,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: subTextColor,
                                      size: 16,
                                    ),
                                    onPressed: () => _searchController.clear(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Horizontal filter tags
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildFilterChip('Semua'),
                            const SizedBox(width: 6),
                            _buildFilterChip('Baik', color: const Color(0xFF10B981)),
                            const SizedBox(width: 6),
                            _buildFilterChip('Sedang', color: const Color(0xFFFBBF24)),
                            const SizedBox(width: 6),
                            _buildFilterChip('Tidak Sehat', color: const Color(0xFFEF4444)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Station Details Card (at the bottom)
          if (_selectedStation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 104,
              child: _buildStationDetailsCard(_selectedStation!),
            ),

          // 4. Draggable Scrollable Sheet (at the bottom when no station is selected)
          if (_selectedStation == null)
            DraggableScrollableSheet(
              initialChildSize: 0.42,
              minChildSize: 0.22,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black12,
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header Section as a Sliver (so it is draggable)
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 12),
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: borderColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 4,
                              ),
                              child: Text(
                                isEn ? 'AQI Monitoring Stations (${filtered.length})' : 'Stasiun Pemantau AQI (${filtered.length})',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      // Empty State or List of Stations as Slivers
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off_rounded,
                                    size: 48,
                                    color: isDark ? Colors.white10 : Colors.grey[300],
                                  ),
                                const SizedBox(height: 12),
                                  Text(
                                    isEn ? 'No stations found' : 'Tidak ada stasiun ditemukan',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 110,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final station = filtered[index];
                                final displayRegion = isEn
                                    ? (station.region == 'Jawa Tengah'
                                        ? 'Central Java'
                                        : (station.region == 'Jawa Barat'
                                            ? 'West Java'
                                            : (station.region == 'Jawa Timur'
                                                ? 'East Java'
                                                : (station.region == 'Sumatera Utara'
                                                    ? 'North Sumatra'
                                                    : station.region))))
                                    : station.region;
                                final displayDistance = isEn
                                    ? (station.distance == 'Wilayah Tengah'
                                        ? 'Central Region'
                                        : (station.distance == 'Wilayah Barat'
                                            ? 'West Region'
                                            : (station.distance == 'Wilayah Timur'
                                                ? 'East Region'
                                                : (station.distance == 'Wilayah Utara'
                                                    ? 'North Region'
                                                    : (station.distance == 'Wilayah Selatan'
                                                        ? 'South Region'
                                                        : station.distance)))))
                                    : station.distance;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: borderColor,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: station.color.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        station.statusIconText,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    title: Text(
                                      station.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$displayRegion • $displayDistance',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: station.color,
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        'AQI ${station.aqi}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedStation = station;
                                      });
                                      _mapController.move(
                                        station.position,
                                        10.5,
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedFilter == label;
    final chipBgColor = isSelected ? (color ?? activeTeal) : (isDark ? const Color(0xFF1E293B) : Colors.white);
    final chipBorderColor = isSelected ? (color ?? activeTeal) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));
    final chipTextColor = isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B));

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: chipBgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: chipBorderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (color ?? activeTeal).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            if (color != null && !isSelected)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            Text(
              AppSettingsController.instance.settingsNotifier.value.languageCode == 'en'
                  ? (label == 'Semua'
                      ? 'All'
                      : (label == 'Baik'
                          ? 'Good'
                          : (label == 'Sedang'
                              ? 'Moderate'
                              : (label == 'Tidak Sehat' ? 'Unhealthy' : label))))
                  : label,
              style: TextStyle(
                color: chipTextColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationDetailsCard(AqiStation station) {
    final lang = AppSettingsController.instance.settingsNotifier.value.languageCode;
    final isEn = lang == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final Color textPrimary = isDark ? const Color(0xFFF8FAFC) : textDark;
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey;

    final pm25 = (station.aqi * 0.35).round();
    final pm10 = (station.aqi * 0.65).round();
    final co = (station.aqi * 0.08).toStringAsFixed(1);
    final so2 = (station.aqi * 0.12).toStringAsFixed(1);
    final o3 = (station.aqi * 0.4).round();

    final bool isUnhealthy = station.aqi > 100;
    final bool isModerate = station.aqi > 50 && station.aqi <= 100;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          station.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5).withOpacity(isDark ? 0.2 : 1.0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE API',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      station.region,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textSecondary),
                onPressed: () {
                  setState(() {
                    _selectedStation = null;
                  });
                },
              ),
            ],
          ),
          Divider(height: 16, color: dividerColor),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: station.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: station.color.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                           children: [
                            const Text(
                              'AQI',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${station.aqi}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${station.status}',
                              style: TextStyle(
                                color: station.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              station.description,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isEn ? 'Particulate Matter (Pollutants)' : 'Kandungan Partikulat (Polutan)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPollutantMeter('PM2.5', '$pm25', pm25 / 150),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPollutantMeter('PM10', '$pm10', pm10 / 150),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPollutantMeter('CO', co, double.parse(co) / 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPollutantMeter('SO2', so2, double.parse(so2) / 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _buildPollutantMeter('O3', '$o3', o3 / 120)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEn ? 'WEATHER' : 'CUACA',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.thermostat_rounded,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '29°C',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    isEn ? 'Health Recommendations' : 'Rekomendasi Kesehatan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRecommendationItem(
                        Icons.masks_rounded,
                        isEn ? 'Mask' : 'Masker',
                        isUnhealthy ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        isUnhealthy
                            ? (isEn ? 'Required' : 'Wajib')
                            : (isEn ? 'Optional' : 'Opsional'),
                      ),
                      _buildRecommendationItem(
                        Icons.sensor_window_rounded,
                        isEn ? 'Close Windows' : 'Tutup Jendela',
                        isUnhealthy ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        isUnhealthy
                            ? (isEn ? 'Yes' : 'Ya')
                            : (isEn ? 'No' : 'Tidak'),
                      ),
                      _buildRecommendationItem(
                        Icons.directions_run_rounded,
                        isEn ? 'Outdoor' : 'Luar Ruangan',
                        isUnhealthy ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        isUnhealthy
                            ? (isEn ? 'Avoid' : 'Hindari')
                            : (isEn ? 'Safe' : 'Aman'),
                      ),
                      _buildRecommendationItem(
                        Icons.air,
                        isEn ? 'Air Purifier' : 'Purifier',
                        isUnhealthy || isModerate
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        isUnhealthy || isModerate
                            ? (isEn ? 'Turn On' : 'Nyalakan')
                            : (isEn ? 'Not Needed' : 'Tidak Perlu'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantMeter(String label, String value, double progressVal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : textDark;
    final clampedProgress = progressVal.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              color: textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 3,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                clampedProgress > 0.7
                    ? const Color(0xFFEF4444)
                    : (clampedProgress > 0.4
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFF10B981)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
    IconData icon,
    String label,
    Color color,
    String action,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

class PinPointerPainter extends CustomPainter {
  final Color color;

  PinPointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

