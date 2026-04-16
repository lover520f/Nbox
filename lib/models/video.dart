class Video {
  final String id;
  final String name;
  final String cover;
  final String url;
  final String? year;
  final String? region;
  final String? type;
  final String? actor;
  final String? director;
  final String? desc;
  final String? playUrl;
  final List<Episode>? episodes;

  Video({
    required this.id,
    required this.name,
    required this.cover,
    required this.url,
    this.year,
    this.region,
    this.type,
    this.actor,
    this.director,
    this.desc,
    this.playUrl,
    this.episodes,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    var episodesJson = json['episodes'] as List? ?? [];
    return Video(
      id: json['id'] ?? json['url'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      cover: json['cover'] ?? json['pic'] ?? '',
      url: json['url'] ?? '',
      year: json['year']?.toString(),
      region: json['region'],
      type: json['type'] ?? json['category'],
      actor: json['actor'],
      director: json['director'],
      desc: json['desc'] ?? json['description'],
      playUrl: json['playUrl'],
      episodes: episodesJson.map((e) => Episode.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cover': cover,
      'url': url,
      'year': year,
      'region': region,
      'type': type,
      'actor': actor,
      'director': director,
      'desc': desc,
      'playUrl': playUrl,
      'episodes': episodes?.map((e) => e.toJson()).toList(),
    };
  }
}

class Episode {
  final String id;
  final String name;
  final String url;

  Episode({
    required this.id,
    required this.name,
    required this.url,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}
