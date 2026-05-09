import 'package:hive/hive.dart';

part 'video_source.g.dart';

@HiveType(typeId: 0)
class VideoSource extends HiveObject {
  @HiveField(0)
  String? key;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? api;

  @HiveField(3)
  int? type;

  @HiveField(4)
  String? spider;

  @HiveField(5)
  int? searchable;

  @HiveField(6)
  int? changeable;

  @HiveField(7)
  int? quicksearch;

  @HiveField(8)
  int? filter;

  @HiveField(9)
  int? enabled;

  VideoSource({
    this.key,
    this.name,
    this.api,
    this.type,
    this.spider,
    this.searchable = 1,
    this.changeable = 1,
    this.quicksearch = 1,
    this.filter = 1,
    this.enabled = 1,
  });

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      key: json['key'] as String?,
      name: json['name'] as String?,
      api: json['api'] as String?,
      type: json['type'] as int?,
      spider: json['spider'] as String?,
      searchable: json['searchable'] as int? ?? 1,
      changeable: json['changeable'] as int? ?? 1,
      quicksearch: json['quicksearch'] as int? ?? 1,
      filter: json['filter'] as int? ?? 1,
      enabled: json['enabled'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'api': api,
        'type': type,
        'spider': spider,
        'searchable': searchable,
        'changeable': changeable,
        'quicksearch': quicksearch,
        'filter': filter,
        'enabled': enabled,
      };

  bool get isEnabled => enabled == 1;
  bool get isSearchable => searchable == 1;
  bool get isChangeable => changeable == 1;
  bool get isQuickSearch => quicksearch == 1;
  bool get hasFilter => filter == 1;
}

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String? typeId;

  @HiveField(1)
  String? typeName;

  @HiveField(2)
  String? typeFlag;

  @HiveField(3)
  String? logo;

  @HiveField(4)
  String? extends_;

  Category({
    this.typeId,
    this.typeName,
    this.typeFlag,
    this.logo,
    this.extends_,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      typeId: json['type_id']?.toString(),
      typeName: json['type_name'] as String?,
      typeFlag: json['type_flag'] as String?,
      logo: json['logo'] as String?,
      extends_: json['extends'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type_id': typeId,
        'type_name': typeName,
        'type_flag': typeFlag,
        'logo': logo,
        'extends': extends_,
      };
}

@HiveType(typeId: 2)
class Filter extends HiveObject {
  @HiveField(0)
  String? key;

  @HiveField(1)
  String? name;

  @HiveField(2)
  List<FilterValue>? values;

  Filter({this.key, this.name, this.values});

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      key: json['key'] as String?,
      name: json['name'] as String?,
      values: (json['value'] as List<dynamic>?)
          ?.map((e) => FilterValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'name': name,
        'value': values?.map((e) => e.toJson()).toList(),
      };
}

@HiveType(typeId: 3)
class FilterValue extends HiveObject {
  @HiveField(0)
  String? n;

  @HiveField(1)
  String? v;

  FilterValue({this.n, this.v});

  factory FilterValue.fromJson(Map<String, dynamic> json) {
    return FilterValue(
      n: json['n'] as String?,
      v: json['v'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'n': n, 'v': v};
}

@HiveType(typeId: 4)
class Video extends HiveObject {
  @HiveField(0)
  String? vodId;

  @HiveField(1)
  String? vodName;

  @HiveField(2)
  String? vodPic;

  @HiveField(3)
  String? vodRemarks;

  @HiveField(4)
  String? vodYear;

  @HiveField(5)
  String? vodArea;

  @HiveField(6)
  String? vodLang;

  @HiveField(7)
  String? vodType;

  @HiveField(8)
  String? vodTag;

  @HiveField(9)
  String? vodDirector;

  @HiveField(10)
  String? vodActor;

  @HiveField(11)
  String? vodContent;

  @HiveField(12)
  String? vodPlayFrom;

  @HiveField(13)
  String? vodPlayUrl;

  Video({
    this.vodId,
    this.vodName,
    this.vodPic,
    this.vodRemarks,
    this.vodYear,
    this.vodArea,
    this.vodLang,
    this.vodType,
    this.vodTag,
    this.vodDirector,
    this.vodActor,
    this.vodContent,
    this.vodPlayFrom,
    this.vodPlayUrl,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      vodId: json['vod_id']?.toString(),
      vodName: json['vod_name'] as String?,
      vodPic: json['vod_pic'] as String?,
      vodRemarks: json['vod_remarks'] as String?,
      vodYear: json['vod_year'] as String?,
      vodArea: json['vod_area'] as String?,
      vodLang: json['vod_lang'] as String?,
      vodType: json['vod_type'] as String?,
      vodTag: json['vod_tag'] as String?,
      vodDirector: json['vod_director'] as String?,
      vodActor: json['vod_actor'] as String?,
      vodContent: json['vod_content'] as String?,
      vodPlayFrom: json['vod_play_from'] as String?,
      vodPlayUrl: json['vod_play_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'vod_id': vodId,
        'vod_name': vodName,
        'vod_pic': vodPic,
        'vod_remarks': vodRemarks,
        'vod_year': vodYear,
        'vod_area': vodArea,
        'vod_lang': vodLang,
        'vod_type': vodType,
        'vod_tag': vodTag,
        'vod_director': vodDirector,
        'vod_actor': vodActor,
        'vod_content': vodContent,
        'vod_play_from': vodPlayFrom,
        'vod_play_url': vodPlayUrl,
      };

  List<String> get playSources {
    if (vodPlayFrom == null || vodPlayFrom!.isEmpty) return [];
    return vodPlayFrom!.split('\$\$\$');
  }

  List<Episode> get episodes {
    if (vodPlayUrl == null || vodPlayUrl!.isEmpty) return [];
    final List<Episode> result = [];
    final sources = playSources;
    final urls = vodPlayUrl!.split('\$\$\$');
    for (int i = 0; i < sources.length && i < urls.length; i++) {
      result.add(Episode(source: sources[i], url: urls[i]));
    }
    return result;
  }

  List<String> getEpisodesBySource(int sourceIndex) {
    final eps = episodes;
    if (sourceIndex >= eps.length) return [];
    return eps[sourceIndex]
        .url
        .split('#')
        .map((e) {
          final parts = e.split('\$');
          return parts.length > 1 ? parts[1] : e;
        })
        .toList();
  }
}

@HiveType(typeId: 5)
class Episode extends HiveObject {
  @HiveField(0)
  String? source;

  @HiveField(1)
  String? url;

  Episode({this.source, this.url});
}

@HiveType(typeId: 6)
class LiveChannel extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String? logo;

  @HiveField(2)
  String? urls;

  LiveChannel({this.name, this.logo, this.urls});

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    return LiveChannel(
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      urls: json['urls'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'logo': logo,
        'urls': urls,
      };

  List<String> get playUrls {
    if (urls == null || urls!.isEmpty) return [];
    return urls!.split(',');
  }
}
