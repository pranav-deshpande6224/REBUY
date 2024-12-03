import 'package:flutter/cupertino.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:resell/constants/constants.dart';

class ImageDetailScreen extends StatelessWidget {
  final List<String> imageUrl;
  const ImageDetailScreen({required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: SafeArea(
        child: PhotoViewGallery.builder(
          scrollPhysics: BouncingScrollPhysics(),
          backgroundDecoration: BoxDecoration(
            color: Constants.white,
          ),
          itemCount: imageUrl.length,
          builder: (context, index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(imageUrl[index]),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              heroAttributes: PhotoViewHeroAttributes(
                tag: imageUrl[index],
              ),
            );
          },
          loadingBuilder: (context, event) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ),
      ),
    );
  }
}
