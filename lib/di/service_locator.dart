// lib/di/service_locator.dart
import 'package:dio/dio.dart';
import 'package:fotosfera/features/job_evaluation/data/datasources/remote_data_source.dart';
import 'package:fotosfera/features/job_evaluation/data/repositories/image_repository_impl.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_repository.dart';
import 'package:fotosfera/features/job_evaluation/domain/usecases/fetch_images_usecase.dart';
import 'package:fotosfera/features/job_evaluation/presentation/blocs/images_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Logging
  getIt.registerLazySingleton<Logger>(() => Logger());

  // Dio
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Data Source
  getIt.registerLazySingleton<IRemoteDataSource>(
    () => RemoteDataSourceImpl(getIt<Dio>()),
  );

  // Repository
  getIt.registerLazySingleton<IImageRepository>(
    () => ImageRepositoryImpl(getIt<IRemoteDataSource>()),
  );

  // UseCase
  getIt.registerFactory(() => FetchImagesUseCase(getIt<IImageRepository>()));

  // BLoC
  getIt.registerFactory(
    () => ImagesBloc(
      getIt<FetchImagesUseCase>(),
    ),
  );
}
