import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/android_ios/screens/login_a_i.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/Providers/brand_filter.dart';
import 'package:resell/UIPart/android_ios/Providers/image_selected.dart';
import 'package:resell/UIPart/android_ios/Providers/select_image.dart';
import 'package:resell/UIPart/android_ios/Providers/selected_item.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/ad_uploaded_a_i.dart';
import 'package:resell/UIPart/android_ios/screens/sell_android_ios/phone_brands.dart';
import 'package:resell/constants/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

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
  late AuthHandler handler;

  void unfocusFields() {
    _brandFocus.unfocus();
    _adTitleFocus.unfocus();
    _adDescriptionFocus.unfocus();
    _priceFocus.unfocus();
  }

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  bool checkAtleastOneImage() {
    if (ref.read(imageProvider).isEmpty) {
      return true; // no image
    }
    return false; // Atleast 1 image has uploaded
  }

  void uploadImageDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Alert', style: GoogleFonts.lato()),
            content: Text('Please select atleast 1 image',
                style: GoogleFonts.lato()),
            actions: [
              TextButton(
                child:
                    Text('Okay', style: GoogleFonts.lato(color: Colors.blue)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Alert', style: GoogleFonts.lato()),
            content: Text('Please select atleast 1 image',
                style: GoogleFonts.lato()),
            actions: [
              CupertinoDialogAction(
                child: Text('Okay', style: GoogleFonts.lato()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }

  void brandErrorText() {
    if (_brandController.text.trim().isEmpty) {
      ref.read(brandError.notifier).updateError('Brand is Mandatory');
    } else {
      ref.read(brandError.notifier).updateError('');
    }
  }

  void priceErrorText() {
    if (_priceController.text.trim().isEmpty) {
      ref.read(priceError.notifier).updateError('Price is Mandatory');
    } else if (double.tryParse(_priceController.text.trim()) == null) {
      ref.read(priceError.notifier).updateError('Price should be a number');
    } else if (double.tryParse(_priceController.text.trim())! <= 0) {
      ref.read(priceError.notifier).updateError('Please Provide Valid Price');
    } else {
      ref.read(priceError.notifier).updateError('');
    }
  }

  void adTitleErrorText() {
    if (_adTitleController.text.trim().isEmpty) {
      ref.read(adTitleError.notifier).updateError('Ad title is Mandatory');
    } else if (_adTitleController.text.trim().length < 5) {
      ref
          .read(adTitleError.notifier)
          .updateError('Ad title should be atleast 10 characters');
    } else {
      ref.read(adTitleError.notifier).updateError('');
    }
  }

  void adDescriptionErrorText() {
    if (_adDescriptionController.text.trim().isEmpty) {
      ref
          .read(adDescriptionError.notifier)
          .updateError('Please provide ad description');
    } else if (_adDescriptionController.text.trim().length < 5) {
      ref
          .read(adDescriptionError.notifier)
          .updateError('Ad description should be atleast 10 characters');
    } else {
      ref.read(adDescriptionError.notifier).updateError('');
    }
  }

  void chargerSelectionErrorText() {
    if (ref.read(selectChargerProvider) == -1) {
      ref
          .read(chargerError.notifier)
          .updateError('Please select a charger type');
    }
  }

  void ipadSelectionErrorText() {
    if (ref.read(selectedIpadProvider) == -1) {
      ref.read(ipadError.notifier).updateError('Please select a brand');
    }
  }

  void confirmationDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text("Confirmation of Price", style: GoogleFonts.lato()),
            content: Text("PRICE : ${_priceController.text}"),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: GoogleFonts.lato(color: Colors.blue),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (widget.subCategoryName == Constants.mobilePhone) {
                    saveMyAdToDB(Constants.mobilePhone);
                  } else if (widget.subCategoryName == Constants.tablet) {
                    saveMyAdToDB(Constants.tablet);
                  } else if (widget.subCategoryName == '') {
                    saveOtherAdToDB(Constants.other);
                  } else {
                    saveMyAdToDB('');
                  }
                },
                child: Text(
                  "Sell",
                  style: GoogleFonts.lato(color: Colors.blue),
                ),
              )
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Confirmation of Price", style: GoogleFonts.lato()),
              content: Text(
                "Price : ${_priceController.text}",
                style: GoogleFonts.lato(),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.lato(),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (widget.subCategoryName == Constants.mobilePhone) {
                      saveMyAdToDB(Constants.mobilePhone);
                    } else if (widget.subCategoryName == Constants.tablet) {
                      saveMyAdToDB(Constants.tablet);
                    } else if (widget.subCategoryName == '') {
                      saveOtherAdToDB(Constants.other);
                    } else {
                      saveMyAdToDB('');
                    }
                  },
                  child: Text(
                    "Sell",
                    style: GoogleFonts.lato(),
                  ),
                )
              ],
            );
          });
    }
  }

  void _nextPressed() {
    if (Platform.isAndroid) {
      if (widget.subCategoryName == Constants.mobilePhone) {
        if (!_mobileFormKey.currentState!.validate()) return;
        if (checkAtleastOneImage()) {
          uploadImageDialog();
          return;
        }
        unfocusFields();
        confirmationDialog();
        // saveMyAdToDB(Constants.mobilePhone);
      } else if (widget.subCategoryName == Constants.tablet) {
        ipadSelectionErrorText();
        if (!_tabletFormKey.currentState!.validate()) return;
        if (checkAtleastOneImage()) {
          uploadImageDialog();
          return;
        }
        unfocusFields();
        confirmationDialog();
        // saveMyAdToDB(Constants.tablet);
      } else if (widget.subCategoryName ==
          Constants.mobileChargerLaptopCharger) {
        chargerSelectionErrorText();
        if (!_chargerFormKey.currentState!.validate()) return;
        if (checkAtleastOneImage()) {
          uploadImageDialog();
          return;
        }
        unfocusFields();
        confirmationDialog();
        //saveMyAdToDB(Constants.mobileChargerLaptopCharger);
      } else if (widget.subCategoryName == '') {
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          // saveOtherAdToDB(Constants.other);
        }
      } else {
        if (!_remainingKey.currentState!.validate()) return;
        if (checkAtleastOneImage()) {
          uploadImageDialog();
          return;
        }
        unfocusFields();
        confirmationDialog();
        // saveMyAdToDB('');
      }
    } else if (Platform.isIOS) {
      if (widget.subCategoryName == Constants.mobilePhone) {
        brandErrorText();
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(brandError).isEmpty &&
            ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          // saveMyAdToDB(Constants.mobilePhone);
        }
      } else if (widget.subCategoryName == Constants.tablet) {
        ipadSelectionErrorText();
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(selectedIpadProvider) != -1 &&
            ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          // saveMyAdToDB(Constants.tablet);
        }
      } else if (widget.subCategoryName ==
          Constants.mobileChargerLaptopCharger) {
        chargerSelectionErrorText();
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(selectChargerProvider) != -1 &&
            ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          // saveMyAdToDB(Constants.mobileChargerLaptopCharger);
        }
      } else if (widget.subCategoryName == '') {
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          // saveOtherAdToDB(Constants.other);
        }
      } else {
        adTitleErrorText();
        adDescriptionErrorText();
        priceErrorText();
        if (ref.read(adTitleError).isEmpty &&
            ref.read(adDescriptionError).isEmpty &&
            ref.read(priceError).isEmpty) {
          if (checkAtleastOneImage()) {
            uploadImageDialog();
            return;
          }
          unfocusFields();
          confirmationDialog();
          //saveMyAdToDB('');
        }
      }
    }
  }

  void noInternetDialog() {
    if (Platform.isAndroid) {
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
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text(
                'Please check your internet connection and try again'),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Okay',
                  style: GoogleFonts.lato(),
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

  void saveOtherAdToDB(String categoryName) async {
    List<String> url = [];
    if (ref.read(imageProvider).length <= 3) {
      final fbStorage = handler.storage;
      final fbCloudFireStore = handler.fireStore;
      final uuid = const Uuid().v4();
      final uuid1 = const Uuid().v1();
      if (handler.newUser.user != null) {
        final internetCheck = await InternetConnection().hasInternetAccess;
        if (context.mounted) {
          if (internetCheck) {
            late BuildContext popContext;
            try {
              await fbCloudFireStore.runTransaction(
                (_) async {
                  if (Platform.isAndroid) {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          popContext = ctx;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          );
                        });
                  } else if (Platform.isIOS) {
                    showCupertinoDialog(
                      context: context,
                      builder: (ctx) {
                        popContext = ctx;
                        return const Center(
                          child: CupertinoActivityIndicator(
                            radius: 15,
                            color: CupertinoColors.darkBackgroundGray,
                          ),
                        );
                      },
                    );
                  }
                  for (int i = 0; i < ref.read(imageProvider).length; i++) {
                    final dir = await path_provider.getTemporaryDirectory();
                    final targetPath = '${dir.absolute.path}/temp.jpg';
                    final result =
                        await FlutterImageCompress.compressAndGetFile(
                            ref.read(imageProvider)[i].path, targetPath,
                            quality: 50);

                    String uniqueName =
                        '${handler.newUser.user!.uid}/$uuid/$i.jpeg';
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
                          .doc(handler.newUser.user!.uid)
                          .collection('MyActiveAds')
                          .doc(uuid1);
                  final timeStamp = FieldValue.serverTimestamp();
                  await activeAdDoc.set(
                    {
                      'id': uuid1,
                      'adTitle': _adTitleController.text.trim(),
                      'adDescription': _adDescriptionController.text.trim(),
                      'price': double.parse(_priceController.text.trim()),
                      'brand': '',
                      'tablet_type': '',
                      'charger_type': '',
                      'images': url,
                      'createdAt': timeStamp,
                      'postedBy': '${handler.newUser.user!.displayName}',
                      'categoryName': widget.categoryName,
                      'subCategoryName': widget.subCategoryName,
                      'userId': handler.newUser.user!.uid,
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
                  //till here its all Ads and myACtiveAds done
                  // now do for the category Ads
                  CollectionReference othersCollectionReference =
                      fbCloudFireStore
                          .collection('users')
                          .doc(handler.newUser.user!.uid)
                          .collection('others');
                  QuerySnapshot existingOtherAd =
                      await othersCollectionReference
                          .where('adReference', isEqualTo: activeAdDoc)
                          .get();
                  if (existingOtherAd.docs.isEmpty) {
                    await othersCollectionReference.add(
                      {
                        'adReference':
                            activeAdDoc, // Store reference to the ad document in MyActiveAds
                        'createdAt': timeStamp
                      },
                    );
                  }
                },
              ).then((_) {
                if (!context.mounted) {
                  return;
                }
                resetFields();
                Navigator.of(popContext).pop();
                if (context.mounted) {
                  if (Platform.isAndroid) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => AdUploadedAI(
                              categoryName: widget.categoryName,
                            )));
                  } else if (Platform.isIOS) {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (ctx) =>
                            AdUploadedAI(categoryName: widget.categoryName)));
                  }
                }
              });
            } catch (e) {
              if (!context.mounted) {
                return;
              }
              Navigator.of(popContext).pop();
              errorAlert(e.toString());
            }
          } else {
            noInternetDialog();
          }
        }
      } else {
        if (Platform.isAndroid) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginAI()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else if (Platform.isIOS) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } else {
      showMoreImagesUploadDialog();
    }
  }

  void saveMyAdToDB(String categoryForPostingData) async {
    List<String> url = [];
    if (ref.read(imageProvider).length <= 3) {
      final fbStorage = handler.storage;
      final fbCloudFireStore = handler.fireStore;
      final uuid = const Uuid().v4();
      final uuid1 = const Uuid().v1();
      if (handler.newUser.user != null) {
        final internetCheck = await InternetConnection().hasInternetAccess;
        if (context.mounted) {
          if (internetCheck) {
            late BuildContext popContext;
            try {
              await fbCloudFireStore.runTransaction((_) async {
                if (Platform.isAndroid) {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (ctx) {
                        popContext = ctx;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue,
                          ),
                        );
                      });
                } else if (Platform.isIOS) {
                  showCupertinoDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        popContext = ctx;
                        return const Center(
                          child: CupertinoActivityIndicator(
                            radius: 15,
                            color: CupertinoColors.darkBackgroundGray,
                          ),
                        );
                      });
                }
                for (int i = 0; i < ref.read(imageProvider).length; i++) {
                  final dir = await path_provider.getTemporaryDirectory();
                  final targetPath = '${dir.absolute.path}/temp.jpg';
                  final result = await FlutterImageCompress.compressAndGetFile(
                      ref.read(imageProvider)[i].path, targetPath,
                      quality: 50);
                  String uniqueName =
                      '${handler.newUser.user!.uid}/$uuid/$i.jpeg';
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
                        .doc(handler.newUser.user!.uid)
                        .collection('MyActiveAds')
                        .doc(uuid1);
                final timeStamp = FieldValue.serverTimestamp();
                await activeAdDoc.set(
                  {
                    'id': uuid1,
                    'adTitle': _adTitleController.text.trim(),
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
                    'postedBy': '${handler.newUser.user!.displayName}',
                    'categoryName': widget.categoryName,
                    'subCategoryName': widget.subCategoryName,
                    'userId': handler.newUser.user!.uid,
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
                  await subcategoryDocRef.collection('Ads').add(
                      {'adReference': activeAdDoc, 'createdAt': timeStamp});
                }
              }).then((_) {
                if (!context.mounted) {
                  return;
                }
                resetFields();
                Navigator.of(popContext).pop();
                if (context.mounted) {
                  if (Platform.isAndroid) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => AdUploadedAI(
                              categoryName: widget.categoryName,
                            )));
                  } else if (Platform.isIOS) {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (ctx) => AdUploadedAI(
                              categoryName: widget.categoryName,
                            )));
                  }
                }
              });
            } catch (e) {
              if (!context.mounted) {
                return;
              }
              Navigator.of(popContext).pop();
              errorAlert(e.toString());
            }
          } else {
            noInternetDialog();
          }
        }
      } else {
        if (Platform.isAndroid) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginAI()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else if (Platform.isIOS) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginAI()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } else {
      showMoreImagesUploadDialog();
    }
  }

  showMoreImagesUploadDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Alert', style: GoogleFonts.lato()),
            content: Text(
              'You are Uploading more than 3 images',
              style: GoogleFonts.lato(),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Okay',
                  style: GoogleFonts.lato(
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
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Alert', style: GoogleFonts.lato()),
            content: Text(
              'You are Uploading more than 3 images',
              style: GoogleFonts.lato(),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Okay', style: GoogleFonts.lato()),
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

  void errorAlert(String e) {
    if (Platform.isAndroid) {
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
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Alert', style: GoogleFonts.lato()),
            content: Text(e.toString(), style: GoogleFonts.lato()),
            actions: [
              CupertinoDialogAction(
                child: Text('Okay', style: GoogleFonts.lato()),
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

  void resetFields() {
    unfocusFields();
    if (Platform.isAndroid) {
      ref.read(imageProvider.notifier).reset();
      ref.read(imageSelectProvider.notifier).changeIndex(0);
      ref.read(selectedIpadProvider.notifier).updateSelectedItem(-1);
      ref.read(selectChargerProvider.notifier).updateSelectedItem(-1);
      ref.read(ipadError.notifier).updateError('');
      ref.read(chargerError.notifier).updateError('');
    } else if (Platform.isIOS) {
      ref.read(selectChargerProvider.notifier).updateSelectedItem(-1);
      ref.read(selectedIpadProvider.notifier).updateSelectedItem(-1);
      ref.read(brandError.notifier).updateError('');
      ref.read(adTitleError.notifier).updateError('');
      ref.read(adDescriptionError.notifier).updateError('');
      ref.read(ipadError.notifier).updateError('');
      ref.read(chargerError.notifier).updateError('');
      ref.read(priceError.notifier).updateError('');
      ref.read(imageProvider.notifier).reset();
      ref.read(imageSelectProvider.notifier).changeIndex(0);
    }
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

  void _cameraPressed(BuildContext ctx) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (image == null) return;
      ref.read(imageProvider.notifier).addImage([XFile(image.path)]);
    } catch (e) {
      var status = await Permission.camera.status;
      if (status.isDenied) {
        settingsDialog();
      } else {
        debugPrint('Permission denied');
      }
    }
  }

  void settingsDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Permission Denied',
              style: GoogleFonts.lato(),
            ),
            content: Text(
              'Please allow the permission to access the gallery',
              style: GoogleFonts.lato(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: Text(
                  'Open Settings',
                  style: GoogleFonts.lato(),
                ),
              )
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Permission Denied',
              style: GoogleFonts.lato(),
            ),
            content: Text(
              'Please allow the permission to access the gallery',
              style: GoogleFonts.lato(),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  openAppSettings();
                },
                child: Text(
                  'Open Settings',
                  style: GoogleFonts.lato(),
                ),
              )
            ],
          );
        },
      );
    }
  }

  void _galleryPressed(BuildContext ctx) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        ref.read(imageProvider.notifier).addImage(images);
        if (ctx.mounted) {
          Navigator.of(ctx).pop();
        }
      }
    } catch (e) {
      var status = await Permission.photos.status;
      if (status.isDenied) {
        settingsDialog();
      } else {
        debugPrint('Permission denied');
      }
    }
  }

  void _uploadImages(BuildContext context) {
    if (Platform.isAndroid) {
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
    } else if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            title: Text(
              'Select Either Camera or Gallery too Upload Images',
              style: GoogleFonts.lato(),
            ),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _cameraPressed(ctx);
                },
                child: Text(
                  'Camera',
                  style: GoogleFonts.lato(),
                ),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _galleryPressed(ctx);
                },
                child: Text('Gallery', style: GoogleFonts.lato()),
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(color: CupertinoColors.systemRed),
              ),
            ),
          );
        },
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

  TextFormField getBrand() {
    return TextFormField(
      readOnly: true,
      focusNode: _brandFocus,
      onTap: _showBrandSelectorDialog,
      controller: _brandController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        label: Text(
          'Brand',
          style: GoogleFonts.lato(),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select Brand';
        }
        return null;
      },
    );
  }

  Widget getAdTitle() {
    if (Platform.isAndroid) {
      return TextFormField(
        controller: _adTitleController,
        focusNode: _adTitleFocus,
        cursorColor: Colors.black,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          label: Text(
            'Ad Title',
            style: GoogleFonts.lato(),
          ),
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
    } else if (Platform.isIOS) {
      return Consumer(
        builder: (context, ref, child) {
          final error = ref.watch(adTitleError);
          return SizedBox(
            height: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Ad Title ',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: error == ''
                          ? CupertinoColors.black
                          : CupertinoColors.systemRed,
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    focusNode: _adTitleFocus,
                    controller: _adTitleController,
                    placeholder: 'Ad Title',
                    cursorColor: CupertinoColors.black,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: error == ''
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget getAdDescription() {
    if (Platform.isAndroid) {
      return TextFormField(
        maxLines: 4,
        controller: _adDescriptionController,
        keyboardType: TextInputType.text,
        focusNode: _adDescriptionFocus,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          label: Text(
            'Additional Info (Include Condition, features) ',
            style: GoogleFonts.lato(),
          ),
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
    } else if (Platform.isIOS) {
      return Consumer(
        builder: (context, ref, child) {
          final error = ref.watch(adDescriptionError);
          return SizedBox(
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Additional Info (Include Condition, features) ',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: error == ''
                          ? CupertinoColors.black
                          : CupertinoColors.systemRed,
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    focusNode: _adDescriptionFocus,
                    controller: _adDescriptionController,
                    maxLines: 10,
                    textAlignVertical: TextAlignVertical.top,
                    cursorColor: CupertinoColors.black,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: error == ''
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  Widget getPrice() {
    if (Platform.isAndroid) {
      return TextFormField(
        controller: _priceController,
        keyboardType: TextInputType.phone,
        focusNode: _priceFocus,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
          ),
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.blue),
          label: Text(
            'Price',
            style: GoogleFonts.lato(),
          ),
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
    } else if (Platform.isIOS) {
      return Consumer(
        builder: (context, ref, child) {
          final error = ref.watch(priceError);
          return SizedBox(
            height: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Set Price ',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: error == ''
                          ? CupertinoColors.black
                          : CupertinoColors.systemRed,
                    ),
                    children: [
                      TextSpan(
                        text: '*',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    keyboardType: TextInputType.number,
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '₹',
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: CupertinoColors.black,
                        ),
                      ),
                    ),
                    controller: _priceController,
                    focusNode: _priceFocus,
                    placeholder: 'Set Price',
                    cursorColor: CupertinoColors.black,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: error == ''
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemRed,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  void _dialog(BuildContext context, XFile image) {
    if (Platform.isAndroid) {
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
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text(
              'Alert',
              style: GoogleFonts.lato(),
            ),
            content: Text(
              'Are you sure want to delete this image?',
              style: GoogleFonts.lato(),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Yes',
                  style:
                      GoogleFonts.lato(color: CupertinoColors.destructiveRed),
                ),
                onPressed: () {
                  ref.read(imageProvider.notifier).removeImage(image);
                  ref.read(imageSelectProvider.notifier).changeIndex(0);
                  Navigator.of(ctx).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'No',
                  style: GoogleFonts.lato(),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget columnImagesWhilePostingAd() {
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
                            'assets/images/upload.png',
                            height: 100,
                            width: 100,
                          ),
                          Text(
                            'Press + Button to add images',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Platform.isAndroid
                                  ? Colors.grey
                                  : Platform.isIOS
                                      ? CupertinoColors.systemGrey
                                      : Colors.grey,
                            ),
                          ),
                          Text(
                            'Upload Atmost 3 images',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Platform.isAndroid
                                  ? Colors.grey
                                  : Platform.isIOS
                                      ? CupertinoColors.systemGrey
                                      : Colors.grey,
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
                                      _dialog(ctx, images[selectedIndex]);
                                    },
                                    child: Icon(
                                      CupertinoIcons.clear_circled_solid,
                                      color: Platform.isAndroid
                                          ? Colors.red
                                          : Platform.isIOS
                                              ? CupertinoColors.destructiveRed
                                              : Colors.red,
                                    ),
                                  )
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
          color: Platform.isAndroid
              ? Colors.black
              : Platform.isIOS
                  ? CupertinoColors.black
                  : Colors.black,
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
                child: Platform.isAndroid
                    ? Container(
                        margin: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                        child: const Icon(
                          Icons.add,
                          size: 50,
                          color: Colors.white,
                        ),
                      )
                    : Platform.isIOS
                        ? const Icon(
                            CupertinoIcons.add_circled_solid,
                            size: 50,
                          )
                        : const Icon(
                            Icons.add,
                            size: 50,
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
                                      color: Platform.isAndroid
                                          ? Colors.grey
                                          : Platform.isIOS
                                              ? CupertinoColors.systemGrey
                                              : Colors.white,
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

  Container imageContainer() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: Platform.isAndroid
              ? Colors.black
              : Platform.isIOS
                  ? CupertinoColors.systemGrey
                  : Colors.white,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: columnImagesWhilePostingAd(),
    );
  }

  Widget getButton() {
    if (Platform.isAndroid) {
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
    } else if (Platform.isIOS) {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          child: Text(
            'Post Your Ad',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          onPressed: () {
            _nextPressed();
          },
        ),
      );
    }
    return const SizedBox();
  }

  //ios
  Consumer watchingMobileSelection() {
    return Consumer(
      builder: (context, ref, child) {
        final error = ref.watch(brandError);
        return SizedBox(
          height: 70,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Brand ',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTextField(
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final selectedBrand =
                        await Navigator.of(context).push<Map<String, String>>(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (ctx) => const PhoneBrands(),
                      ),
                    );
                    if (selectedBrand == null) {
                      FocusScope.of(context).unfocus();
                      return;
                    }
                    _brandController.text = selectedBrand['brand']!;
                    _brandFocus.unfocus();
                  },
                  suffix: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                    ),
                  ),
                  focusNode: _brandFocus,
                  controller: _brandController,
                  placeholder: 'Brand Name',
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: error == ''
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemRed,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Consumer mobileNotSelectionError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(brandError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.lato(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer adTitleNotWrittenError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(adTitleError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.lato(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer adDescriptionNotWrittenError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(adDescriptionError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.lato(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Consumer priceNotSetError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(priceError);
        return error == ''
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.lato(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Widget mobileSubCategory() {
    if (Platform.isAndroid) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _mobileFormKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
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
    } else if (Platform.isIOS) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                watchingMobileSelection(),
                mobileNotSelectionError(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getPrice(),
                priceNotSetError(),
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
      );
    }
    return const SizedBox();
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
                  style: GoogleFonts.lato(
                    color: Platform.isAndroid
                        ? const Color.fromARGB(255, 202, 11, 7)
                        : Platform.isIOS
                            ? CupertinoColors.systemRed
                            : Colors.red,
                  ),
                ),
              );
      },
    );
  }

  Widget getTypeOfChargers() {
    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (ctx, ref, child) {
              final error = ref.watch(chargerError);
              return RichText(
                text: TextSpan(
                  text: 'Charger Type ',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
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
        ],
      ),
    );
  }

  Widget chargerSubCategory() {
    if (Platform.isAndroid) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Form(
              key: _chargerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Charger Type',
                    style: GoogleFonts.lato(),
                  ),
                  SizedBox(
                    height: 40,
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
    } else if (Platform.isIOS) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTypeOfChargers(),
                chargerNotSelectedError(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getPrice(),
                priceNotSetError(),
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
      );
    }
    return const SizedBox();
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
            style: GoogleFonts.lato(
              fontWeight: index == selectedIndex ? FontWeight.bold : null,
              color: index == selectedIndex ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Consumer ipadNotSelectedError() {
    return Consumer(
      builder: (ctx, ref, child) {
        final error = ref.watch(ipadError);
        return error == ''
            ? const SizedBox()
            : Text(
                error,
                style: GoogleFonts.lato(
                  color: Platform.isAndroid
                      ? const Color.fromARGB(255, 202, 11, 7)
                      : Platform.isIOS
                          ? CupertinoColors.systemRed
                          : Colors.red,
                ),
              );
      },
    );
  }

  //ios
  Widget getTypeOfTablets() {
    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer(
            builder: (ctx, ref, child) {
              final error = ref.watch(ipadError);
              return RichText(
                text: TextSpan(
                  text: 'Type ',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
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
                          final selectedIndex = ref.watch(selectedIpadProvider);
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
        ],
      ),
    );
  }

  Widget tabletSubCategory() {
    if (Platform.isAndroid) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _tabletFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Type',
                    style: GoogleFonts.lato(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 30,
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
                  ipadNotSelectedError(),
                  const SizedBox(
                    height: 20,
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
    } else if (Platform.isIOS) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTypeOfTablets(),
                ipadNotSelectedError(),
                const SizedBox(
                  height: 20,
                ),
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getPrice(),
                priceNotSetError(),
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
      );
    }
    return const SizedBox();
  }

  Widget remainingCategory() {
    if (Platform.isAndroid) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _remainingKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
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
    } else if (Platform.isIOS) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAdTitle(),
                adTitleNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getAdDescription(),
                adDescriptionNotWrittenError(),
                const SizedBox(
                  height: 20,
                ),
                getPrice(),
                priceNotSetError(),
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
      );
    }
    return const SizedBox();
  }

  Widget changeUIAccordingly(String subCategoryName, BuildContext context) {
    if (subCategoryName == Constants.mobilePhone) {
      return mobileSubCategory();
    } else if (subCategoryName == Constants.tablet) {
      return tabletSubCategory();
    } else if (subCategoryName == Constants.mobileChargerLaptopCharger) {
      return chargerSubCategory();
    } else {
      return remainingCategory();
    }
  }

  Widget android() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: Colors.grey[200],
        title: Text(
          'Include some details',
          style: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          resetFields();
        },
        child: GestureDetector(
          onTap: () {
            unfocusFields();
          },
          child: changeUIAccordingly(widget.subCategoryName, context),
        ),
      ),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        middle: Text(
          'Include some details',
          style: GoogleFonts.lato(),
        ),
        leading: CupertinoButton(
          padding: EdgeInsetsDirectional.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            resetFields();
            Navigator.pop(context);
          },
        ),
      ),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          resetFields();
        },
        child: GestureDetector(
          onTap: () {
            unfocusFields();
          },
          child: changeUIAccordingly(widget.subCategoryName, context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android();
    }
    if (Platform.isIOS) {
      return ios();
    }
    return const SizedBox();
  }
}
