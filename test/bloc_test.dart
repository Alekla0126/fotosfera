import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fotosfera/features/job_evaluation/domain/entities/image_entity.dart';
import 'package:fotosfera/features/job_evaluation/domain/usecases/fetch_images_usecase.dart';
import 'package:fotosfera/features/job_evaluation/presentation/blocs/images_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// ✅ Correctly generate a mock class for FetchImagesUseCase
@GenerateMocks([FetchImagesUseCase])
import 'bloc_test.mocks.dart';

void main() {
  group('ImagesBloc Tests', () {
    late MockFetchImagesUseCase mockUseCase;
    late ImagesBloc imagesBloc;

    setUp(() {
      mockUseCase = MockFetchImagesUseCase();
      imagesBloc = ImagesBloc(mockUseCase);
    });

    test('initial state is correct', () {
      expect(imagesBloc.state, ImagesState.initial());
    });

    blocTest<ImagesBloc, ImagesState>(
      'emits [loading, loaded] on successful LoadImages',
      build: () => imagesBloc,
      setUp: () {
        when(mockUseCase.call(continuationToken: anyNamed('continuationToken')))
            .thenAnswer((_) async => (<ImageEntity>[], 'someToken'));
      },
      act: (bloc) => bloc.add(LoadImages()),
      expect: () => [
        ImagesState.initial().copyWith(status: ImagesStatus.loading),
        ImagesState.initial().copyWith(
          status: ImagesStatus.loaded,
          continuationToken: 'someToken',
        ),
      ],
    );

    blocTest<ImagesBloc, ImagesState>(
      'emits [loading, error] on failed LoadImages',
      build: () => imagesBloc,
      setUp: () {
        // throws a real `Exception('Test exception')`
        when(mockUseCase.call(continuationToken: anyNamed('continuationToken')))
            .thenThrow(Exception('Test exception'));
      },
      act: (bloc) => bloc.add(LoadImages()),
      expect: () => [
        ImagesState.initial().copyWith(status: ImagesStatus.loading),
        ImagesState.initial().copyWith(
          status: ImagesStatus.error,
          // Instead of exact match, use `contains` to handle "Exception: Test exception"
          errorMessage: 'Exception: Test exception',
        ),
      ],
    );
  });
}
