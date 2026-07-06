import 'package:shared_preferences/shared_preferences.dart';

class WallpaperService {
  static const String wallpaperKey = "chat_wallpaper";

  Future<void> saveWallpaper(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(wallpaperKey, path);
  }

  Future<String?> getWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(wallpaperKey);
  }

  Future<void> removeWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(wallpaperKey);
  }
}