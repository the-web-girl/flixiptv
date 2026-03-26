import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/iptv_provider.dart';
import '../widgets/media_card.dart';
import '../screens/player_screen.dart';
import '../theme.dart';

class MediaListScreen extends StatefulWidget {
  final MediaType type;

  const MediaListScreen({super.key, required this.type});

  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  bool _isGridView = false;
  final _searchController = TextEditingController();

  String get _title {
    switch (widget.type) {
      case MediaType.live:
        return 'Chaînes Live';
      case MediaType.movie:
        return 'Films';
      case MediaType.series:
        return 'Séries';
      default:
        return 'Médias';
    }
  }

  Color get _typeColor {
    switch (widget.type) {
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

  List<MediaItem> _getItems(IptvProvider p) {
    switch (widget.type) {
      case MediaType.live:
        return p.liveChannels;
      case MediaType.movie:
        return p.movies;
      case MediaType.series:
        return p.series;
      default:
        return [];
    }
  }

  List<String> _getGroups(IptvProvider p) {
    switch (widget.type) {
      case MediaType.live:
        return p.liveGroups;
      case MediaType.movie:
        return p.movieGroups;
      case MediaType.series:
        return p.seriesGroups;
      default:
        return ['Tous'];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();
    final items = _getItems(provider);
    final groups = _getGroups(provider);

    if (provider.state == LoadingState.idle) {
      return _buildEmptyState(
        icon: Icons.playlist_add,
        message: 'Ajoutez une playlist M3U\ndans l\'onglet Playlist',
      );
    }

    if (provider.state == LoadingState.loading) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        // Header avec titre et vues
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          color: AppTheme.bg,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _typeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length}',
                      style: TextStyle(
                        color: _typeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _isGridView ? Icons.view_list : Icons.grid_view,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _isGridView = !_isGridView),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Recherche
              TextField(
                controller: _searchController,
                onChanged: provider.setSearch,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Rechercher dans $_title...',
                  prefixIcon: const Icon(Icons.search,
                      color: AppTheme.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearch('');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              // Groupes
              if (groups.length > 1)
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final isSelected = provider.selectedGroup == group;
                      return GestureDetector(
                        onTap: () => provider.setGroup(group),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _typeColor
                                : AppTheme.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? _typeColor
                                  : AppTheme.border,
                            ),
                          ),
                          child: Text(
                            group,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // Liste
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState(
                  icon: Icons.search_off,
                  message: 'Aucun résultat trouvé',
                )
              : _isGridView
                  ? _buildGrid(items, provider)
                  : _buildList(items, provider),
        ),
      ],
    );
  }

  Widget _buildList(List<MediaItem> items, IptvProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaCard(
          item: item,
          onTap: () => _openPlayer(context, item),
          onFavoriteToggle: () => provider.toggleFavorite(item),
        );
      },
    );
  }

  Widget _buildGrid(List<MediaItem> items, IptvProvider provider) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaCard(
          item: item,
          onTap: () => _openPlayer(context, item),
          onFavoriteToggle: () => provider.toggleFavorite(item),
          isGridView: true,
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.accent),
          const SizedBox(height: 16),
          Text(
            'Chargement de $_title...',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _openPlayer(BuildContext context, MediaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(item: item)),
    );
  }
}
