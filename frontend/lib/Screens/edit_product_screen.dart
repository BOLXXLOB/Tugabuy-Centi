// lib/Screens/edit_product_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm4you/Services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Map<String, dynamic> produto;
  final ApiService apiService;

  const EditProductScreen({
    Key? key,
    required this.produto,
    required this.apiService,
  }) : super(key: key);

  @override
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.produto['name']);
    _descCtrl = TextEditingController(text: widget.produto['desc']);
    _priceCtrl =
        TextEditingController(text: widget.produto['price'].toString());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = widget.produto['_id'] as String;
    try {
      await widget.apiService.updateProduct(
        id: id,
        name: _nameCtrl.text,
        desc: _descCtrl.text,
        price: double.parse(_priceCtrl.text),
        idCategory: widget.produto['id_category'],
        idUser: widget.produto['id_user'],
        imageFile: _newImage,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto atualizado com sucesso!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final id = widget.produto['_id'] as String;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Produto'),
        content: const Text('Tem a certeza que quer eliminar este produto?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.apiService.deleteProduct(id);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao eliminar: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.blue[50],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageBase64 = widget.produto['base64']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Produto'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _newImage != null
                        ? Image.file(
                            _newImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : imageBase64.isNotEmpty
                            ? Image.memory(
                                base64Decode(imageBase64),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 50),
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 80),
                              )),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameCtrl,
                label: 'Nome',
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              _buildTextField(
                controller: _descCtrl,
                label: 'Descrição',
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              _buildTextField(
                controller: _priceCtrl,
                label: 'Preço',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Atualizar Produto',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Eliminar Produto',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
