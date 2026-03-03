import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/event_model.dart';
import '../models/news_model.dart';
import '../models/parish_info_model.dart';
import '../models/user_model.dart';

class ApiRepository {
  ApiRepository({
    String? baseUrl,
    http.Client? client,
  })  : _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: '',
            ),
        _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;
  String? _sessionToken;

  void setSessionToken(String? token) {
    _sessionToken = token;
  }

  String get _effectiveBaseUrl {
    if (_baseUrl.isNotEmpty) return _baseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3001/api';
    }
    return 'http://localhost:3001/api';
  }

  Future<List<EventModel>> fetchEvents() async {
    final data = await _getList('/events');
    return data.map(_eventFromJson).toList();
  }

  Future<List<NewsModel>> fetchNews() async {
    final data = await _getList('/news');
    return data.map(_newsFromJson).toList();
  }

  Future<NewsModel> createNews({
    required String titulo,
    required String conteudo,
    String? groupId,
    String? imagemUrl,
    String? linkExterno,
    required bool publico,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/news');
    final response = await _client
        .post(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'titulo': titulo,
            'conteudo': conteudo,
            'groupId': groupId == null ? null : int.tryParse(groupId),
            'imagemUrl': imagemUrl,
            'linkExterno': linkExterno,
            'publico': publico,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao criar noticia: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return _newsFromJson(raw);
  }

  Future<EventModel> createEvent({
    required String nome,
    required String local,
    required EventType tipo,
    String? groupId,
    String? imagemUrl,
    String? linkExterno,
    required bool publico,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/events');
    final response = await _client
        .post(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'nome': nome,
            'local': local,
            'tipo': _eventTypeToApi(tipo),
            'dataHora': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
            'groupId': groupId == null ? null : int.tryParse(groupId),
            'imagemUrl': imagemUrl,
            'linkExterno': linkExterno,
            'publico': publico,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao criar evento: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return _eventFromJson(raw);
  }

  Future<({String token, String refreshToken, UserModel user})> login({
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/login');
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

    return _parseSessionResponse(response.body);
  }

  Future<({String token, String refreshToken, UserModel user})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/register');
    final response = await _client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha no cadastro: ${response.statusCode}');
    }

    return _parseSessionResponse(response.body);
  }

  Future<({String token, String refreshToken, UserModel user})> refresh({
    required String refreshToken,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/refresh');
    final response = await _client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao renovar sessao: ${response.statusCode}');
    }

    return _parseSessionResponse(response.body);
  }

  Future<UserModel> me() async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/me');
    final response =
        await _client.get(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));

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

  Future<void> logout() async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/logout');
    await _client.post(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));
  }

  Future<void> forgotPassword({required String email}) async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/forgot-password');
    final response = await _client
        .post(
          uri,
          headers: {'content-type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao solicitar redefinicao: ${response.statusCode}');
    }
  }

  Future<DateTime> fetchServerNow() async {
    final uri = Uri.parse('$_effectiveBaseUrl/time');
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

  Future<List<MassScheduleModel>> fetchPublicMassSchedules() async {
    final uri = Uri.parse('$_effectiveBaseUrl/public/mass-schedules');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar horarios de missa: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) throw Exception('Resposta invalida de /public/mass-schedules');

    return raw.whereType<Map<String, dynamic>>().map((item) {
      return MassScheduleModel(
        id: '${item['id']}',
        weekday: (item['weekday'] as num?)?.toInt() ?? 0,
        weekdayLabel: item['weekdayLabel'] as String? ?? '',
        time: item['time'] as String? ?? '',
        locationName: item['locationName'] as String? ?? '',
        isActive: _asBool(item['isActive']),
        notes: item['notes'] as String?,
      );
    }).toList();
  }

  Future<List<OfficeHourModel>> fetchPublicOfficeHours() async {
    final uri = Uri.parse('$_effectiveBaseUrl/public/office-hours');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar horarios da secretaria: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) throw Exception('Resposta invalida de /public/office-hours');

    return raw.whereType<Map<String, dynamic>>().map((item) {
      return OfficeHourModel(
        id: '${item['id']}',
        weekday: (item['weekday'] as num?)?.toInt() ?? 0,
        weekdayLabel: item['weekdayLabel'] as String? ?? '',
        openTime: item['openTime'] as String? ?? '',
        closeTime: item['closeTime'] as String?,
        label: item['label'] as String? ?? 'Secretaria',
        isActive: _asBool(item['isActive']),
        notes: item['notes'] as String?,
      );
    }).toList();
  }

  Future<NextMassModel> fetchNextMass() async {
    final uri = Uri.parse('$_effectiveBaseUrl/public/masses/next');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar proxima missa: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final nextMassRaw = raw['nextMass'] as Map<String, dynamic>?;
    return NextMassModel(
      serverNow: DateTime.parse(raw['serverNow'] as String),
      nextMass: nextMassRaw == null
          ? null
          : NextMassItemModel(
              id: '${nextMassRaw['id']}',
              weekday: (nextMassRaw['weekday'] as num?)?.toInt() ?? 0,
              weekdayLabel: nextMassRaw['weekdayLabel'] as String? ?? '',
              time: nextMassRaw['time'] as String? ?? '',
              locationName: nextMassRaw['locationName'] as String? ?? '',
              startsAt: DateTime.parse(nextMassRaw['startsAt'] as String),
              notes: nextMassRaw['notes'] as String?,
            ),
    );
  }

  Map<String, String> _authHeaders() {
    if (_sessionToken == null) {
      return const {'content-type': 'application/json'};
    }

    return {
      'content-type': 'application/json',
      'authorization': 'Bearer $_sessionToken',
    };
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final uri = Uri.parse('$_effectiveBaseUrl$path');
    final response = await _client.get(uri, headers: _authHeaders()).timeout(
          const Duration(seconds: 6),
        );

    if (response.statusCode != 200) {
      throw Exception('Erro em $path: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) {
      throw Exception('Resposta invalida para $path');
    }

    return raw.whereType<Map<String, dynamic>>().toList();
  }

  ({String token, String refreshToken, UserModel user}) _parseSessionResponse(
    String body,
  ) {
    final raw = jsonDecode(body) as Map<String, dynamic>;
    final token = raw['token'] as String?;
    final refreshToken = raw['refreshToken'] as String?;
    final userRaw = raw['user'] as Map<String, dynamic>?;
    if (token == null || refreshToken == null || userRaw == null) {
      throw Exception('Resposta de login invalida');
    }

    return (
      token: token,
      refreshToken: refreshToken,
      user: UserModel(
        id: '${userRaw['id']}',
        nome: userRaw['nome'] as String? ?? '',
        email: userRaw['email'] as String? ?? '',
        nivelAcesso: (userRaw['nivelAcesso'] as num?)?.toInt() ?? 0,
      ),
    );
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

  String _eventTypeToApi(EventType tipo) {
    return switch (tipo) {
      EventType.missa => 'MISSA',
      EventType.reuniao => 'REUNIAO',
      EventType.festa => 'FESTA',
    };
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
