enum EventType { missa, reuniao, festa }

class EventModel {
  final String id;
  final String nome;
  final DateTime dataHora;
  final String local;
  final EventType tipo;

  EventModel({
    required this.id,
    required this.nome,
    required this.dataHora,
    required this.local,
    required this.tipo,
  });
}