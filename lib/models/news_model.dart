class NewsModel {
  final String id;
  final String titulo;
  final String? subtitulo;
  final String? categoria;
  final String conteudo;
  final DateTime dataPublicacao;
  final DateTime? agendamentoPublicacao;
  final DateTime? dataExpiracao;
  final String? groupId;
  final String? imagemUrl;
  final List<String> galeriaUrls;
  final String? linkExterno;
  final String? autorNome;
  final bool destaque;
  final bool avisoParoquial;
  final bool publico;

  NewsModel({
    required this.id,
    required this.titulo,
    this.subtitulo,
    this.categoria,
    required this.conteudo,
    required this.dataPublicacao,
    this.agendamentoPublicacao,
    this.dataExpiracao,
    this.groupId,
    this.imagemUrl,
    this.galeriaUrls = const [],
    this.linkExterno,
    this.autorNome,
    this.destaque = false,
    this.avisoParoquial = false,
    this.publico = true,
  });
}
