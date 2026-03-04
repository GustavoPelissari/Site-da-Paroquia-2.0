import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/event_model.dart';
import '../models/form_model.dart';
import '../models/group_model.dart';
import '../models/mail_settings_model.dart';
import '../models/news_model.dart';
import '../models/parish_info_model.dart';
import '../models/schedule_model.dart';
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

  String get _baseOrigin {
    final uri = Uri.parse(_effectiveBaseUrl);
    final portPart = uri.hasPort ? ':${uri.port}' : '';
    return '${uri.scheme}://${uri.host}$portPart';
  }

  Future<List<EventModel>> fetchEvents({String? query}) async {
    final suffix = (query != null && query.trim().isNotEmpty)
        ? '/events?q=${Uri.encodeQueryComponent(query.trim())}'
        : '/events';
    final data = await _getList(suffix);
    return data.map(_eventFromJson).toList();
  }

  Future<List<NewsModel>> fetchNews({String? query}) async {
    final suffix = (query != null && query.trim().isNotEmpty)
        ? '/news?q=${Uri.encodeQueryComponent(query.trim())}'
        : '/news';
    final data = await _getList(suffix);
    return data.map(_newsFromJson).toList();
  }

  Future<List<GroupModel>> fetchGroups({String? query, String? memberUserId}) async {
    final params = <String>[];
    if (query != null && query.trim().isNotEmpty) {
      params.add('q=${Uri.encodeQueryComponent(query.trim())}');
    }
    if (memberUserId != null && memberUserId.trim().isNotEmpty) {
      params.add('memberUserId=${Uri.encodeQueryComponent(memberUserId.trim())}');
    }
    final suffix = params.isEmpty ? '/groups' : '/groups?${params.join('&')}';
    final data = await _getList(suffix);
    return data.map((raw) {
      return GroupModel(
        id: '${raw['id']}',
        nome: raw['nome'] as String? ?? '',
        descricao: raw['descricao'] as String? ?? '',
        coordenadorUserId: raw['coordenadorUserId']?.toString(),
        permitePdfUpload: _asBool(raw['permitePdfUpload']),
        permiteFormularios: _asBool(raw['permiteFormularios']),
        permiteNoticias: _asBool(raw['permiteNoticias']),
        permiteEventos: _asBool(raw['permiteEventos']),
      );
    }).toList();
  }

  Future<List<FormModel>> fetchGroupForms({required String groupId}) async {
    final parsedId = int.tryParse(groupId);
    if (parsedId == null) return const [];
    final data = await _getList('/groups/$parsedId/forms');
    return data.map((raw) {
      return FormModel(
        id: '${raw['id']}',
        titulo: raw['titulo'] as String? ?? '',
        groupId: raw['groupId']?.toString(),
        publico: _asBool(raw['publico']),
        ativo: _asBool(raw['ativo']),
      );
    }).toList();
  }

  Future<List<ScheduleModel>> fetchGroupSchedules({required String groupId}) async {
    final parsedId = int.tryParse(groupId);
    if (parsedId == null) return const [];
    final data = await _getList('/groups/$parsedId/schedules');
    return data.map((raw) {
      final uploaded = raw['dataUpload']?.toString();
      return ScheduleModel(
        id: '${raw['id']}',
        groupId: '${raw['groupId']}',
        pdfLabel: raw['pdfLabel'] as String? ?? 'Escala',
        pdfUrl: raw['pdfUrl'] as String? ?? '',
        descricao: raw['descricao'] as String?,
        dataUpload: uploaded != null ? DateTime.tryParse(uploaded) ?? DateTime.now() : DateTime.now(),
      );
    }).toList();
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
    String? descricao,
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
            'descricao': descricao,
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

  Future<NewsModel> updateNews({
    required String id,
    required String titulo,
    required String conteudo,
  }) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id da noticia invalido.');
    final uri = Uri.parse('$_effectiveBaseUrl/news/$parsedId');
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'titulo': titulo,
            'conteudo': conteudo,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao atualizar noticia'));
    }
    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return _newsFromJson(raw);
  }

  Future<void> deleteNews({required String id}) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id da noticia invalido.');
    final uri = Uri.parse('$_effectiveBaseUrl/news/$parsedId');
    final response = await _client
        .delete(uri, headers: _authHeaders())
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao excluir noticia'));
    }
  }

  Future<EventModel> updateEvent({
    required String id,
    required String nome,
    required String local,
    String? descricao,
  }) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id do evento invalido.');
    final uri = Uri.parse('$_effectiveBaseUrl/events/$parsedId');
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'nome': nome,
            'local': local,
            'descricao': descricao,
          }),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao atualizar evento'));
    }
    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return _eventFromJson(raw);
  }

  Future<void> deleteEvent({required String id}) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id do evento invalido.');
    final uri = Uri.parse('$_effectiveBaseUrl/events/$parsedId');
    final response = await _client
        .delete(uri, headers: _authHeaders())
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao excluir evento'));
    }
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
      throw Exception(_extractApiError(response, fallback: 'Falha no login'));
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

  Future<List<UserModel>> fetchUsers() async {
    final uri = Uri.parse('$_effectiveBaseUrl/users');
    final response =
        await _client.get(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar usuarios: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) {
      throw Exception('Resposta invalida de /users');
    }

    return raw.whereType<Map<String, dynamic>>().map((item) {
      return UserModel(
        id: '${item['id']}',
        nome: item['nome'] as String? ?? '',
        email: item['email'] as String? ?? '',
        nivelAcesso: (item['nivelAcesso'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<UserModel> updateUserAccessLevel({
    required String userId,
    required int nivelAcesso,
  }) async {
    final id = int.tryParse(userId);
    if (id == null) {
      throw Exception('Id de usuario invalido.');
    }

    final uri = Uri.parse('$_effectiveBaseUrl/users/$id/access-level');
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({'nivelAcesso': nivelAcesso}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar nivel de acesso: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel(
      id: '${raw['id']}',
      nome: raw['nome'] as String? ?? '',
      email: raw['email'] as String? ?? '',
      nivelAcesso: (raw['nivelAcesso'] as num?)?.toInt() ?? 0,
    );
  }

  Future<UserModel> createUserByAdmin({
    required String nome,
    required String email,
    required String senha,
    required int nivelAcesso,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/users');
    final response = await _client
        .post(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'nome': nome,
            'email': email.trim().toLowerCase(),
            'senha': senha,
            'nivelAcesso': nivelAcesso,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao criar usuario'));
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel(
      id: '${raw['id']}',
      nome: raw['nome'] as String? ?? '',
      email: raw['email'] as String? ?? '',
      nivelAcesso: (raw['nivelAcesso'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> deleteUserByAdmin({required String userId}) async {
    final id = int.tryParse(userId);
    if (id == null) {
      throw Exception('Id de usuario invalido.');
    }

    final uri = Uri.parse('$_effectiveBaseUrl/users/$id');
    final response = await _client
        .delete(uri, headers: _authHeaders())
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao excluir usuario'));
    }
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

  Future<MailSettingsModel> fetchMailSettings() async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/admin/mail-settings');
    final response =
        await _client.get(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao carregar configuracao de email'));
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final configured = _asBool(raw['configured']);
    if (!configured) {
      return const MailSettingsModel(configured: false);
    }

    return MailSettingsModel(
      configured: configured,
      host: raw['host'] as String?,
      port: (raw['port'] as num?)?.toInt() ?? 587,
      secure: _asBool(raw['secure']),
      username: raw['username'] as String?,
      hasPassword: _asBool(raw['hasPassword']),
      fromEmail: raw['fromEmail'] as String?,
      fromName: raw['fromName'] as String?,
      resetBaseUrl: raw['resetBaseUrl'] as String?,
      updatedAt: raw['updatedAt'] != null ? DateTime.tryParse(raw['updatedAt'].toString()) : null,
    );
  }

  Future<MailSettingsModel> updateMailSettings({
    required String host,
    required int port,
    required bool secure,
    String? username,
    String? password,
    required String fromEmail,
    String? fromName,
    String? resetBaseUrl,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/auth/admin/mail-settings');
    final payload = <String, dynamic>{
      'host': host.trim(),
      'port': port,
      'secure': secure,
      'username': username?.trim().isEmpty == true ? null : username?.trim(),
      'fromEmail': fromEmail.trim(),
      'fromName': fromName?.trim().isEmpty == true ? null : fromName?.trim(),
      'resetBaseUrl': resetBaseUrl?.trim().isEmpty == true ? null : resetBaseUrl?.trim(),
    };
    if (password != null) {
      payload['password'] = password.trim().isEmpty ? null : password;
    }

    final response = await _client
        .put(
          uri,
          headers: _authHeaders(),
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao salvar configuracao de email'));
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    return MailSettingsModel(
      configured: _asBool(raw['configured']),
      host: raw['host'] as String?,
      port: (raw['port'] as num?)?.toInt() ?? 587,
      secure: _asBool(raw['secure']),
      username: raw['username'] as String?,
      hasPassword: _asBool(raw['hasPassword']),
      fromEmail: raw['fromEmail'] as String?,
      fromName: raw['fromName'] as String?,
      resetBaseUrl: raw['resetBaseUrl'] as String?,
      updatedAt: raw['updatedAt'] != null ? DateTime.tryParse(raw['updatedAt'].toString()) : null,
    );
  }

  Future<DateTime> fetchServerNow() async {
    final uri = Uri.parse('https://worldtimeapi.org/api/timezone/America/Sao_Paulo');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar horario de Brasilia: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final now = raw['datetime'] as String?;
    if (now == null) {
      throw Exception('Resposta invalida da API de horario de Brasilia');
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

    return raw.whereType<Map<String, dynamic>>().map(_massScheduleFromJson).toList();
  }

  Future<List<OfficeHourModel>> fetchPublicOfficeHours() async {
    final uri = Uri.parse('$_effectiveBaseUrl/public/office-hours');
    final response = await _client.get(uri).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar horarios da secretaria: ${response.statusCode}');
    }

    final raw = jsonDecode(response.body);
    if (raw is! List) throw Exception('Resposta invalida de /public/office-hours');

    return raw.whereType<Map<String, dynamic>>().map(_officeHourFromJson).toList();
  }

  Future<MassScheduleModel> createMassSchedule({
    required int weekday,
    required String time,
    required String locationName,
    String? notes,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/mass-schedules');
    final response = await _client
        .post(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'weekday': weekday,
            'time': time,
            'locationName': locationName,
            'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
            'isActive': 1,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao criar horario de missa'));
    }

    return _massScheduleFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<MassScheduleModel> updateMassSchedule({
    required String id,
    required int weekday,
    required String time,
    required String locationName,
    String? notes,
  }) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id de horario invalido.');

    final uri = Uri.parse('$_effectiveBaseUrl/mass-schedules/$parsedId');
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'weekday': weekday,
            'time': time,
            'locationName': locationName,
            'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
            'isActive': 1,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao atualizar horario de missa'));
    }

    return _massScheduleFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deactivateMassSchedule({required String id}) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id de horario invalido.');

    final uri = Uri.parse('$_effectiveBaseUrl/mass-schedules/$parsedId/deactivate');
    final response =
        await _client.patch(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao desativar horario de missa'));
    }
  }

  Future<OfficeHourModel> createOfficeHour({
    required int weekday,
    required String openTime,
    String? closeTime,
    String? label,
    String? notes,
  }) async {
    final uri = Uri.parse('$_effectiveBaseUrl/office-hours');
    final response = await _client
        .post(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'weekday': weekday,
            'openTime': openTime,
            'closeTime': closeTime?.trim().isEmpty == true ? null : closeTime?.trim(),
            'label': label?.trim().isEmpty == true ? 'Secretaria' : label?.trim(),
            'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
            'isActive': 1,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao criar horario de secretaria'));
    }

    return _officeHourFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<OfficeHourModel> updateOfficeHour({
    required String id,
    required int weekday,
    required String openTime,
    String? closeTime,
    String? label,
    String? notes,
  }) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id de horario invalido.');

    final uri = Uri.parse('$_effectiveBaseUrl/office-hours/$parsedId');
    final response = await _client
        .patch(
          uri,
          headers: _authHeaders(),
          body: jsonEncode({
            'weekday': weekday,
            'openTime': openTime,
            'closeTime': closeTime?.trim().isEmpty == true ? null : closeTime?.trim(),
            'label': label?.trim().isEmpty == true ? 'Secretaria' : label?.trim(),
            'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
            'isActive': 1,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha ao atualizar horario de secretaria'));
    }

    return _officeHourFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deactivateOfficeHour({required String id}) async {
    final parsedId = int.tryParse(id);
    if (parsedId == null) throw Exception('Id de horario invalido.');

    final uri = Uri.parse('$_effectiveBaseUrl/office-hours/$parsedId/deactivate');
    final response =
        await _client.patch(uri, headers: _authHeaders()).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception(
        _extractApiError(response, fallback: 'Falha ao desativar horario de secretaria'),
      );
    }
  }

  Future<String> uploadImageFile({required File file}) async {
    final uri = Uri.parse('$_effectiveBaseUrl/uploads/image');
    final request = http.MultipartRequest('POST', uri);
    if (_sessionToken != null) {
      request.headers['authorization'] = 'Bearer $_sessionToken';
    }
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send().timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(_extractApiError(response, fallback: 'Falha no upload da imagem'));
    }

    final raw = jsonDecode(response.body) as Map<String, dynamic>;
    final url = raw['url'] as String?;
    if (url == null || url.trim().isEmpty) {
      throw Exception('Resposta invalida do upload.');
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '$_baseOrigin${url.startsWith('/') ? '' : '/'}$url';
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
      descricao: raw['descricao'] as String?,
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

  MassScheduleModel _massScheduleFromJson(Map<String, dynamic> item) {
    return MassScheduleModel(
      id: '${item['id']}',
      weekday: (item['weekday'] as num?)?.toInt() ?? 0,
      weekdayLabel: item['weekdayLabel'] as String? ?? '',
      time: item['time'] as String? ?? '',
      locationName: item['locationName'] as String? ?? '',
      isActive: _asBool(item['isActive']),
      notes: item['notes'] as String?,
    );
  }

  OfficeHourModel _officeHourFromJson(Map<String, dynamic> item) {
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
  }

  String _extractApiError(http.Response response, {required String fallback}) {
    try {
      final raw = jsonDecode(response.body);
      if (raw is Map<String, dynamic>) {
        final message = raw['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        if (message is List && message.isNotEmpty) {
          final first = message.first;
          if (first is String && first.trim().isNotEmpty) {
            return first.trim();
          }
        }
        final error = raw['error'];
        if (error is String && error.trim().isNotEmpty) {
          return '$fallback: ${error.trim()}';
        }
      }
    } catch (_) {}
    if (response.statusCode == HttpStatus.unauthorized) {
      return 'Credenciais invalidas.';
    }
    if (response.statusCode == HttpStatus.forbidden) {
      return 'Sem permissao para esta operacao.';
    }
    return '$fallback (${response.statusCode})';
  }
}
