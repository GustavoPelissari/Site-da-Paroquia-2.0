import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/event_model.dart';
import '../models/schedule_model.dart';
import '../services/mock_repository.dart';

class AppState extends ChangeNotifier {
  final MockRepository _repository = MockRepository();

  // Usuário atual
  UserModel get user => _repository.user;

  // Dados
  List<GroupModel> get groups => _repository.groups;
  List<NewsModel> get news => _repository.news;
  List<EventModel> get events => _repository.events;
  List<ScheduleModel> get schedules => _repository.schedules;

  // Permissões
  bool get isAdmin => user.nivelAcesso >= 1;

  // Helpers
  List<NewsModel> newsByGroup(String groupId) => _repository.getNewsByGroup(groupId);

  List<ScheduleModel> schedulesByGroup(String groupId) =>
      _repository.getSchedulesByGroup(groupId);

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