class Source {
  final String id;
  final String name;
  final String url;
  final String type;
  final String? icon;
  final bool enabled;

  Source({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.icon,
    this.enabled = true,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      icon: json['icon'],
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'icon': icon,
      'enabled': enabled,
    };
  }
}
