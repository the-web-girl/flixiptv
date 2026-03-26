import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';
import '../services/m3u_parser.dart';

enum LoadingState { idle, loading, loaded, error }

class IptvProvider extends ChangeNotifier {
  List<MediaItem> _allItems = [];
  LoadingState _state = LoadingState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _currentPlaylistUrl = '';
  String _selectedGroup = 'Tous';

  List<MediaItem> get liveChannels => _filtered(MediaType.live);
  List<MediaItem> get movies => _filtered(MediaType.movie);
  List<MediaItem> get series => _filtered(MediaType.series);

  List<MediaItem> get favorites =>
      _allItems.where((i) => i.isFavorite).toList();

  LoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get currentPlaylistUrl => _currentPlaylistUrl;
  String get selectedGroup => _selectedGroup;

  List<String> get liveGroups => _groupsFor(MediaType.live);
  List<String> get movieGroups => _groupsFor(MediaType.movie);
  List<String> get seriesGroups => _groupsFor(MediaType.series);

  List<String> _groupsFor(MediaType type) {
    final groups = _allItems
        .where((i) => i.type == type)
        .map((i) => i.group ?? 'Autres')
        .toSet()
        .toList();
    groups.sort();
    return ['Tous', ...groups];
  }

  List<MediaItem> _filtered(MediaType type) {
    return _allItems.where((item) {
      if (item.type != type) return false;
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedGroup != 'Tous' &&
          (item.group ?? 'Autres') != _selectedGroup) {
        return false;
      }
      return true;
    }).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
  }

  void resetGroup() {
    _selectedGroup = 'Tous';
    notifyListeners();
  }

  Future<void> loadFromUrl(String url) async {
    _state = LoadingState.loading;
    _errorMessage = '';
    _currentPlaylistUrl = url;
    notifyListeners();

    try {
      final items = await M3uParser.fromUrl(url);
      if (items.isEmpty) {
        _state = LoadingState.error;
        _errorMessage = 'Aucun flux trouvé dans ce fichier M3U.';
      } else {
        await _mergeWithFavorites(items);
        _state = LoadingState.loaded;
        await _savePlaylistUrl(url);
      }
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = 'Erreur de chargement : ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> loadFromString(String content) async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      final items = M3uParser.fromString(content);
      await _mergeWithFavorites(items);
      _state = LoadingState.loaded;
    } catch (e) {
      _state = LoadingState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> _mergeWithFavorites(List<MediaItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final favUrls = prefs.getStringList('favorites') ?? [];
    _allItems = items.map((item) {
      return item.copyWith(isFavorite: favUrls.contains(item.url));
    }).toList();
  }

  Future<void> toggleFavorite(MediaItem item) async {
    final idx = _allItems.indexWhere((i) => i.url == item.url);
    if (idx == -1) return;
    _allItems[idx] = _allItems[idx].copyWith(
      isFavorite: !_allItems[idx].isFavorite,
    );
    final prefs = await SharedPreferences.getInstance();
    final favUrls = _allItems
        .where((i) => i.isFavorite)
        .map((i) => i.url)
        .toList();
    await prefs.setStringList('favorites', favUrls);
    notifyListeners();
  }

  Future<void> _savePlaylistUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastPlaylistUrl', url);
  }

  Future<void> loadSavedPlaylist() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('lastPlaylistUrl');
    if (url != null && url.isNotEmpty) {
      await loadFromUrl(url);
    }
  }

  int get totalCount => _allItems.length;
  int get liveCount => _allItems.where((i) => i.type == MediaType.live).length;
  int get movieCount => _allItems.where((i) => i.type == MediaType.movie).length;
  int get seriesCount => _allItems.where((i) => i.type == MediaType.series).length;
}
