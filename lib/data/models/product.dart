import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int? id;
  final String name;
  final int categoryId;
  final double price;
  final String? imageIcon;
  final String? imagePath;
  final bool isAvailable;
  final int? stock;

  const Product({
    this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.imageIcon,
    this.imagePath,
    this.isAvailable = true,
    this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryId: map['category_id'] as int,
      price: (map['price'] as num).toDouble(),
      imageIcon: map['image_icon'] as String?,
      imagePath: map['image_path'] as String?,
      isAvailable: (map['is_available'] as int? ?? 1) == 1,
      stock: map['stock'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'category_id': categoryId,
      'price': price,
      'image_icon': imageIcon,
      'image_path': imagePath,
      'is_available': isAvailable ? 1 : 0,
      'stock': stock,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Product copyWith({
    int? id,
    String? name,
    int? categoryId,
    double? price,
    String? imageIcon,
    String? imagePath,
    bool? isAvailable,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      imageIcon: imageIcon ?? this.imageIcon,
      imagePath: imagePath ?? this.imagePath,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
    );
  }

  @override
  List<Object?> get props => [id, name, categoryId, price, imageIcon, imagePath, isAvailable, stock];
}

