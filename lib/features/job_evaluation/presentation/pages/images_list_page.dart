import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/image_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../blocs/images_bloc.dart';

class ImagesListPage extends StatefulWidget {
  const ImagesListPage({super.key});

  @override
  State<ImagesListPage> createState() => _ImagesListPageState();
}

class _ImagesListPageState extends State<ImagesListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Start by loading the initial images
    context.read<ImagesBloc>().add(LoadImages());

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom => try to load more
      context.read<ImagesBloc>().add(LoadMoreImages());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
      ),
      body: BlocBuilder<ImagesBloc, ImagesState>(
        builder: (context, state) {
          if (state.status == ImagesStatus.loading && state.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ImagesStatus.error && state.images.isEmpty && state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          final images = state.images;
          return Stack(
            children: [
              GridView.builder(
                controller: _scrollController,
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  final image = images[index];
                  // Determine optimal variant for the given item size
                  // For simplicity, let's assume 120x120 is the approximate size of a grid item
                  final variant = _getOptimalImageVariant(
                    image.variants, 
                    desiredWidth: 120, 
                    desiredHeight: 120,
                  );
                  return GestureDetector(
                    onTap: () {
                      // Navigate to detail screen
                      GoRouter.of(context).go('/detail/${image.id}'); 
                    },
                    child: CachedNetworkImage(
                      imageUrl: variant.url,
                      placeholder: (ctx, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (ctx, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              if (state.status == ImagesStatus.loadingMore)
                const Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // Requirement #3:
  // “Оптимальным вариантом понимается минимальный по размеру вариант изображения,
  // больший отображаемого на экране размера. Если нет такого, то берем максимальный.”
  ImageVariantEntity _getOptimalImageVariant(
    List<ImageVariantEntity> variants, {
    required int desiredWidth,
    required int desiredHeight,
  }) {
    // Sort by area or dimension
    final sorted = variants.toList()
      ..sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));

    // 1) minimal bigger than desired
    final bigger = sorted.where((v) => v.width >= desiredWidth && v.height >= desiredHeight);
    if (bigger.isNotEmpty) {
      return bigger.first; // The smallest from bigger ones
    } else {
      // 2) if none is bigger, get the largest
      return sorted.last;
    }
  }
}