enum EventType { missa, reuniao, festa }

class EventModel {
  final String id;
  final String nome;
  final DateTime dataHora;
  final String local;
  final EventType tipo;
  final String? groupId;
  final String? imagemUrl;
  final String? linkExterno;
  final bool publico;

  EventModel({
    required this.id,
    required this.nome,
    required this.dataHora,
    required this.local,
    required this.tipo,
    this.groupId,
    this.imagemUrl,
    this.linkExterno,
    this.publico = true,
  });
}
