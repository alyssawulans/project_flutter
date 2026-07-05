import 'package:flutter/material.dart';

class ListSemuaSampah extends StatelessWidget {
  const ListSemuaSampah({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Contoh Dummy Data (Nanti bisa diganti pakai data asli dari API/Database)
    final List<Map<String, String>> dataSampah = [
      {'judul': 'Pembuangan Sampah Plastik', 'status': 'Diproses'},
      {'judul': 'Pembuangan Sampah Organik', 'status': 'Selesai'},
      {'judul': 'Pembuangan Sampah Elektronik', 'status': 'Ditolak'},
      {'judul': 'Pembuangan Sampah Medis', 'status': 'Diproses'},
    ];

    // 2. Gunakan ListView.builder untuk membuat list yang bisa di-scroll
    return ListView.builder(
      padding: const EdgeInsets.all(16.0), // Jarak/padding di sekitar list
      itemCount: dataSampah.length, // Jumlah item yang mau ditampilkan
      itemBuilder: (context, index) {
        final item = dataSampah[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0), // Jarak antar card
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade200), // Garis tepi tipis
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),

              // Kotak Hijau di sebelah kiri (Leading)
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5E53),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.recycling,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              // Tulisan Judul di tengah (Title)
              title: Text(
                item['judul'] ?? 'Pembuangan Sampah',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              // nambahin sub-title di bawah judul kalau perlu
              subtitle: Text(
                'Status: ${item['status']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              // Tanda panah > di sebelah kanan (Trailing)
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),

              // Aksi ketika card diklik
              onTap: () {
                // Navigasi ke halaman detail atau munculin pop-up
                print('Mengklik: ${item['judul']}');
              },
            ),
          ),
        );
      },
    );
  }
}
