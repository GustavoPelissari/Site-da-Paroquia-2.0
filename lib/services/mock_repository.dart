import '../models/event_model.dart';
import '../models/form_model.dart';
import '../models/group_model.dart';
import '../models/news_model.dart';
import '../models/schedule_model.dart';
import '../models/user_model.dart';

class MockRepository {
  UserModel? user;

  final Map<String, ({String senha, UserModel user})> _mockCredentials = {
    'ana.fiel@paroquia.local': (
      senha: '123456',
      user: UserModel(
        id: 'u1',
        nome: 'Ana Fiel',
        email: 'ana.fiel@paroquia.local',
        nivelAcesso: 0,
        groupIds: {'g2'},
      ),
    ),
    'bruno.membro@paroquia.local': (
      senha: '123456',
      user: UserModel(
        id: 'u2',
        nome: 'Bruno Membro',
        email: 'bruno.membro@paroquia.local',
        nivelAcesso: 1,
        groupIds: {'g1', 'g2'},
      ),
    ),
    'maria.coordenadora@paroquia.local': (
      senha: '123456',
      user: UserModel(
        id: 'u3',
        nome: 'Maria Coordenadora',
        email: 'maria.coordenadora@paroquia.local',
        nivelAcesso: 2,
        groupIds: {'g1'},
      ),
    ),
    'carlos.admin@paroquia.local': (
      senha: '123456',
      user: UserModel(
        id: 'u4',
        nome: 'Carlos Administrativo',
        email: 'carlos.admin@paroquia.local',
        nivelAcesso: 3,
        groupIds: {'g1', 'g2', 'g3'},
      ),
    ),
    'padre.jose@paroquia.local': (
      senha: '123456',
      user: UserModel(
        id: 'u5',
        nome: 'Padre Jose',
        email: 'padre.jose@paroquia.local',
        nivelAcesso: 4,
        groupIds: {'g1', 'g2', 'g3'},
      ),
    ),
  };

  final List<GroupModel> groups = [
    GroupModel(
      id: 'g1',
      nome: 'Pastoral da Juventude',
      descricao: 'Encontros, formacao e servico missionario para jovens.',
      coordenadorUserId: 'u3',
      permitePdfUpload: true,
      permiteFormularios: true,
      permiteNoticias: true,
      permiteEventos: true,
    ),
    GroupModel(
      id: 'g2',
      nome: 'Coroinhas',
      descricao: 'Escalas liturgicas e formacao de altar.',
      coordenadorUserId: 'u3',
      permitePdfUpload: true,
      permiteFormularios: false,
      permiteNoticias: true,
      permiteEventos: false,
    ),
    GroupModel(
      id: 'g3',
      nome: 'Pastoral Familiar',
      descricao: 'Acompanhamento de casais e encontros para familias.',
      coordenadorUserId: 'u4',
      permitePdfUpload: false,
      permiteFormularios: true,
      permiteNoticias: true,
      permiteEventos: true,
    ),
  ];

  final List<NewsModel> news = [
    NewsModel(
      id: 'n1',
      titulo: 'Festa da Padroeira',
      conteudo: 'Programacao aberta para toda a comunidade neste fim de semana.',
      dataPublicacao: DateTime.now().subtract(const Duration(days: 1)),
      imagemUrl: 'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9',
      linkExterno: 'https://paroquia.local/festa-padroeira',
      publico: true,
    ),
    NewsModel(
      id: 'n2',
      titulo: 'Escala interna da Juventude',
      conteudo: 'Escala de servico dos membros da pastoral para o retiro.',
      dataPublicacao: DateTime.now().subtract(const Duration(hours: 5)),
      groupId: 'g1',
      publico: false,
    ),
    NewsModel(
      id: 'n3',
      titulo: 'Aviso dos Coroinhas',
      conteudo: 'Encontro mensal no salao paroquial com todos os servidores.',
      dataPublicacao: DateTime.now().subtract(const Duration(hours: 2)),
      groupId: 'g2',
      publico: true,
    ),
  ];

  final List<EventModel> events = [
    EventModel(
      id: 'e1',
      nome: 'Missa Dominical',
      dataHora: DateTime.now().add(const Duration(hours: 5)),
      local: 'Igreja Matriz',
      tipo: EventType.missa,
      imagemUrl: 'https://images.unsplash.com/photo-1529074963764-98f45c47344b',
      publico: true,
    ),
    EventModel(
      id: 'e2',
      nome: 'Reuniao da Juventude',
      dataHora: DateTime.now().add(const Duration(days: 1)),
      local: 'Salao Paroquial',
      tipo: EventType.reuniao,
      groupId: 'g1',
      publico: false,
    ),
    EventModel(
      id: 'e3',
      nome: 'Encontro da Pastoral Familiar',
      dataHora: DateTime.now().add(const Duration(days: 3)),
      local: 'Auditorio',
      tipo: EventType.festa,
      groupId: 'g3',
      publico: true,
      linkExterno: 'https://paroquia.local/pastoral-familiar',
    ),
  ];

  final List<ScheduleModel> schedules = [
    ScheduleModel(
      id: 's1',
      groupId: 'g2',
      pdfLabel: 'Escala de Coroinhas - Abril',
      pdfUrl: 'https://paroquia.local/escala-coroinhas-abril.pdf',
      descricao: 'Escala oficial de servico no altar.',
      dataUpload: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ScheduleModel(
      id: 's2',
      groupId: 'g1',
      pdfLabel: 'Escala de acolhida - Retiro Jovem',
      pdfUrl: 'https://paroquia.local/escala-juventude-retiro.pdf',
      descricao: 'Responsaveis por acolhida e liturgia.',
      dataUpload: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<FormModel> forms = [
    FormModel(
      id: 'f1',
      titulo: 'Inscricao para retiro jovem',
      groupId: 'g1',
      publico: false,
    ),
    FormModel(
      id: 'f2',
      titulo: 'Atualizacao cadastral da comunidade',
      publico: true,
    ),
  ];

  final List<FormResponseModel> responses = [];

  ({String token, UserModel user})? authenticate(String email, String senha) {
    final entry = _mockCredentials[email.toLowerCase()];
    if (entry == null || entry.senha != senha) return null;
    user = entry.user;
    return (token: 'mock-token-${entry.user.id}', user: entry.user);
  }

  UserModel? findUserByEmail(String email) {
    final entry = _mockCredentials[email.toLowerCase()];
    return entry?.user;
  }

  Future<DateTime> fetchServerNow() async {
    return DateTime.now();
  }
}
