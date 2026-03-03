import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

import '../models/access_control_model.dart';
import '../models/event_model.dart';
import '../models/form_model.dart';
import '../models/group_model.dart';
import '../models/mail_settings_model.dart';
import '../models/news_model.dart';
import '../models/parish_info_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../services/api_repository.dart';
import '../services/mock_repository.dart';

class AppState extends ChangeNotifier {
  static const String _selfAccessLevelTestEmail = 'usuario.teste@paroquia.local';
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  final MockRepository _repository = MockRepository();
  final ApiRepository _api = ApiRepository();

  UserModel? _currentUser;
  String? _token;
  String? _refreshToken;
  bool _authLoading = true;
  String? _authError;

  late List<NewsModel> _news = List<NewsModel>.from(_repository.news);
  late List<EventModel> _events = List<EventModel>.from(_repository.events);
  final List<FormModel> _forms = [];
  final List<FormResponseModel> _formResponses = [];

  Duration _serverOffset = Duration.zero;
  bool _serverClockReady = false;
  bool _isLoadingRemoteData = false;
  String? _remoteError;
  List<MassScheduleModel>? _massSchedulesCache;
  DateTime? _massSchedulesCacheAt;
  List<OfficeHourModel>? _officeHoursCache;
  DateTime? _officeHoursCacheAt;
  NextMassModel? _nextMassCache;
  DateTime? _nextMassCacheAt;
  List<UserModel> _usersManagement = <UserModel>[];
  bool _usersManagementLoading = false;
  String? _usersManagementError;
  MailSettingsModel _mailSettings = const MailSettingsModel(configured: false);
  bool _mailSettingsLoading = false;

  bool get isAuthenticated => _currentUser != null && _token != null;
  bool get authLoading => _authLoading;
  String? get authError => _authError;
  UserModel get user => _currentUser!;
  String? get token => _token;

  List<GroupModel> get groups => _repository.groups;
  List<ScheduleModel> get schedules => _repository.schedules;

  bool get serverClockReady => _serverClockReady;
  bool get isLoadingRemoteData => _isLoadingRemoteData;
  String? get remoteError => _remoteError;
  DateTime get serverNow => DateTime.now().add(_serverOffset);
  List<UserModel> get usersManagement => List<UserModel>.unmodifiable(_usersManagement);
  bool get usersManagementLoading => _usersManagementLoading;
  String? get usersManagementError => _usersManagementError;
  MailSettingsModel get mailSettings => _mailSettings;
  bool get mailSettingsLoading => _mailSettingsLoading;

  AppRole get currentRole => user.role;
  String get currentRoleLabel => user.roleLabel;

  bool hasCapability(AppCapability capability) {
    if (!isAuthenticated) return false;
    return user.capabilities.contains(capability);
  }

  bool get canOpenAdminMenu =>
      isAuthenticated &&
      (currentRole == AppRole.coordenador ||
          currentRole == AppRole.administrativo);

  bool get isAdmin => canOpenAdminMenu;
  bool get hasFloatingAdminActions => canCreateNews || canCreateEvents;
  bool get canCreateNews => hasCapability(AppCapability.createNews);
  bool get canCreateEvents => hasCapability(AppCapability.createEvents);
  bool get canManageUsers => hasCapability(AppCapability.manageUsersHierarchy);
  bool get canManageMassSchedules => hasCapability(AppCapability.manageMassSchedules);
  bool get canSelfChangeAccessLevel =>
      isAuthenticated && user.email.trim().toLowerCase() == _selfAccessLevelTestEmail;

  Future<void> initialize() async {
    _forms.addAll(_repository.forms);
    _formResponses.addAll(_repository.responses);
    _authLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: _tokenKey);
      final storedRefreshToken = await _storage.read(key: _refreshTokenKey);

      if (storedToken != null && storedRefreshToken != null) {
        try {
          _api.setSessionToken(storedToken);
          final user = await _api.me();
          _currentUser = user;
          _token = storedToken;
          _refreshToken = storedRefreshToken;
        } catch (_) {
          try {
            final session = await _api.refresh(refreshToken: storedRefreshToken);
            _token = session.token;
            _refreshToken = session.refreshToken;
            _currentUser = session.user;
            _api.setSessionToken(_token);
            await _storage.write(key: _tokenKey, value: _token);
            await _storage.write(key: _refreshTokenKey, value: _refreshToken);
          } catch (_) {
            await _clearSession();
          }
        }
      }

