class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String price;
  final String material;
  final String careInstructions;
  final List<String> galleryImages;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.material,
    required this.careInstructions,
    required this.galleryImages,
  });
}

class Collection {
  final String id;
  final String name;
  final String description;
  final String coverImage;
  final List<Product> products;

  Collection({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.products,
  });
}

class GalleryItem {
  final String id;
  final String imageUrl;
  final String title;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.title,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      title: json['title'] ?? '',
    );
  }
}

class BrandInfo {
  final String name;
  final String tagline;
  final String story;
  final String mission;
  final String vision;
  final String founderNote;
  final String founderName;
  final String instagramHandle;
  final String whatsappNumber;
  final String email;

  BrandInfo({
    required this.name,
    required this.tagline,
    required this.story,
    required this.mission,
    required this.vision,
    required this.founderNote,
    required this.founderName,
    required this.instagramHandle,
    required this.whatsappNumber,
    required this.email,
  });

  factory BrandInfo.fromJson(Map<String, dynamic> json) {
    return BrandInfo(
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      story: json['story'] ?? '',
      mission: json['mission'] ?? '',
      vision: json['vision'] ?? '',
      founderNote: json['founder_note'] ?? '',
      founderName: json['founder_name'] ?? '',
      instagramHandle: json['instagram_handle'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
