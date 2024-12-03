import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final Timestamp timestamp;
  final String userid;
  final String id;
  final String adTitle;
  final String adDescription;
  final double price;
  final List<String> images;
  final String postedBy;
  final String categoryName;
  final String subCategoryName;
  final String brand;
  final String chargerType;
  final String tabletType;
  final DocumentSnapshot documentSnapshot;
  final DocumentReference<Map<String, dynamic>> documentReference;
  final bool isAvailable;
  const Item({
    required this.timestamp,
    required this.isAvailable,
    required this.documentReference,
    required this.documentSnapshot,
    required this.chargerType,
    required this.tabletType,
    required this.brand,
    required this.userid,
    required this.id,
    required this.adTitle,
    required this.adDescription,
    required this.price,
    required this.images,
    required this.postedBy,
    required this.categoryName,
    required this.subCategoryName,
  });

  static List<String> getImages(List<dynamic> images) {
    List<String> imageList = [];
    for (final image in images) {
      imageList.add(image);
    }
    return imageList;
  }

  factory Item.fromJson(
      Map<String, dynamic> json,
      DocumentSnapshot doc,
      DocumentReference<Map<String, dynamic>> reference) {
    return Item(
        timestamp: json['createdAt'],
        documentReference: reference,
        id: json['id'],
        userid: json['userId'],
        adTitle: json['adTitle'],
        adDescription: json['adDescription'],
        price: json['price'],
        images: getImages(json['images']),
        postedBy: json['postedBy'],
        categoryName: json['categoryName'],
        subCategoryName: json['subCategoryName'],
        brand: json['brand'],
        documentSnapshot: doc,
        chargerType: json['charger_type'],
        tabletType: json['tablet_type'],
        isAvailable: json['isAvailable']);
  }

  Map<String, dynamic> toJson() {
    return {
      'adTitle': adTitle,
      'adDescription': adDescription,
      'price': price,
      'images': images,
      'postedBy': postedBy,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'userId': userid,
      'brand': brand,
      'charger_type': chargerType,
      'tablet_type': tabletType,
      'isAvailable': isAvailable,
    };
  }

  Item copyWith({
    String? userid,
    String? id,
    String? adTitle,
    String? adDescription,
    String? createdAt,
    double? price,
    List<String>? images,
    String? postedBy,
    String? categoryName,
    String? subCategoryName,
    String? brand,
    String? chargerType,
    String? tabletType,
    DocumentSnapshot? documentSnapshot,
    DocumentReference<Map<String, dynamic>>? documentReference,
    bool? isAvailable,
  }) {
    return Item(
      userid: userid ?? this.userid,
      id: id ?? this.id,
      adTitle: adTitle ?? this.adTitle,
      adDescription: adDescription ?? this.adDescription,
      price: price ?? this.price,
      images: images ?? this.images,
      postedBy: postedBy ?? this.postedBy,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      brand: brand ?? this.brand,
      chargerType: chargerType ?? this.chargerType,
      tabletType: tabletType ?? this.tabletType,
      documentSnapshot: documentSnapshot ?? this.documentSnapshot,
      documentReference: documentReference ?? this.documentReference,
      isAvailable: isAvailable ?? this.isAvailable, 
      timestamp: timestamp,
    );
  }
}
