class ProductModel {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;
  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }
}
