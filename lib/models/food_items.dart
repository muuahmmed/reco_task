// food_item_model.dart
class FoodItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;

  FoodItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

// Optionally add fromMap/toMap methods if using Firestore
}