import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandFilter extends StateNotifier<List<String>> {
  BrandFilter()
      : super([
          'iPhone',
          'Samsung',
          'OnePlus',
          'Motorola',
          'iQOO',
          'Mi',
          'Vivo',
          'Oppo',
          'Realme',
          'Asus',
          'Google Pixel',
          'Honor',
          'Infinix',
          'Intex',
          'Lenovo',
          'LG',
          'Nokia',
          'Poco',
          'Redmi',
          'others'
        ]);

  void filterByBrand(String brand) {
    if (brand == '') {
      state = [
        'iPhone',
        'Samsung',
        'OnePlus',
        'Motorola',
        'iQOO',
        'Mi',
        'Vivo',
        'Oppo',
        'Realme',
        'Asus',
        'Google Pixel',
        'Honor',
        'Infinix',
        'Intex',
        'Lenovo',
        'LG',
        'Nokia',
        'Poco',
        'Redmi',
      ];
    } else {
      state = [
        'iPhone',
        'Samsung',
        'OnePlus',
        'Motorola',
        'iQOO',
        'Mi',
        'Vivo',
        'Oppo',
        'Realme',
        'Asus',
        'Google Pixel',
        'Honor',
        'Infinix',
        'Intex',
        'Lenovo',
        'LG',
        'Nokia',
        'Poco',
        'Redmi',
      ].where((element) {
        return element.toLowerCase().contains(brand.toLowerCase());
      }).toList();
    }
  }
}

final brandFilterProvider = StateNotifierProvider<BrandFilter, List<String>>(
  (_) => BrandFilter(),
);
