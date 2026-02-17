enum ShopItemType { customization, powerUp }

class ShopItem {
  final String id;
  final String name;
  final int price;
  final String iconEmoji;
  final ShopItemType type;
  final String? description;
  bool isUnlocked;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.iconEmoji,
    required this.type,
    this.description,
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
          : ShopItemType.powerUp,
      description: json['description'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }
}