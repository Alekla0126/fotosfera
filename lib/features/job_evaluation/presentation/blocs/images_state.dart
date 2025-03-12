part of 'images_bloc.dart';

enum ImagesStatus { initial, loading, loaded, loadingMore, error }

class ImagesState extends Equatable {
  const ImagesState({
    required this.images,
    required this.status,
    this.continuationToken,
    this.errorMessage,
  });

  factory ImagesState.initial() {
    return const ImagesState(
      images: [],
      status: ImagesStatus.initial,
    );
  }

  final List<ImageEntity> images;
  final ImagesStatus status;
  final String? continuationToken;
  final String? errorMessage;

  ImagesState copyWith({
    List<ImageEntity>? images,
    ImagesStatus? status,
    String? continuationToken,
    String? errorMessage,
  }) {
    return ImagesState(
      images: images ?? this.images,
      status: status ?? this.status,
      continuationToken: continuationToken,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [images, status, continuationToken, errorMessage];
}