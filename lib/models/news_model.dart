class NewsModel {
  final String id;
  final String titulo;
  final String conteudo;
  final DateTime dataPublicacao;
  final String? groupId;
  final String? imagemUrl;
  final String? linkExterno;
  final bool publico;

  NewsModel({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.dataPublicacao,
    this.groupId,
    this.imagemUrl,
    this.linkExterno,
    this.publico = true,
  });
}
