import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.heroTag,
    required this.metadata,
    this.externalLink,
    this.externalLinkLabel,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String description;
  final String? imageUrl;
  final String heroTag;
  final List<String> metadata;
  final String? externalLink;
  final String? externalLinkLabel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 270,
            title: const Text('Detalhes'),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: heroTag,
                child: _DetailImage(imageUrl: imageUrl),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (metadata.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: metadata.map((item) => _MetaChip(text: item)).toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Descricao',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  if (externalLink != null && externalLink!.trim().isNotEmpty) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vinhoParoquial,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      onPressed: () => _openExternalLink(context, externalLink!),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text(externalLinkLabel ?? 'Abrir link externo'),
                    ),
                    ),
                  ],
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (onEdit != null)
                          OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                          ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Excluir'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailImage extends StatelessWidget {
  const _DetailImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        height: 270,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6F1025), Color(0xFF8D1A34)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.article_outlined,
          size: 56,
          color: Colors.white70,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFEDE3E6),
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 42,
              color: AppTheme.vinhoParoquial,
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x22000000), Color(0x66000000)],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.vinhoParoquial,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

Future<void> _openExternalLink(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link invalido.')),
    );
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nao foi possivel abrir o link.')),
    );
  }
}
