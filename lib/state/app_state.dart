import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/access_control_model.dart';
import '../models/event_model.dart';
import '../models/form_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';
import '../services/api_repository.dart';
import '../services/mock_repository.dart';

class AppState extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';

  final MockRepository _repository = MockRepository();
  final ApiRepository _api = ApiRepository();

  UserModel? _currentUser;
  String? _token;
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

  AppRole get currentRole => user.role;
  String get currentRoleLabel => user.roleLabel;

  bool hasCapability(AppCapability capability) {
    if (!isAuthenticated) return false;
    if (currentRole == AppRole.padre) return true;
    return user.capabilities.contains(capability);
  }

  bool get canOpenAdminMenu =>
      isAuthenticated &&
      (currentRole == AppRole.coordenador ||
          currentRole == AppRole.administrativo ||
          currentRole == AppRole.padre);

  bool get isAdmin => canOpenAdminMenu;
  bool get hasFloatingAdminActions => canCreateNews || canCreateEvents;
  bool get canCreateNews => hasCapability(AppCapability.createNews);
  bool get canCreateEvents => hasCapability(AppCapability.createEvents);
  bool get canManageUsers => hasCapability(AppCapability.manageUsersHierarchy);

  Future<void> initialize() async {
    _forms.addAll(_repository.forms);
    _formResponses.addAll(_repository.responses);
    _authLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: _tokenKey);
      final storedEmail = await _storage.read(key: _emailKey);

      if (storedToken != null && storedEmail != null) {
        try {
          final user = await _api.me(storedToken);
          _currentUser = user;
          _token = storedToken;
        } catch (_) {
          final local = _repository.findUserByEmail(storedEmail);
          if (local != null) {
            _currentUser = local;
            _token = 'mock-token-${local.id}';
          } else {
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
    _authLoading = true;
    notifyListeners();

    try {
      final result = await _api.login(email: email, senha: senha);
      _token = result.token;
      _currentUser = result.user;
      try {
        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _emailKey, value: email.toLowerCase());
      } catch (_) {}
    } catch (_) {
      final local = _repository.authenticate(email, senha);
      if (local == null) {
        _authError = 'Credenciais invalidas.';
        _authLoading = false;
        notifyListeners();
        return false;
      }
      _token = local.token;
      _currentUser = local.user;
      try {
        await _storage.write(key: _tokenKey, value: _token);
        await _storage.write(key: _emailKey, value: email.toLowerCase());
      } catch (_) {}
    }

    await Future.wait([syncServerClock(), loadRemoteData()]);
    _authLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _clearSession();
    _authLoading = false;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _token = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _emailKey);
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
    if (currentRole == AppRole.padre || currentRole == AppRole.administrativo) {
      return true;
    }
    final group = groupById(groupId);
    if (group == null) return false;
    return group.coordenadorUserId == user.id;
  }

  bool canViewGroupPrivateContent(String groupId) {
    if (!isAuthenticated) return false;
    if (currentRole == AppRole.padre || currentRole == AppRole.administrativo) {
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
    if (currentRole == AppRole.padre || currentRole == AppRole.administrativo) {
      return _formResponses.where((r) => r.formId == formId).length;
    }
    if (groupId != null && canManageGroup(groupId)) {
      return _formResponses.where((r) => r.formId == formId).length;
    }
    return 0;
  }

  void setNivelAcesso(int nivel) {
    if (!isAuthenticated) return;
    user.nivelAcesso = nivel;
    notifyListeners();
  }

  void addNews(NewsModel newsItem) {
    _news.insert(0, newsItem);
    notifyListeners();
  }

  void addEvent(EventModel event) {
    _events.add(event);
    notifyListeners();
  }
}
