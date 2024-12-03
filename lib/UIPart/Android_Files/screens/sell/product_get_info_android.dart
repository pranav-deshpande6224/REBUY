import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/login_android.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/Android_Files/screens/sell/ad_uploaded_android.dart';
import 'package:resell/UIPart/Providers/brand_filter.dart';
import 'package:resell/UIPart/Providers/image_selected.dart';
import 'package:resell/UIPart/Providers/select_image.dart';
import 'package:resell/UIPart/Providers/selected_item.dart';
import 'package:resell/constants/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ProductGetInfoAndroid extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const ProductGetInfoAndroid(
      {required this.categoryName, required this.subCategoryName, super.key});

  @override
  ConsumerState<ProductGetInfoAndroid> createState() =>
      _ProductGetInfoAndroidState();
}

class _ProductGetInfoAndroidState extends ConsumerState<ProductGetInfoAndroid> {
  final _brandController = TextEditingController();
  final _mobileFormKey = GlobalKey<FormState>();
  final _tabletFormKey = GlobalKey<FormState>();
  final _chargerFormKey = GlobalKey<FormState>();
  final _adTitleCOntroller = TextEditingController();
  final _adDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandFocus = FocusNode();
  final _adTitleFocus = FocusNode();
  final _adDescriptionFocus = FocusNode();
  final _priceFocus = FocusNode();
  final List<String> _tabletBrands = ['iPad', 'Samsung', 'Other Tablets'];
  final List<String> chargers = ['Mobile', 'Tablet', 'Smart Watch', 'Speakers'];
  late AuthHandler authHandler;
  final _remainingKey = GlobalKey<FormState>();

  void unfocusFields() {
    _brandFocus.unfocus();
    _adTitleFocus.unfocus();
    _adDescriptionFocus.unfocus();
    _priceFocus.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    super.dispose();
    _brandController.dispose();
    _adTitleCOntroller.dispose();
    _adDescriptionController.dispose();
    _priceController.dispose();
    _brandFocus.unfocus();
    _adTitleFocus.unfocus();
    _adDescriptionFocus.unfocus();
    _priceFocus.unfocus();
  }

