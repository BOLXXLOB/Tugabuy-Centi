import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:farm4you/Services/api_service.dart';
import 'package:farm4you/Screens/chat_screen.dart';

// Extensões na ApiService para chats

// Modelo de chat salvo localmente
class ChatItem {
  final String chatId;
  final String productId;
  final String productName;
  final String otherUserId;
  final String otherUserName;

  ChatItem({
    required this.chatId,
    required this.productId,
    required this.productName,
    required this.otherUserId,
    required this.otherUserName,
  });
}

class ListaMensagensScreen extends StatefulWidget {
  final String meuUserId;
  const ListaMensagensScreen({Key? key, required this.meuUserId})
      : super(key: key);

  @override
  _ListaMensagensScreenState createState() => _ListaMensagensScreenState();
}

class _ListaMensagensScreenState extends State<ListaMensagensScreen> {
  final ApiService _api = ApiService();
  List<ChatItem> _compras = [];
  List<ChatItem> _vendas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final buyerRaw = await _api.getChatsAsBuyer(widget.meuUserId);
      final sellerRaw = await _api.getChatsAsSeller(widget.meuUserId);

      Future<ChatItem> parseRaw(Map<String, dynamic> raw, bool isBuyer) async {
        final prodId = raw['id_product'];
        final otherId = raw['id_user'];

        final prod = await _api.getProduct(prodId);
        print('📦 Produto: $prod');

        final other = await _api.getUser(otherId);
        print('👤 Outro utilizador: $other');

        final productName = prod['name'] is String
            ? prod['name']
            : (prod['name']['pt'] ?? 'Produto');
        final userName = other['name'] is String
            ? other['name']
            : (other['name']['pt'] ?? 'Utilizador');

        return ChatItem(
          chatId: raw['_id'],
          productId: prodId,
          productName: productName,
          otherUserId: otherId,
          otherUserName: userName,
        );
      }

      final buys = await Future.wait(buyerRaw.map((r) => parseRaw(r, true)));
      final sells = await Future.wait(sellerRaw.map((r) => parseRaw(r, false)));

      setState(() {
        _compras = buys;
        _vendas = sells;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Widget _buildSection(String title, List<ChatItem> items) {
    if (items.isEmpty)
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Nenhum chat em $title'),
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final c = items[i];
            return ListTile(
              leading:
                  CircleAvatar(child: Text(c.productName[0].toUpperCase())),
              title: Text(c.productName,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(c.otherUserName),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatId: c.chatId,
                    compradorId: widget.meuUserId,
                    vendedorId: c.otherUserId,
                    vendedorNome: c.otherUserName,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mensagens')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Compras', _compras),
                  _buildSection('Vendas', _vendas),
                ],
              ),
            ),
    );
  }
}
