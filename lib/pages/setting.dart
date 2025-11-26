import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkTheme = false;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),

      body: ListView(
        children: [
          _switchTile(
            title: "Dark Mode",
            value: darkTheme,
            icon: Icons.dark_mode,
            onChanged: (v) => setState(() => darkTheme = v),
          ),

          _switchTile(
            title: "Notifications",
            value: notifications,
            icon: Icons.notifications,
            onChanged: (v) => setState(() => notifications = v),
          ),

          _menuTile(Icons.language, "Language", "English / Bangla", () {}),

          _menuTile(Icons.lock, "Privacy & Security", "", () {}),

          _menuTile(Icons.info_outline, "App Info", "", () {}),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // TODO: Add your logout logic
            },
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      secondary: Icon(icon),
      onChanged: onChanged,
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
