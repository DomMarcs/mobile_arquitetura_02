class Product {
  final int? id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  const Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int?,
      name: (json['title'] ?? json['name'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image'] ?? json['thumbnail'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': name,
      'price': price,
      'description': description,
      'image': imageUrl,
      'category': category,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? description,
    String? imageUrl,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
