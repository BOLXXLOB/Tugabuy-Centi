import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de mensagem
class MessageModel {
  final String id;
  final String idUser;
  final String message;
  final DateTime sendTime;

  MessageModel({
    required this.id,
    required this.idUser,
    required this.message,
    required this.sendTime,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'].toString(),
      idUser: json['id_user'].toString(),
      message: json['message'] as String,
      sendTime: DateTime.parse(json['send_time'] as String),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String compradorId;
  final String vendedorId;
  final String vendedorNome;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.compradorId,
    required this.vendedorId,
    required this.vendedorNome,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controllerMensagem = TextEditingController();
  final _scrollController = ScrollController();
  List<MessageModel> _listaMensagens = [];
  Timer? _timerPolling;
  bool _enviando = false;
  static const String _baseUrl = "https://api.tugabuy.ss-centi.com";

  @override
  void initState() {
    super.initState();
    _buscaMensagens();
    _timerPolling = Timer.periodic(const Duration(seconds: 2), (_) {
      _buscaMensagens();
    });
  }

  @override
  void dispose() {
    _timerPolling?.cancel();
    _controllerMensagem.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _buscaMensagens() async {
    final url = Uri.parse("$_baseUrl/messages/chat/${widget.chatId}");
    final token = await _getToken();
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List;
        final novaLista = body
            .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (!_listasIguais(novaLista, _listaMensagens)) {
          setState(() {
            _listaMensagens = novaLista;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        debugPrint('Erro ao buscar mensagens: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exceção no fetch mensagens: $e');
    }
  }

  bool _listasIguais(List<MessageModel> a, List<MessageModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].message != b[i].message ||
          a[i].sendTime != b[i].sendTime) {
        return false;
      }
    }
    return true;
  }

  Future<void> _enviarMensagem() async {
    final texto = _controllerMensagem.text.trim();
    if (texto.isEmpty || _enviando) return;
    setState(() => _enviando = true);
    final url = Uri.parse("$_baseUrl/messages");
    final token = await _getToken();
    final body = jsonEncode({
      "message": texto,
      "id_chat": widget.chatId,
      "id_user": widget.compradorId,
    });
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: body,
      );
      if (response.statusCode == 201) {
        _controllerMensagem.clear();
        await _buscaMensagens();
      } else {
        debugPrint('Erro ao enviar mensagem: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exceção no envio mensagem: $e');
    }
    if (mounted) setState(() => _enviando = false);
  }

  Widget _buildBubble(MessageModel msg) {
    final isMe = msg.idUser == widget.compradorId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlueAccent.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 8, 7, 7)),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.sendTime),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.vendedorNome)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _listaMensagens.length,
                itemBuilder: (context, i) => _buildBubble(_listaMensagens[i]),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerMensagem,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Escreva uma mensagem...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _enviarMensagem(),
                    ),
                  ),
                  IconButton(
                    icon: _enviando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: _enviando ? null : _enviarMensagem,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
