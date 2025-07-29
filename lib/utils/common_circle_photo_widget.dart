import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommonCirclePhotoWidget extends StatelessWidget {
  final String url;
  final double borderRadius;
  final double imageSize;
  const CommonCirclePhotoWidget(
      {super.key,
        required this.url,
        this.borderRadius = 100,
        this.imageSize = 40});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? Image.network(
        "https://c1.35photo.pro/profile/photos/192/963119_140.jpg",
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
      )
          : CachedNetworkImage(
        imageUrl: url,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        placeholder: (context, url) => Image.asset(
          "https://c1.35photo.pro/profile/photos/192/963119_140.jpg",
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          "https://c1.35photo.pro/profile/photos/192/963119_140.jpg",
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
