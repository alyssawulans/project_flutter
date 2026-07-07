import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:project_flutter/config/app_settings.dart';

class AqiStation {
  final String name;
  final String region;
  int aqi;
  final LatLng position;
  final String distance;
  final int temp;
  final int humidity;

  AqiStation({
    required this.name,
    required this.region,
    required this.aqi,
    required this.position,
    required this.distance,
    required this.temp,
    required this.humidity,
  });

  Color get color {
    if (aqi <= 50) return const Color(0xFF10B981); // Baik (Green)
    if (aqi <= 100) return const Color(0xFFFBBF24); // Sedang (Yellow)
    if (aqi <= 150) return const Color(0xFFF97316); // Sangat Sedang (Orange)
    return const Color(0xFFEF4444); // Tidak Sehat (Red)
  }

  String _getLangCode() {
    try {
      return AppSettingsController.instance.settingsNotifier.value.languageCode;
    } catch (_) {
      return 'id';
    }
  }

  String get status {
    final lang = _getLangCode();
    if (lang == 'en') {
      if (aqi <= 50) return 'Good';
      if (aqi <= 100) return 'Moderate';
      if (aqi <= 150) return 'Slightly Unhealthy';
      return 'Unhealthy';
    } else {
      if (aqi <= 50) return 'Baik';
      if (aqi <= 100) return 'Sedang';
      if (aqi <= 150) return 'Sangat Sedang';
      return 'Tidak Sehat';
    }
  }

  String get statusIconText {
    if (aqi <= 50) return '😊';
    if (aqi <= 100) return '😐';
    if (aqi <= 150) return '😷';
    return '🚨';
  }

  String get description {
    final lang = _getLangCode();
    if (lang == 'en') {
      if (aqi <= 50) {
        return 'Air quality is good for outdoor activities.';
      } else if (aqi <= 100) {
        return 'Air quality is moderate, safe for most people.';
      } else if (aqi <= 150) {
        return 'Air quality is unhealthy for sensitive groups.';
      } else {
        return 'Air quality is unhealthy, reduce outdoor activities and use a mask.';
      }
    } else {
      if (aqi <= 50) {
        return 'Kualitas udara baik untuk aktivitas luar ruangan.';
      } else if (aqi <= 100) {
        return 'Kualitas udara sedang, aman bagi sebagian besar orang.';
      } else if (aqi <= 150) {
        return 'Kualitas udara kurang baik bagi kelompok sensitif.';
      } else {
        return 'Kualitas udara buruk, kurangi aktivitas luar ruangan dan gunakan masker.';
      }
    }
  }

  int get pm25 => (aqi * 0.35).round();
  int get pm10 => (aqi * 0.65).round();
  double get co => aqi * 0.08;
  double get so2 => aqi * 0.12;
  double get o3 => aqi * 0.0015; // Realistic O3 value in ppm

  String getRecommendation(String group) {
    final lang = _getLangCode();
    if (lang == 'en') {
      if (aqi <= 50) {
        return 'Safe';
      } else if (aqi <= 100) {
        if (group == 'Sensitif' || group == 'Sensitive') return 'Caution';
        return 'Safe';
      } else if (aqi <= 150) {
        if (group == 'Sensitif' || group == 'Sensitive') return 'Avoid';
        if (group == 'Olahraga' || group == 'Sports') return 'Reduce';
        return 'Caution';
      } else {
        return 'Avoid';
      }
    } else {
      if (aqi <= 50) {
        return 'Aman';
      } else if (aqi <= 100) {
        if (group == 'Sensitif' || group == 'Sensitive') return 'Waspada';
        return 'Aman';
      } else if (aqi <= 150) {
        if (group == 'Sensitif' || group == 'Sensitive') return 'Hindari';
        if (group == 'Olahraga' || group == 'Sports') return 'Kurangi';
        return 'Waspada';
      } else {
        return 'Hindari';
      }
    }
  }

  Color getRecommendationColor(String group) {
    final rec = getRecommendation(group);
    if (rec == 'Aman' || rec == 'Safe') return const Color(0xFF10B981);
    if (rec == 'Waspada' || rec == 'Kurangi' || rec == 'Caution' || rec == 'Reduce') return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  static final List<AqiStation> defaultStations = [
    AqiStation(
      name: 'Semarang',
      region: 'Jawa Tengah',
      aqi: 48,
      position: const LatLng(-6.9667, 110.4167),
      distance: 'Wilayah Tengah',
      temp: 29,
      humidity: 62,
    ),
    AqiStation(
      name: 'Jakarta Pusat',
      region: 'DKI Jakarta',
      aqi: 154,
      position: const LatLng(-6.1818, 106.8223),
      distance: 'Wilayah Barat',
      temp: 32,
      humidity: 78,
    ),
    AqiStation(
      name: 'Jakarta Selatan',
      region: 'DKI Jakarta',
      aqi: 115,
      position: const LatLng(-6.2615, 106.8106),
      distance: 'Wilayah Barat',
      temp: 31,
      humidity: 80,
    ),
    AqiStation(
      name: 'Bandung',
      region: 'Jawa Barat',
      aqi: 84,
      position: const LatLng(-6.9175, 107.6191),
      distance: 'Wilayah Barat',
      temp: 24,
      humidity: 60,
    ),
    AqiStation(
      name: 'Surabaya',
      region: 'Jawa Timur',
      aqi: 128,
      position: const LatLng(-7.2575, 112.7521),
      distance: 'Wilayah Timur',
      temp: 33,
      humidity: 75,
    ),
    AqiStation(
      name: 'Yogyakarta',
      region: 'DI Yogyakarta',
      aqi: 42,
      position: const LatLng(-7.7956, 110.3695),
      distance: 'Wilayah Tengah',
      temp: 27,
      humidity: 68,
    ),
    AqiStation(
      name: 'Medan',
      region: 'Sumatera Utara',
      aqi: 68,
      position: const LatLng(3.5952, 98.6722),
      distance: 'Wilayah Utara',
      temp: 29,
      humidity: 82,
    ),
    AqiStation(
      name: 'Denpasar',
      region: 'Bali',
      aqi: 32,
      position: const LatLng(-8.6705, 115.2126),
      distance: 'Wilayah Selatan',
      temp: 28,
      humidity: 70,
    ),
  ];
}

