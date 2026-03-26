import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../providers/iptv_provider.dart';
import '../theme.dart';
import 'media_list_screen.dart';
import 'favorites_screen.dart';
import 'playlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    PlaylistScreen(),
    MediaListScreen(type: MediaType.live),
    MediaListScreen(type: MediaType.movie),
    MediaListScreen(type: MediaType.series),
    FavoritesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IptvProvider>().loadSavedPlaylist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.playlist_play),
              label: 'Playlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv),
              label: 'Chaînes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_outlined),
              label: 'Films',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tv_outlined),
              label: 'Séries',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoris',
            ),
          ],
        ),
      ),
    );
  }
}
