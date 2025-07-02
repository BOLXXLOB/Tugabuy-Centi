import 'package:flutter/material.dart';
import 'package:farm4you/Screens/excluirconta.dart';

class PrivacySettingsScreen extends StatelessWidget {
  final String userId; // Adicione o ID do usuário

  PrivacySettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações de Privacidade"),
        backgroundColor: Color.fromARGB(255, 86, 130, 191),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 86, 130, 191), Colors.green.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildListItem("Excluir Conta", Icons.delete_forever, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExcluirContaScreen(userId: userId),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String title, IconData icon, Function() onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Color.fromARGB(255, 86, 130, 191)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Color.fromARGB(255, 86, 130, 191)),
        onTap: onTap,
      ),
    );
  }
}
