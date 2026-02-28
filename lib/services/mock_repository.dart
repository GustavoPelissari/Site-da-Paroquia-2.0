import '../models/user_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/event_model.dart';
import '../models/schedule_model.dart';

class MockRepository {
  // Usuário mock (inicialmente nível 0)
  final UserModel user = UserModel(
    id: 'u1',
    nome: 'Usuário Teste',
    email: 'usuario@paroquia.com',
    nivelAcesso: 0,
  );

  // Grupos / pastorais
  final List<GroupModel> groups = [
    GroupModel(
      id: 'g1',
      nome: 'Pastoral da Juventude',
      descricao: 'Grupo jovem da paróquia',
    ),
    GroupModel(
      id: 'g2',
      nome: 'Coroinhas',
      descricao: 'Serviço ao altar',
    ),
  ];

  // Notícias
  final List<NewsModel> news = [
    NewsModel(
      id: 'n1',
      titulo: 'Festa da Padroeira',
      conteudo: 'Participe da nossa festa da padroeira neste final de semana.',
      dataPublicacao: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NewsModel(
      id: 'n2',
      titulo: 'Encontro da Juventude',
      conteudo: 'Encontro especial da Pastoral da Juventude.',
      dataPublicacao: DateTime.now(),
      groupId: 'g1',
    ),
  ];

  // Eventos
  final List<EventModel> events = [
    EventModel(
      id: 'e1',
      nome: 'Missa Dominical',
      dataHora: DateTime.now().add(const Duration(hours: 5)),
      local: 'Igreja Matriz',
      tipo: EventType.missa,
    ),
    EventModel(
      id: 'e2',
      nome: 'Reunião da Juventude',
      dataHora: DateTime.now().add(const Duration(days: 1)),
      local: 'Salão Paroquial',
      tipo: EventType.reuniao,
    ),
  ];

  // Escalas / documentos
  final List<ScheduleModel> schedules = [
    ScheduleModel(
      id: 's1',
      groupId: 'g2',
      pdfLabel: 'Escala de Coroinhas - Abril',
      dataUpload: DateTime.now(),
    ),
  ];

  // Helpers simples
  List<NewsModel> getNewsByGroup(String groupId) {
    return news.where((n) => n.groupId == groupId).toList();
  }

  List<ScheduleModel> getSchedulesByGroup(String groupId) {
    return schedules.where((s) => s.groupId == groupId).toList();
  }
}