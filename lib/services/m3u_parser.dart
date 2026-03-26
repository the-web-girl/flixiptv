import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class M3uParser {
  static final _vodKeywords = [
    'movie', 'film', 'vod', 'cinema', 'movies', 'filme',
    'pelicul', 'cine', '| film', 'films |', 'vf |', '| vf',
    'vostfr', '| vostfr',
  ];

  static final _seriesKeywords = [
    'series', 'serie', 'séries', 'saison', 'season', 's0', 's1', 's2',
    's3', 's4', 's5', 'episode', 'ep.', ' e0', ' e1', ' e2',
    'tv show', 'tvshow',
  ];

  static MediaType _detectType(String name, String? group) {
    final lowerName = name.toLowerCase();
    final lowerGroup = (group ?? '').toLowerCase();
    final combined = '$lowerName $lowerGroup';

    for (final kw in _seriesKeywords) {
      if (combined.contains(kw)) return MediaType.series;
    }
    for (final kw in _vodKeywords) {
      if (combined.contains(kw)) return MediaType.movie;
    }
    return MediaType.live;
  }

  static List<MediaItem> parse(String content) {
    final items = <MediaItem>[];
    final lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    String? currentGroup;
    String? currentTvgId;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF')) {
        currentName = _extractName(line);
        currentLogo = _extractAttr(line, 'tvg-logo');
        currentGroup = _extractAttr(line, 'group-title');
        currentTvgId = _extractAttr(line, 'tvg-id');
      } else if (line.isNotEmpty && !line.startsWith('#') && currentName != null) {
        final type = _detectType(currentName, currentGroup);
        items.add(MediaItem(
          name: currentName,
          url: line,
          logo: currentLogo,
          group: currentGroup,
          tvgId: currentTvgId,
          type: type,
        ));
        currentName = null;
        currentLogo = null;
        currentGroup = null;
        currentTvgId = null;
      }
    }
    return items;
  }

  static String? _extractAttr(String line, String attr) {
    final regex = RegExp('$attr="([^"]*)"');
    final match = regex.firstMatch(line);
    return match?.group(1);
  }

  static String _extractName(String line) {
    final commaIdx = line.lastIndexOf(',');
    if (commaIdx != -1 && commaIdx < line.length - 1) {
      return line.substring(commaIdx + 1).trim();
    }
    return 'Unknown';
  }

  static Future<List<MediaItem>> fromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return parse(response.body);
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  static List<MediaItem> fromString(String content) {
    return parse(content);
  }
}
