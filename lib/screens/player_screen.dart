import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
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
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.item.url),
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
        },
      );
      await _videoController!.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Timeout'),
      );
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        errorBuilder: (context, errorMessage) => _buildErrorWidget(),
      );
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) setState(() {
        _hasError = true;
        _isInitializing = false;
      });
      // Si le lecteur intégré échoue, ouvrir VLC automatiquement
      _openInVlc(auto: true);
    }
  }

  Future<void> _openInVlc({bool auto = false}) async {
    final url = widget.item.url;

    // Essai 1 : intent VLC direct (Android)
    final vlcIntent = Uri.parse('vlc://$url');
    if (await canLaunchUrl(vlcIntent)) {
      await launchUrl(vlcIntent, mode: LaunchMode.externalApplication);
      return;
    }

    // Essai 2 : intent Android avec type vidéo
    final videoUri = Uri.parse(url);
    if (await canLaunchUrl(videoUri)) {
      await launchUrl(videoUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback : copier l'URL si rien ne fonctionne
    if (mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('URL copiée — collez-la dans VLC'),
          backgroundColor: AppTheme.accent,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Bouton VLC manuel
                  TextButton.icon(
                    onPressed: () => _openInVlc(),
                    icon: const Icon(Icons.play_circle, size: 16),
                    label: const Text('VLC'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      backgroundColor: AppTheme.accentGlow,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lecteur
            Expanded(
              child: _isInitializing
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppTheme.accent),
                          SizedBox(height: 16),
                          Text(
                            'Connexion au flux...',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : _hasError
                      ? _buildErrorWidget()
                      : Chewie(controller: _chewieController!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_outline,
              color: AppTheme.accent, size: 72),
          const SizedBox(height: 20),
          Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ce flux sera ouvert dans VLC',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openInVlc(),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text(
                'Ouvrir dans VLC',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.item.group != null)
            Text(
              widget.item.group!,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
        ],
      ),
    );
  }
}