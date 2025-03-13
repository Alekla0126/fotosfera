class ImageEntity {
  ImageEntity({
    required this.id,
    required this.description,
    required this.variants,
  });
  final String id;
  final String description;
  // Each image can have several variants with different sizes/urls
  final List<ImageVariantEntity> variants;
}

class ImageVariantEntity {
  ImageVariantEntity({
    required this.width,
    required this.height,
    required this.url,
  });
  final int width;
  final int height;
  final String url;
}
