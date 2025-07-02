import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:farm4you/Services/api_service.dart';
import 'package:farm4you/screens/product_detail_screen.dart';

/// Modelo de categoria vindo da API.
class CategoriaModel {
  final String id;
  final String nome;

  CategoriaModel({
    required this.id,
    required this.nome,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['_id']?.toString() ?? '',
      nome: json['desc']?.toString() ?? '',
    );
  }
}

/// Tela de pesquisa no estilo “Vinted”:
/// – Campo de pesquisa no AppBar.
/// – Quando o campo estiver vazio: exibe “pesquisas populares”.
/// – Ao digitar algo: exibe filtros de categorias + grid de resultados filtrados.
class ProcurarScreen extends StatefulWidget {
  final ApiService apiService;
  final String utilizadorId;

  const ProcurarScreen({
    Key? key,
    required this.apiService,
    required this.utilizadorId,
  }) : super(key: key);

  @override
  _ProcurarScreenState createState() => _ProcurarScreenState();
}

class _ProcurarScreenState extends State<ProcurarScreen> {
  late Future<List<dynamic>> _produtosFuture;
  late Future<List<CategoriaModel>> _categoriasFuture;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String _selectedCategoryId = 'Todos';
  final int _limit = 50;

  // Exemplos de pesquisas populares
  final List<String> popularSearches = [
    'Caneta Bic',
    'Almofada',
    'Leds',
    'Maçã',
    'Laranja',
    'Couve',
  ];

  @override
  void initState() {
    super.initState();
    _produtosFuture = widget.apiService.fetchProducts();
    _categoriasFuture = widget.apiService.getCategories().then((list) {
      return list.map((json) => CategoriaModel.fromJson(json)).toList();
    });

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim();
      });
    });
  }

  /// Filtra produtos por estado, categoria e texto de pesquisa.
  List<dynamic> _applyFilters(List<dynamic> produtos) {
    return produtos.where((produto) {
      final state = produto['state']?.toString() ?? '';
      if (state != 'Active') return false;

      // Filtrar por texto
      if (_searchText.isNotEmpty) {
        final nome = (produto['name'] ?? '').toString().toLowerCase();
        if (!nome.contains(_searchText.toLowerCase())) return false;
      }

      // Filtrar por categoria (se não for "Todos")
      if (_selectedCategoryId != 'Todos') {
        final idCat = produto['id_category']?.toString() ?? '';
        if (idCat != _selectedCategoryId) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: _buildSearchField(),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_produtosFuture, _categoriasFuture])
            .then((combo) => combo[0] as List<dynamic>),
        builder: (context, prodSnapshot) {
          if (prodSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prodSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar produtos: \n ${prodSnapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          final produtos = prodSnapshot.data ?? [];

          return FutureBuilder<List<CategoriaModel>>(
            future: _categoriasFuture,
            builder: (context, catSnapshot) {
              if (catSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (catSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar categorias:\n${catSnapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final categorias = catSnapshot.data!;

              // Lista de filtros: “Todos” + categorias da API
              final filtros = [
                {'id': 'Todos', 'nome': 'Todos'},
                ...categorias.map((c) => {'id': c.id, 'nome': c.nome}),
              ];

              // Se o campo de pesquisa estiver vazio: mostrar apenas pesquisas populares
              if (_searchText.isEmpty) {
                return _buildEmptySearchView();
              }

              // Quando há texto, aplicar filtros e exibir resultados
              final filtrados = _applyFilters(produtos);
              final displayList = filtrados.length > _limit
                  ? filtrados.sublist(0, _limit)
                  : filtrados;

              return _buildResultsView(displayList, filtros, filtrados.length);
            },
          );
        },
      ),
    );
  }

  /// View para quando o campo de pesquisa está vazio:
  /// – Exibe “Pesquisas populares” em ActionChips.
  Widget _buildEmptySearchView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesquisas Populares',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: popularSearches.map((texto) {
                return ActionChip(
                  label: Text(
                    texto,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  backgroundColor: Colors.grey.shade200,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.text = texto;
                      _searchText = texto;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// View para quando existe texto no campo:
  /// – Chips de categoria (ChoiceChips horizontais)
  /// – Texto com contagem de resultados
  /// – Grid de produtos
  Widget _buildResultsView(List<dynamic> displayList,
      List<Map<String, String>> filtros, int totalFiltrados) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips de categoria horizontais
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                scrollDirection: Axis.horizontal,
                itemCount: filtros.length,
                itemBuilder: (context, index) {
                  final filtro = filtros[index];
                  final isSelected = (_selectedCategoryId == filtro['id']);
                  return Padding(
                    padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8.0,
                        right: index == filtros.length - 1 ? 16 : 0),
                    child: ChoiceChip(
                      label: Text(
                        filtro['nome']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategoryId = filtro['id']!;
                        });
                      },
                      selectedColor: Colors.green.shade700,
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Texto com contagem de resultados
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Encontrados $totalFiltrados produtos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ),

          // Grid de produtos
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final produto = displayList[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          produto: produto,
                          utilizadorId: widget.utilizadorId,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                (produto['base64'] is String &&
                                        produto['base64'].isNotEmpty)
                                    ? Image.memory(
                                        base64Decode(produto['base64']),
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 80,
                                        color: Colors.grey,
                                      ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Text(
                                    produto['name']?.toString() ?? 'Sem nome',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                            child: Text(
                              '${(produto['price'] as num?)?.toStringAsFixed(2) ?? '0.00'} €',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de texto no AppBar com borda arredondada e ícone; texto sempre preto.
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(color: Colors.black87),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'O que procuras?',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      onSubmitted: (q) {
        setState(() {
          _searchText = q.trim();
        });
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
