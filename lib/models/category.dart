class Category {
  final String id;
  final String name;
  final String? url;
  final List<Filter>? filters;

  Category({
    required this.id,
    required this.name,
    this.url,
    this.filters,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var filtersJson = json['filters'] as List? ?? [];
    return Category(
      id: json['id'] ?? json['name'] ?? '',
      name: json['name'] ?? '',
      url: json['url'],
      filters: filtersJson.map((e) => Filter.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'filters': filters?.map((e) => e.toJson()).toList(),
    };
  }
}

class Filter {
  final String key;
  final String name;
  final List<String> values;

  Filter({
    required this.key,
    required this.name,
    required this.values,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      values: (json['values'] as List? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'values': values,
    };
  }
}
