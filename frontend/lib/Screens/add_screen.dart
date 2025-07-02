import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farm4you/Services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final String utilizadorId;
  final ApiService apiService;

  const AddProductScreen({
    required this.utilizadorId,
    required this.apiService,
    Key? key,
  }) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  // Carrega categorias do servidor
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await widget.apiService.getCategories();
      // Filtra categorias com _id não nulo
      final filtered = list.where((cat) => cat['_id'] != null).toList();
      setState(() {
        _categories = filtered;
        if (filtered.isNotEmpty) {
          _selectedCategoryId = filtered.first['_id'].toString();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar categorias: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _adicionarProduto() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null)
      return;
    setState(() => _isLoading = true);
    try {
      await widget.apiService.addProduct(
        name: _nomeController.text,
        desc: _descricaoController.text,
        price: double.parse(_precoController.text),
        idCategory: _selectedCategoryId!,
        idUser: widget.utilizadorId,
        imageFile: _imageFile,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto adicionado com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao adicionar produto: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Produto'),
        backgroundColor: const Color.fromARGB(255, 46, 87, 149),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço (€)',
                  prefixIcon: Icon(Icons.euro),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obrigatório';
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (_categories.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: _categories
                      .where((cat) => cat['_id'] != null && cat['desc'] != null)
                      .map((cat) {
                    final id = cat['_id'].toString();
                    final name = cat['desc'].toString();
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  decoration: const InputDecoration(
                      labelText: 'Categoria', border: OutlineInputBorder()),
                ),
              const SizedBox(height: 12),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              ElevatedButton(
                  onPressed: _pickImage, child: const Text('Escolher Imagem')),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _adicionarProduto,
                      child: const Text('Adicionar Produto')),
            ],
          ),
        ),
      ),
    );
  }
}
