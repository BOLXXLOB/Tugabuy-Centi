import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

class ApiService {
  final String baseUrl = 'https://api.tugabuy.ss-centi.com'; // URL do XAMPP

  // Função para login de utilizador
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }
    print(token);
    return token;
  }

  Future<List<Map<String, dynamic>>> getChatsAsBuyer(String userId) async {
    final uri = Uri.parse('$baseUrl/chats/user/$userId');
    final token = await _getToken();
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    print('📦 RESPOSTA /chats/user: ${resp.body}'); // <--- aqui

    final decoded = jsonDecode(resp.body);

    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else if (decoded is Map && decoded['results'] is List) {
      return (decoded['results'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } else {
      print('❌ Formato inesperado: ${decoded.runtimeType}');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getChatsAsSeller(String ownerId) async {
    final uri = Uri.parse('$baseUrl/chats/owner/$ownerId');
    final token = await _getToken();
    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        print('❌ Esperava uma lista, mas veio ${decoded.runtimeType}');
        return [];
      }
    }

    throw Exception('Erro em getChatsAsSeller: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getProduct(String productId) async {
    final uri = Uri.parse('$baseUrl/products/${productId.trim()}');
    final token = await _getToken();

    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        print('⚠️ Produto com formato inesperado: $decoded');
        return {};
      }
    }

    throw Exception('Erro ao buscar produto: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final uri = Uri.parse('$baseUrl/users/${userId.trim()}');
    final token = await _getToken();

    final resp = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        print('⚠️ Usuário com formato inesperado: $decoded');
        return {};
      }
    }

    throw Exception('Erro ao buscar usuário: ${resp.statusCode}');
  }

  /// Envia uma mensagem para um chat (`POST /message`)
  /// body: { message, id_chat, id_user }
  Future<bool> sendMessage({
    required String chatId,
    required String userId,
    required String texto,
  }) async {
    final uri = Uri.parse("$baseUrl/message");
    final token = await _getToken();
    final body = jsonEncode({
      "message": texto,
      "id_chat": chatId,
      "id_user": userId,
    });
    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: body,
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      print(
          "Erro ao enviar mensagem: ${response.statusCode} / ${response.body}");
      return false;
    }
  }

  /// Login user and store token
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200) {
      final user = body['user'] as Map<String, dynamic>;
      final token = user['token'] as String;
      final userId = user['_id'] as String;
      final username = user['name'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      await prefs.setString('username', username);

      return body;
    } else {
      throw Exception('Erro no login: ${body['message'] ?? resp.body}');
    }
  }

  Future<void> uploadImage(String userId, File image, String token) async {
    // Sem barra no baseUrl, para não duplicar ou quebrar a linha acidentalmente:
    final endpoint = '$baseUrl/users/$userId';
    print('🔔 uploadImage URL: $endpoint');
    final uri = Uri.parse(endpoint);

    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      // não definas Content-Type aqui; o MultipartRequest cuida disso
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,

          // contentType: MediaType('image', 'jpeg'),
        ),
      );

    final resp = await req.send();
    final respBody = await resp.stream.bytesToString();
    print('🔔 uploadImage status: ${resp.statusCode}');
    print('🔔 uploadImage respBody: $respBody');

    if (resp.statusCode != 201) {
      throw Exception('Erro ao enviar imagem: $respBody');
    }
  }

  /// Example of an authenticated GET
  Future<http.Response> getRequest(String path) async {
    final token = await _getToken();
    if (token == null) throw Exception('Usuário não autenticado');

    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Função para registro de utilizador
  Future<void> uploadImageregister(
      String userId, File imageFile, String token) async {
    final uri = Uri.parse('$baseUrl/users/$userId');
    final request = http.MultipartRequest('POST', uri)
      // se a tua rota aceita POST em /users/:id para atualizar a imagem
      ..headers['Authorization'] = 'Bearer $token'
      // adiciona o ficheiro sob o campo "image", exatamente como no Postman
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          // podes definir contentType se quiseres:
          // contentType: MediaType('image','jpeg'),
        ),
      );

    final streamedResp = await request.send();
    final resp = await http.Response.fromStream(streamedResp);

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      // ajusta de acordo com o que a API devolve
      final body = jsonDecode(resp.body);
      throw Exception(
          'Falha no upload da imagem: ${body['message'] ?? resp.body}');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String phoneMasked,
    String address,
  ) async {
    final url = Uri.parse('$baseUrl/users/');
    final rawPhone = phoneMasked.replaceAll(RegExp(r'\D'), '');

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': rawPhone,
        'address': address,
      }),
    );

    final body = jsonDecode(resp.body);
    if (resp.statusCode == 201) {
      // devolve o próprio user como Map
      return body as Map<String, dynamic>;
    } else {
      throw Exception('Erro no registo: ${body['message'] ?? resp.body}');
    }
  }

  // Função para obter categorias
  Future<List<Map<String, dynamic>>> getCategories() async {
    final list = await _authorizedGet('/categories');
    final lista = List<Map<String, dynamic>>.from(list);
    print(lista);
    return lista;
  }

  Future<List<dynamic>> fetchProducts() async {
    // Get token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List products = json.decode(response.body);
      print('Resposta bruta: ${response.body}');
      return products;
    } else {
      print('Erro ao buscar produtos: \ ${response.statusCode}');
      print('Resposta: \ ${response.body}');
      throw Exception('Falha ao buscar produtos');
    }
  }

  Future<void> addProduct({
    required String name,
    required String desc,
    required double price,
    required String idCategory,
    required String idUser,
    File? imageFile,
  }) async {
    // 1) buscar token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');

    // 2) criar produto via JSON
    final createUri = Uri.parse('$baseUrl/products');
    final createResp = await http.post(
      createUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'desc': desc,
        'price': price,
        'id_category': idCategory,
        'id_user': idUser,
      }),
    );

    if (createResp.statusCode != 201) {
      throw Exception('Erro ao criar produto: ${createResp.body}');
    }

    final created = jsonDecode(createResp.body) as Map<String, dynamic>;
    final newProductId = created['_id'] as String;

    // 3) se houver imagem, fazer upload multipart
    if (imageFile != null) {
      // apagar o '/' extra se existir
      final uploadUri = Uri.parse('$baseUrl/products/$newProductId');
      final req = http.MultipartRequest('POST', uploadUri)
        ..headers['Authorization'] = 'Bearer $token'
        // adiciona o ficheiro exatamente como no Postman
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode != 201 && resp.statusCode != 200) {
        // lê body de erro
        throw Exception('Erro upload imagem: ${resp.body}');
      }
    }
  }

  Future<void> deleteProduct(String produtoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print("token do delete: $token");
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$produtoId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Erro ao excluir produto: ${response.statusCode} → ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getProductsByUser(String userId) async {
    // 1) Busca tudo
    final allProducts = await fetchProducts(); // retorna List<dynamic>
    // 2) Filtra os que tenham id_user == userId
    final filtered = allProducts
        .where((raw) {
          if (raw is Map<String, dynamic>) {
            return raw['id_user'].toString() == userId;
          }
          return false;
        })
        .cast<Map<String, dynamic>>()
        .toList();

    return filtered;
  }

  Future<List<dynamic>> _authorizedGet(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null)
      throw Exception('Token não encontrado em SharedPreferences');

    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      } else {
        throw Exception('Formato inesperado na resposta: $data');
      }
    } else {
      throw Exception('Falha ao GET $path: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getSellerInfo(String userId) async {
    final token = await _getToken();

    final url = Uri.parse('$baseUrl/users/$userId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Retorna diretamente os dados do utilizador
      return decoded;
    } else {
      throw Exception(
          'Falha ao carregar perfil (${response.statusCode}): ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required String id,
    required String name,
    required String desc,
    required double price,
    required String idCategory,
    required String idUser,
    File? imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');

    // 1) PATCH sem imagem
    final patchUri = Uri.parse('$baseUrl/products/$id');
    final patchRes = await http.patch(
      patchUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'desc': desc,
        'price': price,
        'id_category': idCategory,
        'id_user': idUser,
      }),
    );
    if (patchRes.statusCode != 200) {
      throw Exception('Erro ao atualizar produto: ${patchRes.body}');
    }
    // decodifica o produto sem imagem
    Map<String, dynamic> productJson = jsonDecode(patchRes.body);

    // 2) upload de imagem (se houver)
    if (imageFile != null) {
      final uploadUri = Uri.parse('$baseUrl/products/$id');
      final req = http.MultipartRequest('POST', uploadUri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 201) {
        throw Exception('Erro no upload da imagem: $body');
      }
      // decodifica e **sobrescreve** productJson com o produto que já traz a imagem
      productJson = jsonDecode(body) as Map<String, dynamic>;
    }

    return productJson;
  }

  Future<Map<String, dynamic>> getUserProfile(String utilizadorId) async {
    final token = await _getToken();

    final url = Uri.parse('$baseUrl/users/$utilizadorId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Retorna diretamente os dados do utilizador
      return decoded;
    } else {
      throw Exception(
          'Falha ao carregar perfil (${response.statusCode}): ${response.body}');
    }
  }

  Future<Map<String, dynamic>> alterarSenha(
      String userId, String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.patch(
        Uri.parse('$baseUrl/users/profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final body = json.decode(response.body) as Map<String, dynamic>?;
      print(body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body?['message'] ?? 'Senha alterada com sucesso!'
        };
      } else {
        return {
          'success': false,
          'message':
              body?['message'] ?? 'Erro na alteração: ${response.statusCode}'
        };
      }
    } on SocketException {
      // Retorna um mapa para o app exibir a mensagem correta
      return {
        'success': false,
        'message': 'Erro de rede. Verifique sua conexão e tente novamente.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Erro interno:  $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String utilizadorId,
    required String nome,
    required String email,
    required int telefone,
    required String morada,
    File? imagem,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token não encontrado');

    // 1) PATCH com os dados de texto
    final patchUri = Uri.parse('$baseUrl/users/$utilizadorId');
    final patchRes = await http.patch(
      patchUri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': nome,
        'email': email,
        'phone': telefone,
        'address': morada,
      }),
    );

    if (patchRes.statusCode != 200) {
      throw Exception('Erro ao atualizar perfil: ${patchRes.body}');
    }

    // Decodifica o JSON do utilizador (sem imagem)
    Map<String, dynamic> profileJson = jsonDecode(patchRes.body);

    // 2) Upload da imagem, se houver
    if (imagem != null) {
      final uploadUri = Uri.parse('$baseUrl/users/$utilizadorId');
      final req = http.MultipartRequest('POST', uploadUri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('image', imagem.path));

      final streamed = await req.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode != 201 && streamed.statusCode != 200) {
        throw Exception('Erro no upload da imagem: $body');
      }

      // Atualiza os dados do perfil com a versão com imagem
      profileJson = jsonDecode(body) as Map<String, dynamic>;
    }

    return profileJson;
  }
}
