import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ReportImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ReportImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) {
      return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
    }

    if (cleanPath.startsWith('data:image/') || cleanPath.length > 1000) {
      try {
        String base64Str = cleanPath;
        final int base64Index = cleanPath.indexOf('base64,');
        if (base64Index != -1) {
          base64Str = cleanPath.substring(base64Index + 7);
        } else if (cleanPath.contains(',')) {
          base64Str = cleanPath.split(',').last;
        }
        
        // Hapus semua spasi dan baris baru
        base64Str = base64Str.replaceAll(RegExp(r'\s+'), '');
        
        // Sesuaikan padding jika diperlukan
        final int remainder = base64Str.length % 4;
        if (remainder > 0) {
          base64Str = base64Str + '=' * (4 - remainder);
        }
        
        final Uint8List bytes = base64.decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
          },
        );
      } catch (_) {
        return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
      }
    }

    if (cleanPath.startsWith('assets/')) {
      return Image.asset(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
        },
      );
    }

    if (cleanPath.startsWith('http')) {
      return Image.network(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
        },
      );
    }

    // Check if local file exists
    try {
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(file, width: width, height: height, fit: fit);
      }
    } catch (_) {}

    return Image.asset('assets/images/logo_ruas.png', width: width, height: height, fit: fit);
  }
}
