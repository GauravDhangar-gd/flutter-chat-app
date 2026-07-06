import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {

  Widget buildTile(
    String title,
    ThemeMode mode,
    IconData icon,
  ) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: context.watch<ThemeService>().themeMode,
      secondary: Icon(icon),
      title: Text(title),
      onChanged: (value) async {
        if (value == null) return;

        await context.read<ThemeService>().setTheme(value);

        if (mounted) {
          setState(() {});
        }

        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService =
    context.watch<ThemeService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Theme"),
      ),
      body: ListView(
        children: [
          buildTile(
            "Light",
            ThemeMode.light,
            Icons.light_mode,
          ),
          buildTile(
            "Dark",
            ThemeMode.dark,
            Icons.dark_mode,
          ),
          buildTile(
            "System Default",
            ThemeMode.system,
            Icons.phone_android,
          ),
        ],
      ),
    );
  }
}