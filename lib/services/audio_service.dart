import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();

  String? _currentPath;

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    final granted = await requestPermission();

    if (!granted) return null;

    final dir = await getTemporaryDirectory();

    _currentPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a";

    await _recorder.start(
      const RecordConfig(),
      path: _currentPath!,
    );

    return _currentPath;
  }

  Future<String?> stopRecording() async {
    await _recorder.stop();
    return _currentPath;
  }

  Future<void> cancelRecording() async {
    await _recorder.stop();

    if (_currentPath != null) {
      final file = File(_currentPath!);

      if (await file.exists()) {
        await file.delete();
      }
    }

    _currentPath = null;
  }

  Future<bool> isRecording() async {
    return _recorder.isRecording();
  }
}