      if (isAuthenticated) {
        await Future.wait([syncServerClock(), loadRemoteData()]);
      }
    } catch (_) {
      _authError = 'Falha ao validar sessao.';
      _currentUser = null;
      _token = null;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    _authError = null;

    try {
      final result = await _api.login(email: email, senha: senha);
      _token = result.token;
      _refreshToken = result.refreshToken;
      _currentUser = result.user;
      _api.setSessionToken(_token);
      try {
        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _refreshTokenKey, value: _refreshToken);
      } catch (_) {}
    } catch (e) {
      _authError = 'Falha no login: $e';
      return false;
    }

    await Future.wait([syncServerClock(), loadRemoteData()]);
    return true;
  }

  Future<bool> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _authError = null;

    try {
      final result = await _api.register(name: nome, email: email, password: senha);
      _token = result.token;
      _refreshToken = result.refreshToken;
      _currentUser = result.user;
      _api.setSessionToken(_token);
      try {
        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _refreshTokenKey, value: _refreshToken);
      } catch (_) {}
    } catch (e) {
      _authError = 'Falha no cadastro: $e';
      return false;
    }

    await Future.wait([syncServerClock(), loadRemoteData()]);
    return true;
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        _api.setSessionToken(_token);
        await _api.logout();
      }
    } catch (_) {}

    await _clearSession();
    notifyListeners();
  }

  Future<void> forgotPassword({required String email}) async {
    await _api.forgotPassword(email: email.trim());
  }

  Future<void> loadMailSettings() async {
    if (!isAuthenticated || !isAdmin) return;
    _mailSettingsLoading = true;
    notifyListeners();
    try {
      _mailSettings = await _api.fetchMailSettings();
    } catch (_) {
      _mailSettings = const MailSettingsModel(configured: false);
    } finally {
      _mailSettingsLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveMailSettings({
    required String host,
    required int port,
    required bool secure,
    String? username,
    String? password,
    required String fromEmail,
    String? fromName,
    String? resetBaseUrl,
  }) async {
    if (!isAuthenticated || !isAdmin) {
      throw Exception('Sem permissao para alterar configuracao de email.');
    }
    _mailSettings = await _api.updateMailSettings(
      host: host,
      port: port,
      secure: secure,
      username: username,
      password: password,
      fromEmail: fromEmail,
      fromName: fromName,
      resetBaseUrl: resetBaseUrl,
    );
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _token = null;
    _refreshToken = null;
    _massSchedulesCache = null;
    _massSchedulesCacheAt = null;
    _officeHoursCache = null;
    _officeHoursCacheAt = null;
    _nextMassCache = null;
    _nextMassCacheAt = null;
    _api.setSessionToken(null);
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (_) {}
  }

  bool isMemberOfGroup(String groupId) {
    if (!isAuthenticated) return false;
    return user.groupIds.contains(groupId);
  }

  GroupModel? groupById(String groupId) {
    for (final group in groups) {
      if (group.id == groupId) return group;
    }
    return null;
  }

  bool canManageGroup(String groupId) {
    if (!isAuthenticated) return false;
    if (currentRole == AppRole.administrativo) {
      return true;
    }
    final group = groupById(groupId);
    if (group == null) return false;
    return group.coordenadorUserId == user.id;
  }

  bool canViewGroupPrivateContent(String groupId) {
    if (!isAuthenticated) return false;
    if (currentRole == AppRole.administrativo) {
      return true;
    }
    return isMemberOfGroup(groupId) || canManageGroup(groupId);
  }

  bool canCreateNewsForGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;
    return group.permiteNoticias && hasCapability(AppCapability.createNews);
  }

  bool canCreateEventsForGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;
    return group.permiteEventos && hasCapability(AppCapability.createEvents);
  }

  bool canUploadScheduleForGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;
    return group.permitePdfUpload &&
        hasCapability(AppCapability.uploadPdfSchedules);
  }

  bool canCreateFormForGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null) return false;
    return group.permiteFormularios && hasCapability(AppCapability.createForms);
  }

  List<NewsModel> get news => _news.where(_canUserViewNews).toList();
  List<EventModel> get events => _events.where(_canUserViewEvent).toList();

  bool _canUserViewNews(NewsModel item) {
    if (item.publico || item.groupId == null) return true;
    return canViewGroupPrivateContent(item.groupId!);
  }

  bool _canUserViewEvent(EventModel item) {
    if (item.publico || item.groupId == null) return true;
    return canViewGroupPrivateContent(item.groupId!);
  }

  Future<void> loadRemoteData() async {
    _isLoadingRemoteData = true;
    _remoteError = null;
    notifyListeners();

    try {
      final fetchedEvents = await _api.fetchEvents();
      final fetchedNews = await _api.fetchNews();

      if (fetchedEvents.isNotEmpty) _events = fetchedEvents;
      if (fetchedNews.isNotEmpty) _news = fetchedNews;
    } catch (e) {
      _remoteError = e.toString();
    } finally {
      _isLoadingRemoteData = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadData() => loadRemoteData();

  Future<void> syncServerClock() async {
    try {
      final server = await _api.fetchServerNow();
      final local = DateTime.now();
      _serverOffset = server.difference(local);
      _serverClockReady = true;
    } catch (_) {
      try {
        final server = await _repository.fetchServerNow();
        final local = DateTime.now();
        _serverOffset = server.difference(local);
      } catch (_) {}
      _serverClockReady = false;
    }
    notifyListeners();
  }

  List<NewsModel> newsByGroup(String groupId) {
    return _news.where((item) {
      if (item.groupId != groupId) return false;
      if (item.publico) return true;
      return canViewGroupPrivateContent(groupId);
    }).toList();
  }

  List<ScheduleModel> schedulesByGroup(String groupId) {
    if (!canViewGroupPrivateContent(groupId)) return [];
    return _repository.schedules.where((s) => s.groupId == groupId).toList();
  }

  List<FormModel> formsByGroup(String groupId) {
    final group = groupById(groupId);
    if (group == null || !group.permiteFormularios) return [];
    return _forms.where((form) {
      if (!form.ativo) return false;
      if (form.groupId == null) return form.publico;
      if (form.groupId != groupId) return false;
      if (form.publico) return true;
      return canViewGroupPrivateContent(groupId);
    }).toList();
  }

  bool hasResponded(String formId) {
    if (!isAuthenticated) return false;
    return _formResponses.any((r) => r.formId == formId && r.userId == user.id);
  }

  void submitFormResponse({
    required String formId,
    required String resposta,
  }) {
    if (!isAuthenticated || hasResponded(formId)) return;
    _formResponses.add(
      FormResponseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        formId: formId,
        userId: user.id,
        resposta: resposta,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  int responsesCount(String formId, {String? groupId}) {
    if (!isAuthenticated) return 0;
    if (currentRole == AppRole.administrativo) {
      return _formResponses.where((r) => r.formId == formId).length;
    }
    if (groupId != null && canManageGroup(groupId)) {
      return _formResponses.where((r) => r.formId == formId).length;
    }
    return 0;
  }

  int landingTabIndexForCurrentUser() {
    return 0;
  }

  Future<void> loadUsersManagement({bool forceRefresh = false}) async {
    if (!canManageUsers) {
      _usersManagement = <UserModel>[];
      _usersManagementError = null;
      _usersManagementLoading = false;
      notifyListeners();
      return;
    }
    if (_usersManagementLoading) return;
    if (!forceRefresh && _usersManagement.isNotEmpty) return;

    _usersManagementLoading = true;
    _usersManagementError = null;
    notifyListeners();
    try {
      final users = await _api.fetchUsers();
      _usersManagement = users;
    } catch (e) {
      _usersManagementError = e.toString();
    } finally {
      _usersManagementLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserAccessLevel({
    required String userId,
    required int nivelAcesso,
  }) async {
    if (!canManageUsers) {
      throw Exception('Sem permissao para gerenciar usuarios.');
    }
    final updated = await _api.updateUserAccessLevel(
      userId: userId,
      nivelAcesso: nivelAcesso,
    );

    final index = _usersManagement.indexWhere((u) => u.id == updated.id);
    if (index >= 0) {
      _usersManagement[index] = updated;
    } else {
      _usersManagement.add(updated);
    }

    if (_currentUser != null && _currentUser!.id == updated.id) {
      _currentUser!.nivelAcesso = updated.nivelAcesso;
    }
    notifyListeners();
  }

  Future<void> createUserByAdmin({
    required String nome,
    required String email,
    required String senha,
    required int nivelAcesso,
  }) async {
    if (!canManageUsers) {
      throw Exception('Sem permissao para criar usuarios.');
    }

    final created = await _api.createUserByAdmin(
      nome: nome,
      email: email,
      senha: senha,
      nivelAcesso: nivelAcesso,
    );
    _usersManagement.insert(0, created);
    notifyListeners();
  }

  Future<void> deleteUserByAdmin({required String userId}) async {
    if (!canManageUsers) {
      throw Exception('Sem permissao para excluir usuarios.');
    }

    await _api.deleteUserByAdmin(userId: userId);
    _usersManagement.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  Future<List<MassScheduleModel>> fetchMassSchedules({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final isFresh = _massSchedulesCacheAt != null &&
        now.difference(_massSchedulesCacheAt!) < const Duration(minutes: 5);
    if (!forceRefresh && isFresh && _massSchedulesCache != null) {
      return _massSchedulesCache!;
    }

    final data = await _api.fetchPublicMassSchedules();
    _massSchedulesCache = data;
    _massSchedulesCacheAt = now;
    return data;
  }

  Future<List<OfficeHourModel>> fetchOfficeHours({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final isFresh =
        _officeHoursCacheAt != null && now.difference(_officeHoursCacheAt!) < const Duration(minutes: 5);
    if (!forceRefresh && isFresh && _officeHoursCache != null) {
      return _officeHoursCache!;
    }

    final data = await _api.fetchPublicOfficeHours();
    _officeHoursCache = data;
    _officeHoursCacheAt = now;
    return data;
  }

  Future<NextMassModel> fetchNextMass({bool forceRefresh = false}) async {
    final now = DateTime.now();
    final isFresh =
        _nextMassCacheAt != null && now.difference(_nextMassCacheAt!) < const Duration(minutes: 3);
    if (!forceRefresh && isFresh && _nextMassCache != null) {
      return _nextMassCache!;
    }

    final data = await _api.fetchNextMass();
    _nextMassCache = data;
    _nextMassCacheAt = now;
    return data;
  }

  Future<void> createMassSchedule({
    required int weekday,
    required String time,
    required String locationName,
    String? notes,
  }) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios de missa.');
    }
    await _api.createMassSchedule(
      weekday: weekday,
      time: time,
      locationName: locationName,
      notes: notes,
    );
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> updateMassSchedule({
    required String id,
    required int weekday,
    required String time,
    required String locationName,
    String? notes,
  }) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios de missa.');
    }
    await _api.updateMassSchedule(
      id: id,
      weekday: weekday,
      time: time,
      locationName: locationName,
      notes: notes,
    );
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> deactivateMassSchedule({required String id}) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios de missa.');
    }
    await _api.deactivateMassSchedule(id: id);
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> createOfficeHour({
    required int weekday,
    required String openTime,
    String? closeTime,
    String? label,
    String? notes,
  }) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios da secretaria.');
    }
    await _api.createOfficeHour(
      weekday: weekday,
      openTime: openTime,
      closeTime: closeTime,
      label: label,
      notes: notes,
    );
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> updateOfficeHour({
    required String id,
    required int weekday,
    required String openTime,
    String? closeTime,
    String? label,
    String? notes,
  }) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios da secretaria.');
    }
    await _api.updateOfficeHour(
      id: id,
      weekday: weekday,
      openTime: openTime,
      closeTime: closeTime,
      label: label,
      notes: notes,
    );
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> deactivateOfficeHour({required String id}) async {
    if (!canManageMassSchedules) {
      throw Exception('Sem permissao para gerenciar horarios da secretaria.');
    }
    await _api.deactivateOfficeHour(id: id);
    _invalidateScheduleCaches();
    notifyListeners();
  }

  Future<void> createNewsItem({
    required String titulo,
    required String conteudo,
    String? groupId,
    String? imagemUrl,
    String? linkExterno,
    required bool publico,
  }) async {
    if (!isAuthenticated || !canCreateNews) {
      throw Exception('Sem permissao para criar noticia.');
    }
    final created = await _api.createNews(
      titulo: titulo,
      conteudo: conteudo,
      groupId: groupId,
      imagemUrl: imagemUrl,
      linkExterno: linkExterno,
      publico: publico,
    );
    _news.insert(0, created);
    notifyListeners();
  }

  Future<String> uploadImageFile({required File file}) async {
    if (!isAuthenticated) {
      throw Exception('Sessao invalida.');
    }
    return _api.uploadImageFile(file: file);
  }

  Future<void> createEventItem({
    required String nome,
    required String local,
    required EventType tipo,
    String? descricao,
    String? groupId,
    String? imagemUrl,
    String? linkExterno,
    required bool publico,
  }) async {
    if (!isAuthenticated || !canCreateEvents) {
      throw Exception('Sem permissao para criar evento.');
    }
    final created = await _api.createEvent(
      nome: nome,
      local: local,
      tipo: tipo,
      descricao: descricao,
      groupId: groupId,
      imagemUrl: imagemUrl,
      linkExterno: linkExterno,
      publico: publico,
    );
    _events.add(created);
    notifyListeners();
  }

  void _invalidateScheduleCaches() {
    _massSchedulesCache = null;
    _massSchedulesCacheAt = null;
    _officeHoursCache = null;
    _officeHoursCacheAt = null;
    _nextMassCache = null;
    _nextMassCacheAt = null;
  }
}
