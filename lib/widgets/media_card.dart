import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../theme.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isGridView;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isGridView = false,
  });

  Color get _typeColor {
    switch (item.type) {
      case MediaType.live:
        return AppTheme.liveColor;
      case MediaType.movie:
        return AppTheme.movieColor;
      case MediaType.series:
        return AppTheme.seriesColor;
      default:
        return AppTheme.accent;
    }
  }

  String get _typeLabel {
    switch (item.type) {
      case MediaType.live:
        return 'LIVE';
      case MediaType.movie:
        return 'FILM';
      case MediaType.series:
        return 'SÉRIE';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isGridView) return _buildGridCard(context);
    return _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Row(
          children: [
            // Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52,
                height: 52,
                color: AppTheme.surface,
                child: item.logo != null && item.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.logo!,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const _LogoPlaceholder(),
                        errorWidget: (_, __, ___) => const _LogoPlaceholder(),
                      )
                    : const _LogoPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            color: _typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (item.group != null) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.group!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Favorite
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.redAccent : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const Icon(
              Icons.play_circle_outline,
              color: AppTheme.accent,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(13)),
                child: Container(
                  color: AppTheme.surface,
                  child: item.logo != null && item.logo!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.logo!,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const _LogoPlaceholder(),
                          errorWidget: (_, __, ___) => const _LogoPlaceholder(),
                        )
                      : const _LogoPlaceholder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _typeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            color: _typeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onFavoriteToggle,
                        child: Icon(
                          item.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: item.isFavorite
                              ? Colors.redAccent
                              : AppTheme.textSecondary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.tv, color: AppTheme.textSecondary, size: 24),
    );
  }
}
