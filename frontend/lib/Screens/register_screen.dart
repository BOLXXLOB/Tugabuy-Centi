// lib/Screens/register_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:farm4you/Services/api_service.dart';
import 'package:farm4you/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService apiService = ApiService();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final telefoneController = TextEditingController();
  final moradaController = TextEditingController();

  File? imagemSelecionada;
  bool isLoading = false;
  bool _isPasswordVisible = false;

  // Formatter xxx-xxx-xxx
  final telefoneFormatter = MaskTextInputFormatter(mask: '###-###-###');

  bool isValidEmail(String email) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => imagemSelecionada = File(file.path));
    }
  }

  Future<void> registerUser() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final telefone = telefoneController.text.trim();
    final morada = moradaController.text.trim();

    if ([nome, email, password, telefone, morada].any((s) => s.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }
    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um email válido.')),
      );
      return;
    }
    if (!RegExp(r'^\d{3}-\d{3}-\d{3}$').hasMatch(telefone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telefone inválido. Formato: xxx-xxx-xxx')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1) Registar e obter o user recém-criado
      final userMap = await apiService.register(
        nomeController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        telefoneController.text.trim(),
        moradaController.text.trim(),
      );
      final userId = userMap['_id'] as String;

      // 2) Login automático
      final loginResp = await apiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      debugPrint('🔔 loginResp: $loginResp');

      // 3) Extrai o token de dentro de loginResp['user']
      final loginUser = loginResp['user'] as Map<String, dynamic>;
      final token = loginUser['token'] as String;
      if (token.isEmpty) {
        throw Exception('Token vazio recebido do login');
      }

      // 4) Se houver imagem, faz upload
      if (imagemSelecionada != null) {
        await apiService.uploadImageregister(userId, imagemSelecionada!, token);
      }

      // 5) Feedback e navegação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registo e upload concluídos com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registar: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Registar'), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Criar conta',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildTextField(nomeController, 'Nome', Icons.person),
            SizedBox(height: 10),
            _buildTextField(emailController, 'Email', Icons.email,
                keyboard: TextInputType.emailAddress),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [telefoneFormatter],
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            SizedBox(height: 10),
            _buildTextField(moradaController, 'Morada', Icons.home),
            SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text('Selecionar imagem'),
            ),
            if (imagemSelecionada != null) ...[
              SizedBox(height: 10),
              Image.file(imagemSelecionada!, height: 150),
            ],
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child:
                        Text('Registar conta', style: TextStyle(fontSize: 18)),
                  ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              ),
              child: Text.rich(
                TextSpan(
                  text: 'Já tens conta? ',
                  style: TextStyle(color: Colors.blueAccent),
                  children: [
                    TextSpan(
                      text: 'Faz login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }
}
