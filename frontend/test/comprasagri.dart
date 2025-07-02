import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farm4you/Services/api_service.dart';

class PedidosScreen extends StatefulWidget {
  final int utilizadorId;
  final ApiService apiService;

  const PedidosScreen({
    required this.utilizadorId,
    required this.apiService,
    Key? key,
  }) : super(key: key);

  @override
  _PedidosScreenState createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  late Future<List<dynamic>> pedidosFuture;
  late Future<List<dynamic>> comprasFuture;

  @override
  void initState() {
    super.initState();
    // Carrega as compras e os pedidos na inicialização
    pedidosFuture =
        widget.apiService.getPedidosByUtilizadorId(widget.utilizadorId);
    comprasFuture =
        widget.apiService.getComprasByUtilizadorId(widget.utilizadorId);
  }

  String _estadoTexto(int estadoId) {
    switch (estadoId) {
      case 1:
        return 'A levar para a transportadora';
      case 2:
        return 'Recebido pela transportadora';
      case 3:
        return 'A caminho de sua casa';
      case 4:
        return 'Pronto a levantar';
      case 5:
        return 'Em preparação';
      case 6:
        return 'Recusada';
      case 7:
        return 'Aceite';
      case 8:
        return 'Pago e aguardando pela confirmação';
      case 9:
        return 'Aguardando confirmação';
      case 10:
        return 'Pedido realizado';
      case 11:
        return 'Entregue';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos e Compras'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Seção de Pedidos
            FutureBuilder<List<dynamic>>(
              future: pedidosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar pedidos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum pedido encontrado.'));
                } else {
                  final pedidos = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Meus Pedidos",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...pedidos.map((pedido) {
                        final dataPedido =
                            DateTime.parse(pedido['data_pedido']);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Pedido ${pedido['pedido_id']}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      _estadoTexto(pedido['estado_id']),
                                      style: TextStyle(
                                          color: Colors.green, fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Data do Pedido: ${DateFormat('dd/MM/yyyy HH:mm').format(dataPedido)}",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                                Text("Produto: ${pedido['produto_nome']}"),
                                Text(
                                    "Quantidade: ${pedido['quantidade']} ${pedido['unidade_medida']}"),
                                Text(
                                    "Agricultor: ${pedido['agricultor_nome']}"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
            // Seção de Compras
            FutureBuilder<List<dynamic>>(
              future: comprasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar compras'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma compra encontrada.'));
                } else {
                  final compras = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Minhas Compras",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...compras.map((compra) {
                        final dataPedido =
                            DateTime.parse(compra['data_pedido']);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Produto: ${compra['nome_produto']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  "Quantidade: ${compra['quantidade']} ${compra['unidade_medida']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Preço total: ${compra['preco_total']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  "Data do Pedido: ${DateFormat('dd/MM/yyyy HH:mm').format(dataPedido)}",
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                    "Estado: ${_estadoTexto(compra['estado_id'])}"),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
