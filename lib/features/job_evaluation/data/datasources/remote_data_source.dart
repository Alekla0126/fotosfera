import '../models/image_model.dart';
import 'package:dio/dio.dart';

abstract class IRemoteDataSource {
  Future<(List<ImageModel>, String?)> fetchImages({String? continuationToken});
}

class RemoteDataSourceImpl implements IRemoteDataSource { // or final http.Client _client

  RemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<(List<ImageModel>, String?)> fetchImages(
      {String? continuationToken,}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (continuationToken != null) {
        queryParameters['continuationToken'] = continuationToken;
      }

      final response = await _dio.get(
        'https://ru.api.dev.photograf.io/v1/jobEvaluation/images',
        queryParameters: queryParameters,
      );

      // The actual JSON:
      // {
      //   "ok": true,
      //   "result": {
      //     "items": [...],
      //     "continuationToken": "FAAAAKOgOBc..."
      //   }
      // }

      final data = response.data as Map<String, dynamic>;
      // null-safely read "result"
      final result = data['result'] as Map<String, dynamic>? ?? {};

      // "items" is the array of images
      final itemsJson = result['items'] as List<dynamic>? ?? [];
      final token = result['continuationToken'] as String?;

      final images = itemsJson
          .map((json) => ImageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return (images, token);
    } on DioException {
      rethrow;
    }
  }
}