  Consumer ipadNotSelectedError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(ipadError);
        return error == ''
            ? const SizedBox()
            : Text(
                error,
                style: GoogleFonts.roboto(color: Colors.red[400]),
              );
      },
    );
  }

  Container getContainer(String text, int selectedIndex, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: index == selectedIndex ? Colors.blue : null,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      height: 30,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontWeight: index == selectedIndex ? FontWeight.bold : null,
              color: index == selectedIndex ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget tabletSubCategory() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _tabletFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type'),
                SizedBox(
                  height: 30,
                  child: Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _tabletBrands.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(selectedIpadProvider.notifier)
                                    .updateSelectedItem(index);
                              },
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final selectedIndex =
                                      ref.watch(selectedIpadProvider);
                                  return getContainer(
                                    _tabletBrands[index],
                                    selectedIndex,
                                    index,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                ipadNotSelectedError(),
                const SizedBox(
                  height: 10,
                ),
                getAdTitle(),
                const SizedBox(height: 20),
                getAdDescription(),
                const SizedBox(height: 20),
                getPrice(),
                const SizedBox(height: 20),
                imageContainer(),
                const SizedBox(
                  height: 50,
                ),
                getButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void chargerSelectionErrorText() {
    if (ref.read(selectChargerProvider) == -1) {
      ref
          .read(chargerError.notifier)
          .updateError('Please select a charger type');
    }
  }

  Consumer chargerNotSelectedError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(chargerError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: Colors.red[400]),
                ),
              );
      },
    );
  }

  Widget chargerSubCategory() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _chargerFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Charger Type'),
                SizedBox(
                  height: 40,
                  child: Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: chargers.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(selectChargerProvider.notifier)
                                    .updateSelectedItem(index);
                              },
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final selectedIndex =
                                      ref.watch(selectChargerProvider);
                                  return getContainer(
                                      chargers[index], selectedIndex, index);
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                chargerNotSelectedError(),
                const SizedBox(
                  height: 10,
                ),
                getAdTitle(),
                const SizedBox(height: 20),
                getAdDescription(),
                const SizedBox(height: 20),
                getPrice(),
                const SizedBox(
                  height: 20,
                ),
                imageContainer(),
                const SizedBox(
                  height: 50,
                ),
                getButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget changeUiAccordingly(String subCategoryName, BuildContext context) {
    if (subCategoryName == Constants.mobilePhone) {
      return mobileSubCategory();
    } else if (subCategoryName == Constants.tablet) {
      return tabletSubCategory();
    } else if (subCategoryName == Constants.mobileChargerLaptopCharger) {
      return chargerSubCategory();
    } else {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _remainingKey,
              child: Column(
                children: [
                  getAdTitle(),
                  const SizedBox(
                    height: 20,
                  ),
                  getAdDescription(),
                  const SizedBox(
                    height: 20,
                  ),
                  getPrice(),
                  const SizedBox(
                    height: 20,
                  ),
                  imageContainer(),
                  const SizedBox(
                    height: 50,
                  ),
                  getButton()
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showBrandSelectorDialog() async {
    final List<String> brandList = ref.read<List<String>>(brandFilterProvider);
    String? selectedBrand = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Select Brand'),
          content: SizedBox(
            width: 300,
            height: 450,
            child: ListView.builder(
              itemCount: brandList.length,
              itemBuilder: (BuildContext itemContext, int index) {
                return ListTile(
                  onTap: () {
                    Navigator.of(ctx).pop<String>(brandList[index]);
                  },
                  title: Text(brandList[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedBrand != null) {
      setState(() {
        _brandController.text = selectedBrand;
      });
    }
  }

  void _uploadImages(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Choose"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(ctx).pop();
                  _cameraPressed(ctx);
                },
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(ctx).pop();
                  _galleryPressed(ctx);
                },
                leading: const Icon(Icons.image),
                title: const Text('Gallery'),
              )
            ],
          ),
        );
      },
    );
  }

  void _cameraPressed(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image == null) return;
    ref.read(imageProvider.notifier).addImage([XFile(image.path)]);
  }

  void _galleryPressed(BuildContext ctx) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      ref.read(imageProvider.notifier).addImage(images);
      if (ctx.mounted) {
        Navigator.of(ctx).pop();
      }
    }
  }

  void dialog(BuildContext context, XFile image) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Alert'),
            content: const Text('Are you sure you want to delete this image?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.blue),
                  )),
              TextButton(
                  onPressed: () {
                    ref.read(imageProvider.notifier).removeImage(image);
                    ref.read(imageSelectProvider.notifier).changeIndex(0);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("Yes", style: TextStyle(color: Colors.red)))
            ],
          );
        });
  }

  Column columnImagesWhilePostingAd() {
    return Column(
      children: [
        Consumer(
          builder: (ctx, ref, child) {
            final images = ref.watch(imageProvider);
            return Expanded(
              flex: 8,
              child: images.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/upload.jpg',
                            height: 100,
                            width: 100,
                          ),
                          Text(
                            'Press + Button to add images',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Upload Atmost 3 images',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          )
                        ],
                      ),
                    )
                  : Consumer(
                      builder: (ctx, ref, child) {
                        final selectedIndex = ref.watch(imageSelectProvider);
                        return Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const Spacer(),
                                  GestureDetector(
                                      onTap: () {
                                        dialog(ctx, images[selectedIndex]);
                                      },
                                      child: const SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ))
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 9,
                              child: Image.file(
                                File(images[selectedIndex].path),
                                fit: BoxFit.fill,
                              ),
                            )
                          ],
                        );
                      },
                    ),
            );
          },
        ),
        Container(
          height: 0.5,
          width: double.infinity,
          color: Colors.black,
        ),
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  unfocusFields();
                  _uploadImages(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle),
                  child: const Icon(
                    Icons.add,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (ctx, ref, child) {
                    final images = ref.watch(imageProvider);
                    return Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (ctx, index) {
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(imageSelectProvider.notifier)
                                      .changeIndex(index);
                                },
                                child: Container(
                                  height: 20,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Center(
                                    child: Image.file(
                                      height: 30,
                                      width: 40,
                                      File(
                                        images[index].path,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    authHandler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  void saveMyAdToDB(String categoryForPostingData) async {
    List<String> url = [];
    if (ref.read(imageProvider).length <= 3) {
      final fbStorage = authHandler.storage;
      final fbCloudFireStore = authHandler.fireStore;
      final uuid = const Uuid().v4();
      final uuid1 = const Uuid().v1();
      if (authHandler.newUser.user == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginAndroid()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return;
      }
      final internetCheck = await InternetConnection().hasInternetAccess;
      if (context.mounted) {
        if (internetCheck) {
          late BuildContext popContext;
          try {
            await fbCloudFireStore.runTransaction((_) async {
              showDialog(
                context: context,
                builder: (ctx) {
                  popContext = ctx;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                },
              );
              for (int i = 0; i < ref.read(imageProvider).length; i++) {
                final dir = await path_provider.getTemporaryDirectory();
                final targetPath = '${dir.absolute.path}/temp.jpg';
                final result = await FlutterImageCompress.compressAndGetFile(
                    ref.read(imageProvider)[i].path, targetPath,
                    quality: 50);
                print(result);
                String uniqueName =
                    '${authHandler.newUser.user!.uid}/$uuid/$i.jpeg';
                UploadTask task =
                    fbStorage.ref(uniqueName).putFile(File(result!.path));
                await task.whenComplete(() => null);
                String downloadURL =
                    await fbStorage.ref(uniqueName).getDownloadURL();
                url.add(downloadURL);
              }
              DocumentReference<Map<String, dynamic>> activeAdDoc =
                  fbCloudFireStore
                      .collection('users')
                      .doc(authHandler.newUser.user!.uid)
                      .collection('MyActiveAds')
                      .doc(uuid1);
              final timeStamp = FieldValue.serverTimestamp();
              await activeAdDoc.set(
                {
                  'id': uuid1,
                  'adTitle': _adTitleCOntroller.text.trim(),
                  'adDescription': _adDescriptionController.text.trim(),
                  'price': double.parse(_priceController.text.trim()),
                  'brand': categoryForPostingData == Constants.mobilePhone
                      ? _brandController.text.trim()
                      : '',
                  'tablet_type': categoryForPostingData == Constants.tablet
                      ? _tabletBrands[ref.read(selectedIpadProvider)]
                      : '',
                  'charger_type': categoryForPostingData ==
                          Constants.mobileChargerLaptopCharger
                      ? chargers[ref.read(selectChargerProvider)]
                      : '',
                  'images': url,
                  'createdAt': timeStamp,
                  'postedBy': '${authHandler.newUser.user!.displayName}',
                  'categoryName': widget.categoryName,
                  'subCategoryName': widget.subCategoryName,
                  'userId': authHandler.newUser.user!.uid,
                  'isAvailable': true,
                },
              );
              CollectionReference allAdsCollection =
                  fbCloudFireStore.collection('AllAds');
              QuerySnapshot existingPost = await allAdsCollection
                  .where('adReference', isEqualTo: activeAdDoc)
                  .get();
              if (existingPost.docs.isEmpty) {
                await allAdsCollection.add({
                  'adReference':
                      activeAdDoc, // Store reference to the ad document in MyActiveAds
                  'createdAt': timeStamp
                });
              }
              CollectionReference categoryCollection =
                  fbCloudFireStore.collection('Category');
              DocumentReference categoryDocRef =
                  categoryCollection.doc(widget.categoryName);
              DocumentReference subcategoryDocRef = categoryDocRef
                  .collection('Subcategories')
                  .doc(widget.subCategoryName);
              QuerySnapshot existingSubcategoryAd = await subcategoryDocRef
                  .collection('Ads')
                  .where('adReference', isEqualTo: activeAdDoc)
                  .get();

              if (existingSubcategoryAd.docs.isEmpty) {
                // If the ad reference does not exist in the subcategory, add it
                await subcategoryDocRef
                    .collection('Ads')
                    .add({'adReference': activeAdDoc, 'createdAt': timeStamp});
              }
            }).then((_) {
              if (!context.mounted) {
                return;
              }
              Navigator.of(popContext).pop();
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const AdUploadedAndroid()));
              }
            });
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            Navigator.of(popContext).pop();
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Alert'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Okay'),
                    )
                  ],
                );
              },
            );
          }
        } else {
          noInternetDialog();
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Alert', style: GoogleFonts.roboto()),
            content: Text(
              'You are Uploading more than 3 images',
              style: GoogleFonts.roboto(),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Okay',
                  style: GoogleFonts.roboto(
                    color: Colors.blue,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  void noInternetDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  void ipadSelectionErrorText() {
    if (ref.read(selectedIpadProvider) == -1) {
      ref.read(ipadError.notifier).updateError('Please select Type');
    }
  }

  void _nextPressed() {
    unfocusFields();
    if (widget.subCategoryName == Constants.mobilePhone) {
      if (!_mobileFormKey.currentState!.validate()) return;
      if (checkAtleastOneImage()) {
        uploadImageDialog();
        return;
      }
      saveMyAdToDB(Constants.mobilePhone);
    } else if (widget.subCategoryName == Constants.tablet) {
      ipadSelectionErrorText();
      if (!_tabletFormKey.currentState!.validate()) return;
      if (checkAtleastOneImage()) {
        uploadImageDialog();
        return;
      }
      saveMyAdToDB(Constants.tablet);
    } else if (widget.subCategoryName == Constants.mobileChargerLaptopCharger) {
      chargerSelectionErrorText();
      if (!_chargerFormKey.currentState!.validate()) return;
      if (checkAtleastOneImage()) {
        uploadImageDialog();
        return;
      }
      saveMyAdToDB(Constants.mobileChargerLaptopCharger);
    } else {
      if (!_remainingKey.currentState!.validate()) return;
      if (checkAtleastOneImage()) {
        uploadImageDialog();
        return;
      }
      saveMyAdToDB('');
    }
  }

  uploadImageDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Alert', style: GoogleFonts.roboto()),
          content: Text('Please select atleast 1 image',
              style: GoogleFonts.roboto()),
          actions: [
            TextButton(
              child: Text('Okay', style: GoogleFonts.roboto()),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  bool checkAtleastOneImage() {
    if (ref.read(imageProvider).isEmpty) {
      return true; // no image
    }
    return false; // Atleast 1 image has uploaded
  }

  SizedBox getButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: () {
          _nextPressed();
        },
        child: const Text(
          'Post Your Ad',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container imageContainer() {
    return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: columnImagesWhilePostingAd());
  }

  TextFormField getBrand() {
    return TextFormField(
      readOnly: true,
      focusNode: _brandFocus,
      onTap: _showBrandSelectorDialog,
      controller: _brandController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Brand',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select Brand';
        }
        return null;
      },
    );
  }

  TextFormField getAdTitle() {
    return TextFormField(
      controller: _adTitleCOntroller,
      focusNode: _adTitleFocus,
      cursorColor: Colors.black,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        label: Text(
          'Ad Title',
          style: GoogleFonts.roboto(),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter Ad Title';
        }
        if (value.length < 5) {
          return 'Ad Title must be at least 5 characters long';
        }
        return null;
      },
    );
  }

  TextFormField getAdDescription() {
    return TextFormField(
      maxLines: 4,
      controller: _adDescriptionController,
      keyboardType: TextInputType.text,
      focusNode: _adDescriptionFocus,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Additional info(include Condition, Features)',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please provide description';
        }
        if (value.length < 5) {
          return 'describiption must be at least 5 characters long';
        }
        return null;
      },
    );
  }

  TextFormField getPrice() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.phone,
      focusNode: _priceFocus,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        labelText: 'Set Price',
        labelStyle: const TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please provide Price';
        }
        if (double.tryParse(value) == null) {
          return 'Please provide valid Price';
        }
        if (double.parse(value) < 1.0) {
          return 'Price must be greater than 1';
        }
        return null;
      },
    );
  }

  Widget mobileSubCategory() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _mobileFormKey,
            child: Column(
              children: [
                getBrand(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                const SizedBox(
                  height: 20,
                ),
                getPrice(),
                const SizedBox(
                  height: 20,
                ),
                imageContainer(),
                const SizedBox(
                  height: 50,
                ),
                getButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetFields() {
    unfocusFields();
    ref.read(imageProvider.notifier).reset();
    ref.read(imageSelectProvider.notifier).changeIndex(0);
    ref.read(selectedIpadProvider.notifier).updateSelectedItem(-1);
    ref.read(selectChargerProvider.notifier).updateSelectedItem(-1);
    ref.read(ipadError.notifier).updateError('');
    ref.read(chargerError.notifier).updateError('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        title: const Text('Include some details'),
      ),
      body: PopScope(
          onPopInvokedWithResult: (didPop, result) {
            resetFields();
          },
          child: changeUiAccordingly(widget.subCategoryName, context)),
    );
  }
}
