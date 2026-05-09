// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_source.dart';

class VideoSourceAdapter extends TypeAdapter<VideoSource> {
  @override
  final int typeId = 0;

  @override
  VideoSource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoSource(
      key: fields[0] as String?,
      name: fields[1] as String?,
      api: fields[2] as String?,
      type: fields[3] as int?,
      spider: fields[4] as String?,
      searchable: fields[5] as int?,
      changeable: fields[6] as int?,
      quicksearch: fields[7] as int?,
      filter: fields[8] as int?,
      enabled: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoSource obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.api)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.spider)
      ..writeByte(5)
      ..write(obj.searchable)
      ..writeByte(6)
      ..write(obj.changeable)
      ..writeByte(7)
      ..write(obj.quicksearch)
      ..writeByte(8)
      ..write(obj.filter)
      ..writeByte(9)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      typeId: fields[0] as String?,
      typeName: fields[1] as String?,
      typeFlag: fields[2] as String?,
      logo: fields[3] as String?,
      extends_: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.typeId)
      ..writeByte(1)
      ..write(obj.typeName)
      ..writeByte(2)
      ..write(obj.typeFlag)
      ..writeByte(3)
      ..write(obj.logo)
      ..writeByte(4)
      ..write(obj.extends_);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FilterAdapter extends TypeAdapter<Filter> {
  @override
  final int typeId = 2;

  @override
  Filter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Filter(
      key: fields[0] as String?,
      name: fields[1] as String?,
      values: (fields[2] as List?)?.cast<FilterValue>(),
    );
  }

  @override
  void write(BinaryWriter writer, Filter obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.values);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FilterValueAdapter extends TypeAdapter<FilterValue> {
  @override
  final int typeId = 3;

  @override
  FilterValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FilterValue(
      n: fields[0] as String?,
      v: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FilterValue obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.n)
      ..writeByte(1)
      ..write(obj.v);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 4;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      vodId: fields[0] as String?,
      vodName: fields[1] as String?,
      vodPic: fields[2] as String?,
      vodRemarks: fields[3] as String?,
      vodYear: fields[4] as String?,
      vodArea: fields[5] as String?,
      vodLang: fields[6] as String?,
      vodType: fields[7] as String?,
      vodTag: fields[8] as String?,
      vodDirector: fields[9] as String?,
      vodActor: fields[10] as String?,
      vodContent: fields[11] as String?,
      vodPlayFrom: fields[12] as String?,
      vodPlayUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.vodId)
      ..writeByte(1)
      ..write(obj.vodName)
      ..writeByte(2)
      ..write(obj.vodPic)
      ..writeByte(3)
      ..write(obj.vodRemarks)
      ..writeByte(4)
      ..write(obj.vodYear)
      ..writeByte(5)
      ..write(obj.vodArea)
      ..writeByte(6)
      ..write(obj.vodLang)
      ..writeByte(7)
      ..write(obj.vodType)
      ..writeByte(8)
      ..write(obj.vodTag)
      ..writeByte(9)
      ..write(obj.vodDirector)
      ..writeByte(10)
      ..write(obj.vodActor)
      ..writeByte(11)
      ..write(obj.vodContent)
      ..writeByte(12)
      ..write(obj.vodPlayFrom)
      ..writeByte(13)
      ..write(obj.vodPlayUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 5;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      source: fields[0] as String?,
      url: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.source)
      ..writeByte(1)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LiveChannelAdapter extends TypeAdapter<LiveChannel> {
  @override
  final int typeId = 6;

  @override
  LiveChannel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LiveChannel(
      name: fields[0] as String?,
      logo: fields[1] as String?,
      urls: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LiveChannel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.logo)
      ..writeByte(2)
      ..write(obj.urls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
