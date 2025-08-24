import 'package:json_annotation/json_annotation.dart';

import '../../../domain/entities/location.dart';

part 'location_dto.g.dart';

@JsonSerializable()
class LocationDto {
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? angle;

  LocationDto({
    this.latitude,
    this.longitude,
    this.altitude,
    this.angle,
  });

  factory LocationDto.fromJson(Map<String, dynamic> json) => _$LocationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDtoToJson(this);

  Location toDomain() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      angle: angle,
    );
  }
}