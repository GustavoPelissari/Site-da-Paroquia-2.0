import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/event_model.dart';
import '../models/schedule_model.dart';
import '../services/mock_repository.dart';

class AppState extends ChangeNotifier {
  final MockRepository _repository = MockRepository();

  // -------------------------
  // Usuário atual
  // -------------------------
  UserModel get user => _repository.user;

  // -------------------------
  // Dados
  // -------------------------
  List<GroupModel> get groups => _repository.groups;
  List<NewsModel> get news => _repository.news;
  List<EventModel> get events => _repository.events;
  List<ScheduleModel> get schedules => _repository.schedules;

  // -------------------------
  // Permissões
  // -------------------------
  bool get isAdmin => user.nivelAcesso >= 1;

  // -------------------------
  // Relógio do servidor (MVP)
  // -------------------------
  Duration _serverOffset = Duration.zero;
  bool _serverClockReady = false;

  bool get serverClockReady => _serverClockReady;

  /// "Agora" baseado no relógio do servidor (ou no melhor chute possível).
  ///
  /// - Se já sincronizou com o servidor: usa offset.
  /// - Se não sincronizou ainda: cai no DateTime.now() do device (fallback).
  DateTime get serverNow => DateTime.now().add(_serverOffset);

  /// Sincroniza a hora do app com a hora do servidor (regra crítica do PDF).
  ///
  /// Estratégia:
  /// 1) Pega a hora do servidor (mock por enquanto).
  /// 2) Calcula offset em relação ao relógio do device.
  /// 3) Usa esse offset no resto do app.
  Future<void> syncServerClock() async {
    try {
      final server = await _repository.fetchServerNow();
      final local = DateTime.now();
      _serverOffset = server.difference(local);
      _serverClockReady = true;
      notifyListeners();
    } catch (_) {
      // Falhou? Sem drama: continua no fallback (relógio do device),
      // mas não marca como "ready".
      _serverClockReady = false;
      notifyListeners();
    }
  }

  // -------------------------
  // Helpers
  // -------------------------
  List<NewsModel> newsByGroup(String groupId) =>
      _repository.getNewsByGroup(groupId);

  List<ScheduleModel> schedulesByGroup(String groupId) =>
      _repository.getSchedulesByGroup(groupId);

  // -------------------------
  // Mutations
  // -------------------------

  // Alterar nível de acesso (tela Perfil)
  void setNivelAcesso(int nivel) {
    user.nivelAcesso = nivel;
    notifyListeners();
  }

  // Criar notícia (admin)
  void addNews(NewsModel newsItem) {
    _repository.news.insert(0, newsItem);
    notifyListeners();
  }

  // Criar evento (admin)
  void addEvent(EventModel event) {
    _repository.events.add(event);
    notifyListeners();
  }
}