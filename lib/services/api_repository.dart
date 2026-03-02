import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/event_model.dart';
import '../models/news_model.dart';
import '../models/user_model.dart';

class ApiRepository {
  ApiRepository({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3001/api'),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  Future<List<EventModel>> fetchEvents() async {
    final data = await _getList('/events');
    return data.map(_eventFromJson).toList();
  }

  Future<List<NewsModel>> fetchNews() async {
    final data = await _getList('/news');
    return data.map(_newsFromJson).toList();
  }

  Future<({String token, UserModel user})> login({
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await _client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'email': email, 'senha': senha}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha no login: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final token = raw['token'] as String?;
    final userRaw = raw['user'] as Map<String, dynamic>?;
    if (token == null || userRaw == null) {
      throw Exception('Resposta de login invalida');
    }

    return (
      token: token,
      user: UserModel(
        id: '${userRaw['id']}',
        nome: userRaw['nome'] as String? ?? '',
        email: userRaw['email'] as String? ?? '',
        nivelAcesso: (userRaw['nivelAcesso'] as num?)?.toInt() ?? 0,
      ),
    );
  }

  Future<UserModel> me(String token) async {
    final uri = Uri.parse('$_baseUrl/auth/me');
    final response = await _client.get(
      uri,
      headers: {'authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Sessao invalida');
    }
    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel(
      id: '${raw['id']}',
      nome: raw['nome'] as String? ?? '',
      email: raw['email'] as String? ?? '',
      nivelAcesso: (raw['nivelAcesso'] as num?)?.toInt() ?? 0,
    );
  }

  Future<DateTime> fetchServerNow() async {
    final uri = Uri.parse('$_baseUrl/time');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar horario do servidor: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final now = raw['now'] as String?;
    if (now == null) {
      throw Exception('Resposta invalida de /time');
    }

    return DateTime.parse(now);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro em $path: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) {
      throw Exception('Resposta invalida para $path');
    }

    return raw.whereType<Map<String, dynamic>>().toList();
  }

  EventModel _eventFromJson(Map<String, dynamic> raw) {
    final rawType = (raw['tipo'] as String? ?? '').toUpperCase();
    final type = switch (rawType) {
      'MISSA' => EventType.missa,
      'REUNIAO' => EventType.reuniao,
      'FESTA' => EventType.festa,
      _ => EventType.reuniao,
    };

    return EventModel(
      id: '${raw['id']}',
      nome: raw['nome'] as String? ?? '',
      dataHora: DateTime.parse(raw['dataHora'] as String),
      local: raw['local'] as String? ?? '',
      tipo: type,
      groupId: raw['groupId']?.toString(),
      imagemUrl: raw['imagemUrl'] as String?,
      linkExterno: raw['linkExterno'] as String?,
      publico: _asBool(raw['publico']),
    );
  }

  NewsModel _newsFromJson(Map<String, dynamic> raw) {
    return NewsModel(
      id: '${raw['id']}',
      titulo: raw['titulo'] as String? ?? '',
      conteudo: raw['conteudo'] as String? ?? '',
      dataPublicacao: DateTime.parse(raw['dataPublicacao'] as String),
      groupId: raw['groupId']?.toString(),
      imagemUrl: raw['imagemUrl'] as String?,
      linkExterno: raw['linkExterno'] as String?,
      publico: _asBool(raw['publico']),
    );
  }

  bool _asBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return true;
  }
}
