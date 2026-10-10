import 'package:flutter_ecommerce_app/src/model/category.dart';
import 'package:flutter_ecommerce_app/src/model/product.dart';

class AppData {
  static final List<Product> productList = [
    Product(
      id: 1,
      name: 'Air Max 200',
      price: 120,
      isSelected: true,
      isliked: false,
      image: 'assets/shooe_tilt_1.png',
      category: 'Sneakers',
    ),
    Product(
      id: 2,
      name: 'Air Max 97',
      price: 145,
      isliked: false,
      image: 'assets/shoe_tilt_2.png',
      category: 'Sneakers',
    ),
    Product(
      id: 3,
      name: 'Air Runner Classic',
      price: 98,
      isliked: false,
      image: 'assets/show_1.png',
      category: 'Sneakers',
    ),
    Product(
      id: 4,
      name: 'Everyday Puffer',
      price: 165,
      isliked: false,
      image: 'assets/jacket.png',
      category: 'Jackets',
    ),
    Product(
      id: 5,
      name: 'Minimal Field Watch',
      price: 189,
      isliked: false,
      image: 'assets/watch.png',
      category: 'Watches',
    ),
    Product(
      id: 6,
      name: 'Air Max Studio',
      price: 132,
      isliked: false,
      image: 'assets/small_tilt_shoe_1.png',
      category: 'Sneakers',
    ),
    Product(
      id: 7,
      name: 'City Move Runner',
      price: 110,
      isliked: false,
      image: 'assets/small_tilt_shoe_2.png',
      category: 'Sneakers',
    ),
    Product(
      id: 8,
      name: 'Weekend Runner',
      price: 125,
      isliked: false,
      image: 'assets/small_tilt_shoe_3.png',
      category: 'Sneakers',
    ),
    Product(
      id: 9,
      name: 'Cloudwalk Everyday',
      price: 118,
      image: 'assets/shoe_thumb_1.png',
      category: 'Sneakers',
    ),
    Product(
      id: 10,
      name: 'Studio Court Low',
      price: 106,
      image: 'assets/shoe_thumb_2.png',
      category: 'Sneakers',
    ),
    Product(
      id: 11,
      name: 'Trail Form Runner',
      price: 154,
      image: 'assets/shoe_thumb_3.png',
      category: 'Sneakers',
    ),
    Product(
      id: 12,
      name: 'Retro Pace 90',
      price: 139,
      image: 'assets/shoe_thumb_4.png',
      category: 'Sneakers',
    ),
    Product(
      id: 13,
      name: 'Everyday Puffer Vest',
      price: 145,
      image: 'assets/jacket.png',
      category: 'Jackets',
    ),
    Product(
      id: 14,
      name: 'Field Notes Chronograph',
      price: 215,
      image: 'assets/watch.png',
      category: 'Watches',
    ),
    Product(
      id: 15,
      name: 'Classic Court Essential',
      price: 94,
      image: 'assets/shoe_thumb_5.png',
      category: 'Sneakers',
    ),
    Product(
      id: 16,
      name: 'Weekend Hiker',
      price: 172,
      image: 'assets/small_tilt_shoe_1.png',
      category: 'Sneakers',
    ),
  ];

  static List<Product> get cartList => productList
      .where((product) => product.isSelected)
      .toList(growable: false);
  static List<Category> categoryList = [
    Category(),
    Category(
      id: 1,
      name: "Sneakers",
      image: 'assets/shoe_thumb_2.png',
      isSelected: true,
    ),
    Category(id: 2, name: "Jacket", image: 'assets/jacket.png'),
    Category(id: 3, name: "Watch", image: 'assets/watch.png'),
    Category(id: 4, name: "Watch", image: 'assets/watch.png'),
  ];
  static List<String> showThumbnailList = [
    "assets/shoe_thumb_5.png",
    "assets/shoe_thumb_1.png",
    "assets/shoe_thumb_4.png",
    "assets/shoe_thumb_3.png",
  ];
  static String description =
      "Clean lines, versatile and timeless—the people shoe returns with the Nike Air Max 90. Featuring the same iconic Waffle sole, stitched overlays and classic TPU accents you come to love, it lets you walk among the pantheon of Air. ßNothing as fly, nothing as comfortable, nothing as proven. The Nike Air Max 90 stays true to its OG running roots with the iconic Waffle sole, stitched overlays and classic TPU details. Classic colours celebrate your fresh look while Max Air cushioning adds comfort to the journey.";
}
