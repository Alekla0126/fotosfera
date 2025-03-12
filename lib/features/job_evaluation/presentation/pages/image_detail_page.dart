import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fotosfera/translations/locale_keys.dart';
import '../../domain/entities/image_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../blocs/images_bloc.dart';


class ImageDetailPage extends StatelessWidget {
  const ImageDetailPage({
    super.key,
    required this.imageId,
  });
  final String imageId;

  @override
  Widget build(BuildContext context) {
    final imagesBloc = context.read<ImagesBloc>();
    final image = imagesBloc.state.images.firstWhere((img) => img.id == imageId,
        orElse: () => throw Exception('Not Found'),);

    // We can get the screen size to find the best variant:
    final size = MediaQuery.of(context).size;
    final desiredWidth = size.width.toInt();
    final desiredHeight = size.height.toInt();
    final variant =
        _getOptimalImageVariant(image.variants, desiredWidth, desiredHeight);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.imageDetail.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/images'); // Fallback: go to images page
            }
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 2,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: variant.url,
            placeholder: (ctx, url) => const CircularProgressIndicator(),
            errorWidget: (ctx, url, error) => const Icon(Icons.error),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  ImageVariantEntity _getOptimalImageVariant(
    List<ImageVariantEntity> variants,
    int desiredWidth,
    int desiredHeight,
  ) {
    final sorted = variants.toList()
      ..sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));

    final bigger = sorted
        .where((v) => v.width >= desiredWidth && v.height >= desiredHeight);
    if (bigger.isNotEmpty) {
      return bigger.first;
    } else {
      return sorted.last;
    }
  }
}
