enum ShopItemType { customization, powerUp, mallet }

class ShopItem {
  final String id;
  final String name;
  final int price;
  final String iconEmoji;
  final ShopItemType type;
  final String? description;
  final String? imagePath; // NEW: Path to skin image
  bool isUnlocked;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.iconEmoji,
    required this.type,
    this.description,
    this.imagePath, // NEW: Optional image path for skins
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'iconEmoji': iconEmoji,
      'type': type.toString(),
      'description': description,
      'imagePath': imagePath,
      'isUnlocked': isUnlocked,
    };
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      iconEmoji: json['iconEmoji'],
      type: json['type'] == 'ShopItemType.customization' 
          ? ShopItemType.customization 
          : json['type'] == 'ShopItemType.mallet'
              ? ShopItemType.mallet
              : ShopItemType.powerUp,
      description: json['description'],
      imagePath: json['imagePath'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}