import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm4you/Services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  final String utilizadorId;
  final String userName;

  const PerfilScreen({
    required this.utilizadorId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late ApiService apiService;
  Map<String, dynamic>? userData;
  String? imageBase64;
  bool isLoading = true;
  bool isEditing = false;
  File? _novaImagem;

  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController moradaController;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    nomeController = TextEditingController();
    emailController = TextEditingController();
    telefoneController = TextEditingController();
    moradaController = TextEditingController();
    _loadUserData();
  }

  /// Carrega dados completos do utilizador
  Future<void> _loadUserData() async {
    setState(() => isLoading = true);
    try {
      final data = await apiService.getUserProfile(widget.utilizadorId);
      setState(() {
        userData = data;
        imageBase64 = data['base64'] ?? '';
        nomeController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        telefoneController.text = data['phone']?.toString() ?? '';
        moradaController.text = data['address'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar perfil: $e")),
      );
    }
  }

  /// Atualiza perfil (texto + opcional imagem)
  Future<void> _atualizarPerfil() async {
    if ([nomeController, emailController, telefoneController, moradaController]
        .any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await apiService.updateProfile(
        utilizadorId: widget.utilizadorId,
        nome: nomeController.text.trim(),
        email: emailController.text.trim(),
        telefone: int.parse(telefoneController.text),
        morada: moradaController.text.trim(),
        imagem: _novaImagem,
      );

      // Recarrega o perfil para refletir alterações sem precisar de logout/login
      await _loadUserData();
      setState(() {
        isEditing = false;
        _novaImagem = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar perfil: $e")),
      );
    }
  }

  /// Seleciona nova imagem (só em modo edição)
  Future<void> _selecionarImagem() async {
    if (!isEditing) return;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _novaImagem = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 155, 196, 231),
              Colors.green.shade50
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            _buildProfileHeader(),
                            const SizedBox(height: 24),
                            isEditing ? _buildEditForm() : _buildProfileInfo(),
                            const SizedBox(height: 24),
                            _buildEditButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    ImageProvider avatar;
    if (_novaImagem != null) {
      avatar = FileImage(_novaImagem!);
    } else if (imageBase64 != null && imageBase64!.isNotEmpty) {
      final bytes = base64Decode(imageBase64!);
      avatar = MemoryImage(bytes);
    } else {
      avatar = const NetworkImage('https://placekitten.com/200/200');
    }

    return GestureDetector(
      onTap: isEditing ? _selecionarImagem : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white,
          child: CircleAvatar(radius: 75, backgroundImage: avatar),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            _buildInfoRow("Nome", userData?['name'] ?? ""),
            _buildDivider(),
            _buildInfoRow("Email", userData?['email'] ?? ""),
            _buildDivider(),
            _buildInfoRow("Telefone", (userData?['phone'] ?? '').toString()),
            _buildDivider(),
            _buildInfoRow("Localização", userData?['address'] ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: Colors.grey, height: 1),
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            _buildTextField("Nome", nomeController),
            const SizedBox(height: 12),
            _buildTextField("Email", emailController),
            const SizedBox(height: 12),
            _buildTextField("Telefone", telefoneController),
            const SizedBox(height: 12),
            _buildTextField("Localização", moradaController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _atualizarPerfil,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Guardar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title:",
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          isEditing = !isEditing;
          if (!isEditing) _novaImagem = null;
        });
      },
      icon: Icon(isEditing ? Icons.cancel : Icons.edit, color: Colors.white),
      label: Text(isEditing ? "Cancelar" : "Editar Perfil",
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 74, 139, 189),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
    );
  }
}
