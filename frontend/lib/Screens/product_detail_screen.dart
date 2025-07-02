// lib/screens/product_detail_screen.dart

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart'; // Ajusta conforme a tua estrutura de pastas

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> produto;
  final String utilizadorId; // id do comprador logado, ex.: "1234"

  const ProductDetailScreen({
    Key? key,
    required this.produto,
    required this.utilizadorId,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late double estoqueAtual;
  bool _criandoChat = false;
  bool _loadingSeller = true;
  String _sellerName = '';
  String _sellerPhone = '';
  String _sellerAddress = '';
  String _sellerImage = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String _baseUrl = "https://api.tugabuy.ss-centi.com";

  @override
  void initState() {
    super.initState();
    estoqueAtual = 1.0;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.forward();

    _fetchSellerInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }
    return token;
  }

  /// Busca os dados do vendedor via GET /users/{id_user}
  Future<void> _fetchSellerInfo() async {
    final vendedorId = widget.produto['id_user']?.toString() ?? '';
    print("Vendedor id: $vendedorId");
    if (vendedorId.isEmpty) {
      setState(() => _loadingSeller = false);
      return;
    }

    final token = await _getToken();
    final url = Uri.parse("$_baseUrl/users/$vendedorId");

    try {
      final resp = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      if (resp.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(resp.body);
        setState(() {
          _sellerName = json['name']?.toString() ?? '';
          _sellerPhone = json['phone']?.toString() ?? '';
          _sellerAddress = json['address']?.toString() ?? '';
          _sellerImage = json['base64']?.toString() ?? '';
          _loadingSeller = false;
          print("1");
        });
      } else {
        setState(() => _loadingSeller = false);
        print("2");
      }
    } catch (e) {
      setState(() => _loadingSeller = false);
    }
  }

  /// Guarda localmente em SharedPreferences o chatId + info do vendedor + do produto
  Future<void> _salvarChatLocal({
    required String chatId,
    required String vendedorId,
    required String vendedorNome,
    required String productId,
    required String productName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('minhasConversas');
    List<dynamic> list = [];
    print("3");
    if (saved != null) {
      list = jsonDecode(saved) as List<dynamic>;
    }
    bool exists =
        list.any((e) => (e as Map<String, dynamic>)['productId'] == productId);
    // Usamos productId para garantir que só há UM chat por produto
    if (!exists) {
      list.add({
        'chatId': chatId,
        'vendedorId': vendedorId,
        'vendedorNome': vendedorNome,
        'productId': productId,
        'productName': productName,
      });
      prefs.setString('minhasConversas', jsonEncode(list));
    }
  }

  /// Chama POST /chats com { "id_product": ... } (é o que o backend espera)
  Future<String?> _criarOuRecuperarChat({required String idProduct}) async {
    final url = Uri.parse("$_baseUrl/chats");
    final token = await _getToken();
    final bodyMap = {
      "id_product": idProduct,
      "id_user": widget.utilizadorId, // <— aqui incluído
    };
    try {
      final resp = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode(bodyMap),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return json["_id"]?.toString();
      } else {
        debugPrint("Erro ao criar chat (${resp.statusCode}): ${resp.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception ao criar chat: $e");
      return null;
    }
  }

  /// Ao tocar em “Chat”, cria/recupera o chat, guarda localmente e navega
  Future<void> _irParaChat() async {
    if (_loadingSeller) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("A carregar dados do vendedor, aguarde...")),
      );
      return;
    }

    setState(() {
      _criandoChat = true;
    });

    final String idProd = widget.produto['_id']?.toString() ?? "";
    final String productName = widget.produto['name']?.toString() ?? "";
    if (idProd.isEmpty || productName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto inválido")),
      );
      setState(() {
        _criandoChat = false;
      });
      return;
    }

    // 1) POST /chats { id_product: idProd }
    final chatId = await _criarOuRecuperarChat(idProduct: idProd);

    setState(() {
      _criandoChat = false;
    });

    if (chatId != null && chatId.isNotEmpty) {
      final String vendedorId = widget.produto['id_user']?.toString() ?? "";
      if (vendedorId.isEmpty || _sellerName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Dados do vendedor em falta.")),
        );
        return;
      }

      // 2) Guarda localmente { chatId, vendedorId, vendedorNome, productId, productName }
      await _salvarChatLocal(
        chatId: chatId,
        vendedorId: vendedorId,
        vendedorNome: _sellerName,
        productId: idProd,
        productName: productName,
      );

      // 3) Navega para ChatScreen, passando todos os dados necessários
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            compradorId: widget.utilizadorId,
            vendedorId: vendedorId,
            vendedorNome: _sellerName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível iniciar o chat.")),
      );
    }
  }

  Widget buildHeader() {
    final imageUrl = Image.memory(
      base64Decode(widget.produto['base64']),
    );

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color.fromARGB(255, 165, 180, 197),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              base64Decode(widget.produto['base64']),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductDetails() {
    final nomeRaw = widget.produto['name'];
    final descRaw = widget.produto['desc'];
    final priceRaw = widget.produto['price'];

    final nome = (nomeRaw != null) ? nomeRaw.toString() : "";
    final desc = (descRaw != null) ? descRaw.toString() : "";
    final precoDouble =
        priceRaw != null ? double.tryParse(priceRaw.toString()) ?? 0 : 0;
    final precoTexto = '${precoDouble.toStringAsFixed(0)} €';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.15),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nome,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              precoTexto,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.lightBlueAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.inventory, color: Colors.lightBlueAccent),
                const SizedBox(width: 6),
                Text(
                  'Stock: 1',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSellerCard() {
    if (_loadingSeller) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
            child: CircularProgressIndicator(
          color: Colors.white,
        )),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color.fromARGB(255, 190, 196, 202).withOpacity(0.20),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: _sellerImage.isNotEmpty
                  ? MemoryImage(base64Decode(_sellerImage))
                  : null,
              // se não houver imagem, fica só com o fundo azul claro
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _sellerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        _sellerPhone,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _sellerAddress.isNotEmpty
                              ? _sellerAddress
                              : 'Sem endereço',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _criandoChat ? null : _irParaChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
              ),
              child: _criandoChat
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.chat, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 162, 172, 188),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color(0xFF1976D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              buildHeader(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    buildProductDetails(),
                    buildSellerCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom bar com botão “Criar Chat”
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        color: Colors.blue.shade800,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _criandoChat ? null : _irParaChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _criandoChat
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Criar Chat',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
