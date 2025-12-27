import 'dart:io';

import 'package:dio/dio.dart';

class CreatePostDto {
  final File imageFile;
  final String caption;
  final List<String> hashtags;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? angle;

  CreatePostDto({
    required this.imageFile,
    required this.caption,
    required this.hashtags,
    this.latitude,
    this.longitude,
    this.altitude,
    this.angle,
  });

  Map<String, dynamic> toJson() => {
    'Caption': caption,
    'Hashtags': hashtags,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (altitude != null) 'altitude': altitude,
    if (angle != null) 'angle': angle,
  };

  // Method to convert File to MultipartFile for Dio
  Future<MultipartFile> getImageMultipart() async {
    return await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
    );
  }
}