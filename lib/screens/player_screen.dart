import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/media_item.dart';
import '../theme.dart';

class PlayerScreen extends StatefulWidget {
  final MediaItem item;

  const PlayerScreen({super.key, required this.item});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player _player;
  late final VideoController _controller;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _initPlayer();
  }

  void _initPlayer() {
    _player = Player();
    _controller = VideoController(_player);

    _player.stream.error.listen((err) {
      if (mounted && err.isNotEmpty) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    });

    _player.stream.playing.listen((_) {
      if (mounted) setState(() => _isLoading = false);
    });

    _player.open(Media(widget.item.url));
  }

  Future<void> _openInVlc() async {
    final vlcUri = Uri.parse('vlc://${widget.item.url}');
    if (await canLaunchUrl(vlcUri)) {
      await launchUrl(vlcUri);
    } else {
      // Fallback: copier l'URL
      await Clipboard.setData(ClipboardData(text: widget.item.url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL copiée ! Ouvrez VLC et collez l\'URL manuellement.'),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.item.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Bouton VLC
                  TextButton.icon(
                    onPressed: _openInVlc,
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('VLC'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      backgroundColor: AppTheme.accentGlow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lecteur vidéo
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Video(controller: _controller),
                  if (_isLoading && !_hasError)
                    const CircularProgressIndicator(color: AppTheme.accent),
                  if (_hasError) _buildErrorState(),
                ],
              ),
            ),

            // Info et contrôles bas
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.liveColor, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Le lecteur intégré ne peut pas lire ce flux.',
            style: TextStyle(color: Colors.white, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez d\'ouvrir avec VLC.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openInVlc,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Ouvrir dans VLC'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: widget.item.url));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL copiée dans le presse-papier'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              }
            },
            child: const Text(
              'Copier l\'URL du flux',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.black,
      child: Row(
        children: [
          if (widget.item.group != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.item.group!,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          const Text(
            'Lecteur intégré',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
