import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../theme.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final _urlController = TextEditingController();
  bool _isExpanded = false;

  static const _defaultUrl =
      'https://raw.githubusercontent.com/Rodri200906/IPTV-Rodri/main/IPTV-Rodri.m3u';

  final _presetPlaylists = [
    {
      'name': 'IPTV Rodri (Test)',
      'url': 'https://raw.githubusercontent.com/Rodri200906/IPTV-Rodri/main/IPTV-Rodri.m3u',
      'desc': 'France, Portugal, Brésil — chaînes gratuites',
      'color': AppTheme.accent,
    },
    {
      'name': 'Free-TV World',
      'url': 'https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8',
      'desc': 'Collection mondiale de chaînes gratuites',
      'color': AppTheme.seriesColor,
    },
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<IptvProvider>();
    _urlController.text = provider.currentPlaylistUrl.isNotEmpty
        ? provider.currentPlaylistUrl
        : _defaultUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IptvProvider>();
    final isLoaded = provider.state == LoadingState.loaded;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('FlixIPTV'),
        actions: [
          if (isLoaded)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${provider.totalCount} flux',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero / titre
            _buildHeader(),
            const SizedBox(height: 24),

            // Stats si chargé
            if (isLoaded) ...[
              _buildStats(provider),
              const SizedBox(height: 24),
            ],

            // Presets
            const Text(
              'Listes préconfigurées',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...(_presetPlaylists.map((p) => _buildPresetCard(p, provider))),

            const SizedBox(height: 24),

            // URL personnalisée
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                children: [
                  const Text(
                    'URL personnalisée',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'https://exemple.com/playlist.m3u',
                  prefixIcon: Icon(Icons.link, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.state == LoadingState.loading
                      ? null
                      : () => _load(provider, _urlController.text.trim()),
                  icon: provider.state == LoadingState.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded),
                  label: Text(provider.state == LoadingState.loading
                      ? 'Chargement...'
                      : 'Charger la playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Erreur
            if (provider.state == LoadingState.error) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.liveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.liveColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.liveColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(
                            color: AppTheme.liveColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Info légale
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      color: AppTheme.textSecondary, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Utilisez uniquement des listes M3U légales et gratuites. '
                      'FlixIPTV ne fournit aucun contenu — il lit uniquement vos propres listes.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentGlow, Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FlixIPTV',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Votre lecteur M3U universel',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(IptvProvider provider) {
    return Row(
      children: [
        _StatChip(
          label: 'Chaînes',
          count: provider.liveCount,
          color: AppTheme.liveColor,
          icon: Icons.live_tv,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Films',
          count: provider.movieCount,
          color: AppTheme.movieColor,
          icon: Icons.movie,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Séries',
          count: provider.seriesCount,
          color: AppTheme.seriesColor,
          icon: Icons.tv,
        ),
      ],
    );
  }

  Widget _buildPresetCard(Map<String, dynamic> preset, IptvProvider provider) {
    final isActive = provider.currentPlaylistUrl == preset['url'];
    return GestureDetector(
      onTap: () => _load(provider, preset['url'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? (preset['color'] as Color).withOpacity(0.12)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? (preset['color'] as Color).withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (preset['color'] as Color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.playlist_play,
                color: preset['color'] as Color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset['name'] as String,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    preset['desc'] as String,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: AppTheme.accent, size: 20)
            else
              provider.state == LoadingState.loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  void _load(IptvProvider provider, String url) {
    if (url.isEmpty) return;
    provider.loadFromUrl(url);
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
