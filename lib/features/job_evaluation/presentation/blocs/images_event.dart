part of 'images_bloc.dart';

abstract class ImagesEvent extends Equatable {
  const ImagesEvent();

  @override
  List<Object?> get props => [];
}

class LoadImages extends ImagesEvent {}

class LoadMoreImages extends ImagesEvent {}