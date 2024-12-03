import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';

class ProductGetInfoAI extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const ProductGetInfoAI(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  ConsumerState<ProductGetInfoAI> createState() => _ProductGetInfoAIState();
}

class _ProductGetInfoAIState extends ConsumerState<ProductGetInfoAI> {
  
  final _mobileFormKey = GlobalKey<FormState>();
  final _tabletFormKey = GlobalKey<FormState>();
  final _chargerFormKey = GlobalKey<FormState>();
  final _remainingKey = GlobalKey<FormState>();
  
  final _brandController = TextEditingController();
  final _adTitleController = TextEditingController();
  final _adDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandFocus = FocusNode();
  final _adTitleFocus = FocusNode();
  final _adDescriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final List<String> _tabletBrands = ['iPad', 'Samsung', 'Other Tablets'];
  final List<String> chargers = ['Mobile', 'Tablet', 'Smart Watch', 'Speakers'];
  late AuthHandler authHandler;

  void unfocusFields() {
    _brandFocus.unfocus();
    _adTitleFocus.unfocus();
    _adDescriptionFocus.unfocus();
    _priceFocus.unfocus();
  }

   @override
  void initState() {
    authHandler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _brandFocus.dispose();
    _adTitleController.dispose();
    _adTitleFocus.dispose();
    _adDescriptionController.dispose();
    _adDescriptionFocus.dispose();
    _priceController.dispose();
    _priceFocus.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
