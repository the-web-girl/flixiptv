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
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget();
        },
      );
      if (mounted) setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) setState(() {
        _hasError = true;
        _isInitializing = false;
      });
    }
  }

  Future<void> _openInVlc() async {
    final vlcUri = Uri.parse('vlc://${widget.item.url}');
    if (await canLaunchUrl(vlcUri)) {
      await launchUrl(vlcUri);
    } else {
      await Clipboard.setData(ClipboardData(text: widget.item.url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL copiée — ouvrez VLC et collez l\'URL'),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
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
                  TextButton.icon(
                    onPressed: _openInVlc,
                    icon: const Icon(Icons.open_in_new, size: 15),
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
                      child: CircularProgressIndicator(
                          color: AppTheme.accent))
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: AppTheme.liveColor, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Impossible de lire ce flux.',
            style: TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openInVlc,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Ouvrir dans VLC'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
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
                    content: Text('URL copiée'),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              }
            },
            child: const Text('Copier l\'URL',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}