// lib/Screens/home_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:farm4you/Services/api_service.dart';
import 'package:farm4you/Screens/dashboard_screen.dart';
import 'package:farm4you/Screens/procurar_produtos.dart';
import 'package:farm4you/Screens/edit_product_screen.dart';
import 'package:farm4you/Screens/mensagens.dart';
import 'package:farm4you/Screens/perfil_screen.dart';
import 'package:farm4you/Screens/add_screen.dart';
import 'package:farm4you/Screens/settings.dart';

class HomeScreen extends StatefulWidget {
  final String utilizadorId;
  final String userName;

  const HomeScreen({
    required this.utilizadorId,
    required this.userName,
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenAgricultorState createState() => _HomeScreenAgricultorState();
}

class _HomeScreenAgricultorState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ApiService apiService = ApiService();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
          apiService: apiService, utilizadorId: widget.utilizadorId),
      ProcurarScreen(apiService: apiService, utilizadorId: widget.utilizadorId),
      ProdutosScreen(utilizadorId: widget.utilizadorId, apiService: apiService),
      ListaMensagensScreen(meuUserId: widget.utilizadorId),
      PerfilScreen(
          utilizadorId: widget.utilizadorId, userName: widget.userName),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddPressed() async {
    // Apenas mostra o AddProductScreen quando estiver na aba Produtos (index 2)
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          utilizadorId: widget.utilizadorId,
          apiService: apiService,
        ),
      ),
    );
    if (result == true && _selectedIndex == 2) {
      // força reload dos produtos
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 49, 188, 243),
        title: Row(
          children: [
            Image.asset('assets/images/image.png', height: 40),
            const SizedBox(width: 16),
            const Text('TugaBuy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.gear),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ConfigurationsScreen(utilizadorId: widget.utilizadorId),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: _onAddPressed,
              child: const Icon(Icons.add),
              backgroundColor: const Color.fromARGB(255, 42, 150, 193),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.house), label: 'Início'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.search), label: 'Pesquisar'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.plus), label: 'Produtos'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.mailBulk), label: 'Mensagens'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userLarge), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 47, 50, 150),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

// lib/Screens/produtos_screen.dart

class ProdutosScreen extends StatefulWidget {
  final String utilizadorId;
  final ApiService apiService;

  const ProdutosScreen({
    required this.utilizadorId,
    required this.apiService,
    Key? key,
  }) : super(key: key);

  @override
  _ProdutosScreenState createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  late Future<List<dynamic>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _loadProdutos();
  }

  void _loadProdutos() {
    setState(() {
      _produtosFuture =
          widget.apiService.getProductsByUser(widget.utilizadorId);
    });
  }

  void _editarProduto(Map<String, dynamic> produto) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProductScreen(produto: produto, apiService: widget.apiService),
      ),
    );
    if (result == true) {
      _loadProdutos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _produtosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro:  ${snapshot.error}'));
        }
        final produtos = snapshot.data ?? [];
        if (produtos.isEmpty) {
          return const Center(child: Text('Nenhum produto disponível'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: produtos.length,
          itemBuilder: (context, index) {
            final produto = produtos[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (produto['base64'] is String &&
                          produto['base64'].isNotEmpty)
                      ? Image.memory(
                          base64Decode(produto['base64']),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported, size: 60),
                ),
                title: Text(
                  produto['name'] ?? 'Sem nome',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    'Preço: ${(produto['price'] as num).toStringAsFixed(2)} €'),
                onTap: () => _editarProduto(produto),
              ),
            );
          },
        );
      },
    );
  }
}
