class LiveChannel {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String? group;
  final String? epgUrl;

  LiveChannel({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.epgUrl,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    return LiveChannel(
      id: json['id'] ?? json['url'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      url: json['url'] ?? '',
      logo: json['logo'] ?? json['icon'],
      group: json['group'] ?? json['category'],
      epgUrl: json['epgUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'logo': logo,
      'group': group,
      'epgUrl': epgUrl,
    };
  }
}

class LiveGroup {
  final String name;
  final List<LiveChannel> channels;

  LiveGroup({
    required this.name,
    required this.channels,
  });
}
