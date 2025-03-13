import 'package:fotosfera/features/job_evaluation/data/datasources/remote_data_source.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_entity.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_repository.dart';

class ImageRepositoryImpl implements IImageRepository {
  ImageRepositoryImpl(this.remoteDataSource);
  final IRemoteDataSource remoteDataSource;

  @override
  Future<(List<ImageEntity>, String?)> fetchImages({
    String? continuationToken,
  }) async {
    final (models, token) = await remoteDataSource.fetchImages(
      continuationToken: continuationToken,
    );
    return (models.map((m) => m.toEntity()).toList(), token);
  }
}
