import 'dart:ui' as ui show Image;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  static const String baseUrl = '';

  /// 取得圖片壓縮比例
  static double getImageCompressRatio(ui.Image image, [double maxSize = 1920]) {
    final height = image.height;
    final width = image.width;

    // 若長寬皆 <= maxSize，維持原比例
    if (maxSize > height && maxSize > width) {
      return 1;
    }

    // 高度 >= 寬度，以高度計算
    if (height >= width) {
      return height / maxSize;
    }

    return width / maxSize;
  }
}

Widget generaterImageWidget(url, double width, double height) {
  return p.extension(url).toLowerCase() == '.svg'
      ? SizedBox(
          width: width,
          height: height,
          child: SvgPicture.network(url),
        )
      : cachedNetworkImage(url, width: width, height: height);
}

Widget cachedNetworkImage(
  String url, {
  double? width,
  double? height,
  BoxFit? fit,
  Widget? errorWidget,
}) {
  return CachedNetworkImage(
    width: width,
    height: height,
    fit: fit,
    imageUrl: url,
    //placeholder: (context, url) => const CircularProgressIndicator(),
    errorWidget: (context, url, error) =>
        errorWidget ?? const Icon(Icons.error),
  );
}
