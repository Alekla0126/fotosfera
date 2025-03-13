import 'package:dio/dio.dart';
import 'package:fotosfera/core/utils/logger.dart';
import 'package:fotosfera/features/job_evaluation/data/models/image_model.dart';

abstract class IRemoteDataSource {
  Future<(List<ImageModel>, String?)> fetchImages({String? continuationToken});
}

class RemoteDataSourceImpl implements IRemoteDataSource {
  // or final http.Client _client

  RemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<(List<ImageModel>, String?)> fetchImages({
    String? continuationToken,
  }) async {
    try {
      AppLogger.debug('Fetching images... Sending token: $continuationToken');

      final queryParameters = <String, dynamic>{};
      if (continuationToken != null) {
        queryParameters['continuationToken'] = continuationToken;
      }

      final response = await _dio.get(
        'https://ru.api.dev.photograf.io/v1/jobEvaluation/images',
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>? ?? {};

      final itemsJson = result['items'] as List<dynamic>? ?? [];
      final token =
          result['continuationToken'] as String?; // Update token from response

      final images = itemsJson
          .map((json) => ImageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.debug('Received ${images.length} images. New token: $token');

      return (images, token); // Return updated token
    } on DioException catch (e, stackTrace) {
      AppLogger.error('API Request Failed', e, stackTrace);
      rethrow;
    }
  }
}
