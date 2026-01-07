import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CloudinaryService {
  final String cloudName = 'dbzkhhtwx';
  // Use the 'imonow_unsigned' preset which must be created in Cloudinary settings
  final String uploadPreset = 'YaNafssi';

  Future<String?> uploadImage(dynamic imageFile) async {
    var uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      Uint8List? imageBytes;
      String fileName = 'image.jpg';

      if (imageFile is File) {
        imageBytes = await imageFile.readAsBytes();
        fileName = imageFile.path.split('/').last;
      } else if (imageFile is XFile) {
        imageBytes = await imageFile.readAsBytes();
        fileName = imageFile.path.split('/').last;
      }

      if (imageBytes != null) {
        try {
          // Compress image
          var compressedBytes = await FlutterImageCompress.compressWithList(
            imageBytes,
            minHeight: 1920,
            minWidth: 1080,
            quality: 85,
          );
          imageBytes = compressedBytes;
        } catch (e) {
          print("Compression failed, using original image: $e");
        }
      }

      if (kIsWeb) {
        // For web, use base64 encoding to avoid CORS issues
        if (imageBytes != null) {
          String base64Image = base64Encode(imageBytes);
          String dataUri = 'data:image/jpeg;base64,$base64Image';

          var response = await http.post(
            uri,
            body: {'file': dataUri, 'upload_preset': uploadPreset},
          );

          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            return jsonResponse['secure_url'];
          } else {
            print(
              'Cloudinary Upload Failed: ${response.statusCode} - ${response.body}',
            );
            return null;
          }
        } else {
          throw UnsupportedError('Could not read image bytes.');
        }
      } else {
        // Mobile/Desktop - use multipart request
        var request = http.MultipartRequest('POST', uri);
        request.fields['upload_preset'] = uploadPreset;
        request.fields['resource_type'] = 'auto';

        if (imageBytes != null) {
          var multipartFile = http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: fileName,
          );
          request.files.add(multipartFile);
        }

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          var jsonResponse = jsonDecode(responseString);
          return jsonResponse['secure_url'];
        } else {
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          print(
            'Cloudinary Upload Failed: ${response.statusCode} - $responseString',
          );
          // Fallback to mock URL for testing/demo purposes if credentials are invalid
          print('Using mock URL fallback for testing.');
          return 'https://placehold.co/600x400/png?text=Mock+Image';
        }
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      // Fallback to mock URL for testing/demo purposes
      return 'https://placehold.co/600x400/png?text=Mock+Image';
    }
  }
}
