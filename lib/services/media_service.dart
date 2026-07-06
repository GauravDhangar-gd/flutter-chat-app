import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  static const String cloudName = "dykomfntd";
  static const String uploadPreset = "flutter_chat";

  /// Pick image from gallery
  Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (video == null) return null;

    return File(video.path);
  }

  /// Pick image from camera
  Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return null;

    return File(image.path);
  }

  Future<File?> recordVideo() async {
    final XFile? video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 2),
    );

    if (video == null) return null;

    return File(video.path);
  }

  /// Upload Image
  Future<String?> uploadImage(File imageFile) async {
    return uploadMedia(
      imageFile,
      resourceType: "image",
    );
  }

  /// Upload Audio
  Future<String?> uploadAudio(File audioFile) async {
    return uploadMedia(
      audioFile,
      resourceType: "video",
    );
  }

  /// Upload Video (future use)
  Future<String?> uploadVideo(File videoFile) async {
    return uploadMedia(
      videoFile,
      resourceType: "video",
    );
  }

  /// Generic Cloudinary uploader
  Future<String?> uploadMedia(
    File file, {
    required String resourceType,
  }) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
    );

    final request = http.MultipartRequest(
      "POST",
      uri,
    );

    request.fields["upload_preset"] = uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        file.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body =
          await response.stream.bytesToString();

      final jsonData = json.decode(body);

      return jsonData["secure_url"];
    }

    print("Cloudinary Upload Failed");
    print(response.statusCode);

    return null;
  }
}