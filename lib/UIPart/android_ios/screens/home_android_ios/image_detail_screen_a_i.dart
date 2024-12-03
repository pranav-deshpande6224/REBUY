import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageDetailScreenAI extends StatelessWidget {
  final List<String> images;
  const ImageDetailScreenAI({required this.images, super.key});

  SafeArea displayImages() {
    return SafeArea(
      child: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(),
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            heroAttributes: PhotoViewHeroAttributes(
              tag: images[index],
            ),
          );
        },
        loadingBuilder: (context, event) {
          return Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator(
                    color: Colors.blue,
                  )
                : Platform.isIOS
                    ? const CupertinoActivityIndicator()
                    : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          elevation: 10,
        ),
        body: displayImages(),
      );
    }
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: displayImages(),
      );
    }
    return const SizedBox();
  }
}
