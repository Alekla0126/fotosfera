import '../entities/image_entity.dart';
import '../entities/image_repository.dart';

class FetchImagesUseCase {
  FetchImagesUseCase(this._repository);
  final IImageRepository _repository;

  Future<(List<ImageEntity>, String?)> call({String? continuationToken}) {
    return _repository.fetchImages(continuationToken: continuationToken);
  }
}
