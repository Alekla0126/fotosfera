// lib/features/job_evaluation/domain/usecases/fetch_images_usecase.dart
import 'package:fotosfera/features/job_evaluation/domain/entities/image_repository.dart';
import '../entities/image_entity.dart';

class FetchImagesUseCase {
  final IImageRepository repository;

  FetchImagesUseCase(this.repository);

  Future<(List<ImageEntity>, String?)> call({String? continuationToken}) {
    return repository.fetchImages(continuationToken: continuationToken);
  }
}