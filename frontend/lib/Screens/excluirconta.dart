import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:farm4you/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExcluirContaScreen extends StatelessWidget {
  final String userId; // Receba o ID do usuário

  const ExcluirContaScreen({Key? key, required this.userId}) : super(key: key);

  Future<void> _marcarComoInativo(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("token do delete: $token");
      final response = await http.delete(
        Uri.parse('https://api.tugabuy.ss-centi.com/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Conta eliminada"),
            content: const Text("Sua conta foi eliminada com sucesso."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o diálogo
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) =>
                        false, // Remove todas as rotas anteriores
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        // Mostrar mensagem específica
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao eliminar a  conta.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Excluir Conta"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Tem certeza que deseja eliminar sua conta?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _marcarComoInativo(context),
                child: const Text(
                  "Eliminar Conta",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
