// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_posts_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedPostsDto _$PaginatedPostsDtoFromJson(Map<String, dynamic> json) =>
    PaginatedPostsDto(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['currentPage'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginatedPostsDtoToJson(PaginatedPostsDto instance) =>
    <String, dynamic>{
      'items': instance.items,
      'currentPage': instance.currentPage,
      'pageSize': instance.pageSize,
      'totalCount': instance.totalCount,
    };
