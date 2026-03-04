enum EventType { missa, reuniao, festa, retiro }

class EventModel {
  final String id;
  final String nome;
  final DateTime dataHora;
  final DateTime? dataFinal;
  final String local;
  final EventType tipo;
  final String? descricao;
  final String? groupId;
  final String? imagemUrl;
  final String? linkExterno;
  final String? linkInscricao;
  final int? limiteParticipantes;
  final bool publico;

  EventModel({
    required this.id,
    required this.nome,
    required this.dataHora,
    this.dataFinal,
    required this.local,
    required this.tipo,
    this.descricao,
    this.groupId,
    this.imagemUrl,
    this.linkExterno,
    this.linkInscricao,
    this.limiteParticipantes,
    this.publico = true,
  });
}
