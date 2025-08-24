// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
      id: (json['id'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      caption: json['caption'] as String?,
      createdAt: json['createdAt'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : UserDto.fromJson(json['user'] as Map<String, dynamic>),
      likesCount: (json['likesCount'] as num?)?.toInt(),
      isLikedByUser: json['isLikedByUser'] as bool?,
      location: json['location'] == null
          ? null
          : LocationDto.fromJson(json['location'] as Map<String, dynamic>),
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PostDtoToJson(PostDto instance) => <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'caption': instance.caption,
      'createdAt': instance.createdAt,
      'userId': instance.userId,
      'user': instance.user,
      'likesCount': instance.likesCount,
      'isLikedByUser': instance.isLikedByUser,
      'location': instance.location,
      'comments': instance.comments,
    };
