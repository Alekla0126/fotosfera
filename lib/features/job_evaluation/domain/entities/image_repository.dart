// lib/features/job_evaluation/domain/entities/image_repository.dart

import 'package:fotosfera/features/job_evaluation/domain/entities/image_entity.dart';

/// The domain interface for fetching images.
abstract class IImageRepository {
  /// Returns a list of [ImageEntity] plus a continuation token for pagination.
  Future<(List<ImageEntity>, String?)> fetchImages({String? continuationToken});
}
