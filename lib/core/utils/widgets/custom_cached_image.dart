import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_m_app/core/utils/theme/app_images.dart';
import '../theme/app_color.dart';
import 'cached_image_shimmer_loading_widget.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  final String? imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Image.asset(AppImagesPath.placeholder,fit: BoxFit.cover,width: double.infinity,height: double.infinity,);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) => const CachedImageShimmerLoadingWidget(),
      errorWidget: (context, url, error) => Image.asset(AppImagesPath.placeholder,fit: BoxFit.cover,width: double.infinity,height: double.infinity,),
    );
  }
}