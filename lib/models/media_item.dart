enum MediaType { live, movie, series, unknown }

class MediaItem {
  final String name;
  final String url;
  final String? logo;
  final String? group;
  final String? tvgId;
  final MediaType type;
  bool isFavorite;

  MediaItem({
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.tvgId,
    this.type = MediaType.unknown,
    this.isFavorite = false,
  });

  MediaItem copyWith({bool? isFavorite}) {
    return MediaItem(
      name: name,
      url: url,
      logo: logo,
      group: group,
      tvgId: tvgId,
      type: type,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'logo': logo,
        'group': group,
        'tvgId': tvgId,
        'type': type.index,
        'isFavorite': isFavorite,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        name: json['name'],
        url: json['url'],
        logo: json['logo'],
        group: json['group'],
        tvgId: json['tvgId'],
        type: MediaType.values[json['type'] ?? 0],
        isFavorite: json['isFavorite'] ?? false,
      );
}
