class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String material;
  final String careInstructions;
  final List<String> galleryImages;
  final String category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt; 

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.material,
    required this.careInstructions,
    required this.galleryImages,
    required this.category,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt, 
  });

  /// 🔁 From JSON (Supabase → Flutter)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Uncategorized',
      material: json['material'] ?? '',
      careInstructions: json['care_instructions'] ?? '',
      galleryImages: List<String>.from(
          json['gallery_images'] ?? [json['image_url'] ?? '']),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  /// 🔁 To JSON (Flutter → Supabase)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'material': material,
      'care_instructions': careInstructions,
      'gallery_images': galleryImages,
      'is_active': isActive,
    };
  }

  // Optional: Add a copyWith method for easier updates
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? material,
    String? careInstructions,
    List<String>? galleryImages,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      material: material ?? this.material,
      careInstructions: careInstructions ?? this.careInstructions,
      galleryImages: galleryImages ?? this.galleryImages,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
