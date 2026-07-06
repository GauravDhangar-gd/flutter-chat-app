import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class StorageService {
  Future<String> uploadProfileImage(File image) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/dykomfntd/image/upload",
    );

    var request = http.MultipartRequest("POST", uri);

    request.fields["upload_preset"] = "flutter_chat";

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        image.path,
      ),
    );

    final response = await request.send();

    final responseBody =
        await response.stream.bytesToString();

    print("Status Code: ${response.statusCode}");
    print("Response: $responseBody");

    if (response.statusCode == 200) {
      final json = jsonDecode(responseBody);
      return json["secure_url"];
    } else {
      throw Exception(responseBody);
    }
  }
}