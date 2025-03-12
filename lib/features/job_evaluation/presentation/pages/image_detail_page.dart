import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fotosfera/translations/locale_keys.dart';
import '../../domain/entities/image_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../blocs/images_bloc.dart';

class ImageDetailPage extends StatefulWidget {
  const ImageDetailPage({
    super.key,
    required this.imageId,
  });

  final String imageId;

  @override
  _ImageDetailPageState createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Smooth transition
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagesBloc = context.read<ImagesBloc>();
    final image = imagesBloc.state.images.firstWhere(
      (img) => img.id == widget.imageId,
      orElse: () => throw Exception('Not Found'),
    );

    // Get screen size to find the best variant:
    final size = MediaQuery.of(context).size;
    final desiredWidth = size.width.toInt();
    final desiredHeight = size.height.toInt();
    final variant =
        _getOptimalImageVariant(image.variants, desiredWidth, desiredHeight);

    return Scaffold(
      backgroundColor: Colors.black, // Dark background like iPhone gallery
      appBar: AppBar(
        title: Text(LocaleKeys.imageDetail.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/images'); // Fallback: go to images page
            }
          },
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: SizedBox.expand(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 1.0,
            maxScale: 5.0, // Allow up to 5x zoom like iPhone gallery
            panEnabled: true, // Enable panning
            clipBehavior: Clip.none, // Prevents cropping
            child: Container(
              color: Colors.white, // Set background to white
              child: CachedNetworkImage(
                imageUrl: variant.url,
                placeholder: (ctx, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (ctx, url, error) => const Icon(Icons.error),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles double-tap zoom-in and zoom-out with smooth animation.
  void _handleDoubleTap() {
    if (_doubleTapDetails == null) return;

    final position = _doubleTapDetails!.localPosition;
    final scaleFactor = 3.0; // Zoom to 3x

    // Reset to normal if already zoomed in
    if (_transformationController.value != Matrix4.identity()) {
      _animateReset();
    } else {
      _animateZoom(position, scaleFactor);
    }
  }

  /// Smoothly resets zoom level.
  void _animateReset() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  /// Smoothly zooms in to a tapped position.
  void _animateZoom(Offset position, double scaleFactor) {
    final x = -position.dx * (scaleFactor - 1);
    final y = -position.dy * (scaleFactor - 1);
    final zoomMatrix = Matrix4.identity()
      ..translate(x, y)
      ..scale(scaleFactor);

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: zoomMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward(from: 0);
  }

  /// Finds the best image variant for the screen size.
  ImageVariantEntity _getOptimalImageVariant(
    List<ImageVariantEntity> variants,
    int desiredWidth,
    int desiredHeight,
  ) {
    final sorted = variants.toList()
      ..sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));

    final bigger = sorted
        .where((v) => v.width >= desiredWidth && v.height >= desiredHeight);
    return bigger.isNotEmpty ? bigger.first : sorted.last;
  }
}
