import 'dart:convert';
import 'dart:io';
import 'package:farm4you/Services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  final String utilizadorId;

  const ChangePasswordScreen({Key? key, required this.utilizadorId})
      : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;
  ApiService apiService = ApiService();
  Future<void> _alterarSenha() async {
    final senhaAtual = _senhaAtualController.text.trim();
    final novaSenha = _novaSenhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    // Validações de campos
    if (senhaAtual.isEmpty) {
      _mostrarMensagem('A senha atual é obrigatória.');
      return;
    }
    if (novaSenha.isEmpty) {
      _mostrarMensagem('A nova senha é obrigatória.');
      return;
    }
    if (confirmarSenha.isEmpty) {
      _mostrarMensagem('Confirme a nova senha.');
      return;
    }
    if (novaSenha != confirmarSenha) {
      _mostrarMensagem('A nova senha e a confirmação não coincidem.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final resposta = await apiService.alterarSenha(
        widget.utilizadorId,
        senhaAtual,
        novaSenha,
      );

      // Exibe a mensagem retornada pela API
      if (resposta['success'] == true) {
        _mostrarMensagem(resposta['message'] ?? 'Senha alterada com sucesso!',
            exitScreen: true);
      } else {
        _mostrarMensagem(resposta['message'] ?? 'Erro ao alterar a senha.');
      }
    } catch (e) {
      // Qualquer exceção inesperada
      _mostrarMensagem('Ocorreu um erro inesperado: \$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String mensagem, {bool exitScreen = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Text(mensagem, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (exitScreen) Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF5682BF), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        backgroundColor: const Color(0xFF5682BF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPasswordField('Senha Atual', _senhaAtualController),
            _buildPasswordField('Nova Senha', _novaSenhaController),
            _buildPasswordField(
                'Confirmar Nova Senha', _confirmarSenhaController),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _alterarSenha,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5682BF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text('Salvar Alterações',
                        style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
