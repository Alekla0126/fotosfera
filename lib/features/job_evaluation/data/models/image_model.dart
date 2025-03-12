import '../../domain/entities/image_entity.dart';

class ImageModel {

  ImageModel({
    required this.id,
    required this.description,
    required this.variants,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as String,
      // If no "description" field, fallback to empty string
      description: json['description'] as String? ?? '',
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((v) => ImageVariantModel.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
  final String id;
  final String description;
  final List<ImageVariantModel> variants;

  // Convert model to entity
  ImageEntity toEntity() {
    return ImageEntity(
      id: id,
      description: description,
      variants: variants.map((v) => v.toEntity()).toList(),
    );
  }
}

class ImageVariantModel {

  ImageVariantModel({
    required this.width,
    required this.height,
    required this.url,
  });

  factory ImageVariantModel.fromJson(Map<String, dynamic> json) {
    return ImageVariantModel(
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String,
    );
  }
  final int width;
  final int height;
  final String url;

  ImageVariantEntity toEntity() {
    return ImageVariantEntity(
      width: width,
      height: height,
      url: url,
    );
  }
}
