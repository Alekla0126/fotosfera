import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotosfera/core/utils/logger.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_entity.dart';
import 'package:fotosfera/features/job_evaluation/presentation/blocs/images_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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
    final bloc = context.read<ImagesBloc>();

    if (bloc.state.images.isEmpty) {
      bloc.add(LoadImages());
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bloc = context.read<ImagesBloc>();

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        bloc.state.status != ImagesStatus.loadingMore &&
        bloc.state.continuationToken != null) {
      AppLogger.debug(
        'Loading more images with token: ${bloc.state.continuationToken}',
      );
      bloc.add(LoadMoreImages());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: BlocBuilder<ImagesBloc, ImagesState>(
        builder: (context, state) {
          if (state.status == ImagesStatus.loading && state.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ImagesStatus.error &&
              state.images.isEmpty &&
              state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }

          final images = state.images;
          return LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 3;
              const spacing = 8.0;
              final containerSize =
                  (constraints.maxWidth - ((crossAxisCount - 1) * spacing)) /
                      crossAxisCount;

              return GridView.builder(
                key: const PageStorageKey<String>(
                  'imagesGrid',
                ), // 🔥 Keeps scroll position alive
                controller: _scrollController,
                itemCount: images.length,
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemBuilder: (context, index) {
                  final image = images[index];

                  final variant = _getOptimalImageVariant(
                    image.variants,
                    desiredWidth: containerSize.toInt(),
                    desiredHeight: containerSize.toInt(),
                  );

                  return GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push('/detail/${image.id}');
                    },
                    child: CachedNetworkImage(
                      imageUrl: variant.url,
                      cacheKey: image.id,
                      placeholder: (ctx, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (ctx, url, error) => const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Selects the optimal image variant based on display size.
  ImageVariantEntity _getOptimalImageVariant(
    List<ImageVariantEntity> variants, {
    required int desiredWidth,
    required int desiredHeight,
  }) {
    final sorted = variants.toList()
      ..sort((a, b) => (a.width * a.height).compareTo(b.width * b.height));

    final bigger = sorted
        .where((v) => v.width >= desiredWidth && v.height >= desiredHeight);
    return bigger.isNotEmpty ? bigger.first : sorted.last;
  }
}
