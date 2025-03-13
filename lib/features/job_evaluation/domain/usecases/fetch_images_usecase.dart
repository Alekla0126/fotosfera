// lib/features/job_evaluation/domain/usecases/fetch_images_usecase.dart
import 'package:fotosfera/features/job_evaluation/domain/entities/image_entity.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_repository.dart';

class FetchImagesUseCase {
  FetchImagesUseCase(this.repository);
  final IImageRepository repository;

  Future<(List<ImageEntity>, String?)> call({String? continuationToken}) {
    return repository.fetchImages(continuationToken: continuationToken);
  }
}
