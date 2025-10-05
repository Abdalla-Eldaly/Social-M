import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/hastag.dart';

part 'hashtag_dto.g.dart';

@JsonSerializable()
class HashtagDto {
  final int id;
  final String name;
  final int postCount;

  HashtagDto({
    required this.id,
    required this.name,
    required this.postCount,
  });

  factory HashtagDto.fromJson(Map<String, dynamic> json) =>
      _$HashtagDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HashtagDtoToJson(this);

  Hashtag toDomain() {
    return Hashtag(
      id: id,
      name: name,
      postCount: postCount,
    );
  }
}