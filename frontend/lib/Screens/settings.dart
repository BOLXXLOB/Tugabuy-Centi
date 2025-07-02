import 'package:flutter/material.dart';
import 'package:farm4you/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farm4you/Screens/ChangePasswordScreen.dart';

import 'package:farm4you/Screens/about_screen.dart';
import 'package:farm4you/Screens/privacy_settings_screen.dart';

class ConfigurationsScreen extends StatelessWidget {
  final String utilizadorId;

  const ConfigurationsScreen({Key? key, required this.utilizadorId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Definições',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 49, 188, 243),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, utilizadorId),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingItem(context,
              icon: Icons.lock,
              title: 'Alterar Senha',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordScreen(utilizadorId: utilizadorId)))),
          _buildSettingItem(context,
              icon: Icons.security,
              title: 'Privacidade',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacySettingsScreen(
                            userId: utilizadorId,
                          )))),
          _buildSettingItem(context,
              icon: Icons.info_outline,
              title: 'Sobre',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutScreen()))),
          _buildSettingItem(context,
              icon: Icons.logout,
              title: 'Log Out',
              onTap: () => _logout(context)),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context,
      {required IconData icon,
      required String title,
      required Function() onTap}) {
    return ListTile(
      leading:
          Icon(icon, color: const Color.fromARGB(255, 53, 139, 196), size: 28),
      title: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: const Color.fromARGB(255, 53, 139, 196), size: 20),
      onTap: onTap,
    );
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
