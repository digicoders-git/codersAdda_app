import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:coders_adda_app/services/api_urls.dart';

class CertificateDownloader {
  static Future<void> downloadAndSave(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return;

    try {
      String resolvedUrl = urlString;
      if (resolvedUrl.contains('localhost')) {
        final uri = Uri.parse(resolvedUrl);
        final baseUri = Uri.parse(ApiUrls.baseUrl);
        resolvedUrl = resolvedUrl.replaceFirst(
            '${uri.scheme}://${uri.host}:${uri.port}', 
            '${baseUri.scheme}://${baseUri.host}:${baseUri.port}');
      }

      // Request permissions
      if (Platform.isAndroid) {
        await [Permission.storage, Permission.photos].request();
      } else if (Platform.isIOS) {
        await Permission.photosAddOnly.request();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloading certificate...")),
        );
      }

      var response = await Dio().get(
        resolvedUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "Certificate_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result != null && result['isSuccess'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Certificate saved to Gallery!")),
          );
        }
      } else {
        throw Exception("Failed to save to gallery");
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Could not save certificate.")),
        );
      }
    }
  }
}
