import 'package:fotosfera/features/job_evaluation/domain/usecases/fetch_images_usecase.dart';
import 'package:fotosfera/core/utils/logger.dart';
import '../../domain/entities/image_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part 'images_event.dart';
part 'images_state.dart';

/// BLoC for fetching and paging images
class ImagesBloc extends Bloc<ImagesEvent, ImagesState> {
  /// The use case that fetches images from the repository
  final FetchImagesUseCase _fetchImagesUseCase;

  /// Creates an [ImagesBloc] using the provided [_fetchImagesUseCase].
  ImagesBloc(FetchImagesUseCase fetchImagesUseCase)
      : _fetchImagesUseCase = fetchImagesUseCase,
        super(ImagesState.initial()) {
    on<LoadImages>(_onLoadImages);
    on<LoadMoreImages>(_onLoadMoreImages);
  }

  Future<void> _onLoadImages(
    LoadImages event,
    Emitter<ImagesState> emit,
  ) async {
    emit(state.copyWith(status: ImagesStatus.loading));

    try {
      final (images, token) = await _fetchImagesUseCase();
      emit(
        state.copyWith(
          images: images,
          continuationToken: token,
          status: ImagesStatus.loaded,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
          status: ImagesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreImages(
    LoadMoreImages event,
    Emitter<ImagesState> emit,
  ) async {
    if (state.continuationToken == null ||
        state.status == ImagesStatus.loadingMore) {
      AppLogger.debug(
          "No more images to load. Current token: ${state.continuationToken}");
      return;
    }

    AppLogger.debug(
        "Loading more images... Current token: ${state.continuationToken}");

    emit(state.copyWith(status: ImagesStatus.loadingMore));

    try {
      final (newImages, newToken) = await _fetchImagesUseCase(
        continuationToken: state.continuationToken, // Pass the latest token
      );

      final updatedList = List<ImageEntity>.from(state.images)
        ..addAll(newImages);

      AppLogger.debug(
          "Loaded ${newImages.length} new images. New token: $newToken");

      emit(
        state.copyWith(
          images: updatedList, // Append new images
          continuationToken: newToken, // Update token for the next request
          status: ImagesStatus.loaded,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error("Failed to load more images", e, stackTrace);
      emit(
        state.copyWith(
          status: ImagesStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
