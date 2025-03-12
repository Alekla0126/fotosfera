import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fotosfera/features/job_evaluation/domain/usecases/fetch_images_usecase.dart';
import '../../domain/entities/image_entity.dart';

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
      emit(state.copyWith(status: ImagesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadMoreImages(
    LoadMoreImages event,
    Emitter<ImagesState> emit,
  ) async {
    // If no continuationToken or already loadingMore, do nothing
    if (state.continuationToken == null ||
        state.status == ImagesStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: ImagesStatus.loadingMore));
    try {
      // Correctly call `_fetchImagesUseCase` with the named parameter
      final (newImages, newToken) = await _fetchImagesUseCase(
        continuationToken: state.continuationToken,
      );

      final updatedList = List<ImageEntity>.from(state.images)..addAll(newImages);
      emit(
        state.copyWith(
          images: updatedList,
          continuationToken: newToken,
          status: ImagesStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ImagesStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}