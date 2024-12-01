import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/IOS_Files/Screens/auth/login_ios.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/UIPart/IOS_Files/screens/sell/ad_uploaded.dart';
import 'package:resell/UIPart/IOS_Files/screens/sell/phone_brands.dart';
import 'package:resell/UIPart/Providers/image_selected.dart';
import 'package:resell/UIPart/Providers/select_image.dart';
import 'package:resell/UIPart/Providers/selected_item.dart';
import 'package:resell/constants/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ProductGetInfo extends ConsumerStatefulWidget {
  final String categoryName;
  final String subCategoryName;
  const ProductGetInfo({
    required this.categoryName,
    required this.subCategoryName,
    super.key,
  });

  @override
  ConsumerState<ProductGetInfo> createState() => _ProductGetInfoState();
}

class _ProductGetInfoState extends ConsumerState<ProductGetInfo> {
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
    } else if (_adTitleController.text.trim().length < 10) {
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
    } else if (_adDescriptionController.text.trim().length < 10) {
      ref
          .read(adDescriptionError.notifier)
          .updateError('Ad description should be atleast 10 characters');
    } else {
      ref.read(adDescriptionError.notifier).updateError('');
    }
  }

  void ipadSelectionErrorText() {
    if (ref.read(selectedIpadProvider) == -1) {
      ref.read(ipadError.notifier).updateError('Please select a brand');
    }
  }

  void noInternetDialog() {
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
                  style: GoogleFonts.roboto(),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
  }

  void saveMyAdToDB(String categoryForPostingData) async {
    List<String> url = [];
    if (ref.read(imageProvider).length <= 3) {
      final fbStorage = handler.storage;
      final fbCloudFireStore = handler.fireStore;
      final uuid = const Uuid().v4();
      final uuid1 = const Uuid().v1();
      if (handler.newUser.user?.uid == null) {
        // then i need to write the code to move to the login screen.
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            CupertinoPageRoute(builder: (ctx) => const LoginIos()),
            (Route<dynamic> route) => false);
        return;
      }
      final internetCheck = await InternetConnection().hasInternetAccess;
      if (context.mounted) {
        if (internetCheck) {
          late BuildContext popContext;
          try {
            await fbCloudFireStore.runTransaction((_) async {
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
                  });
              for (int i = 0; i < ref.read(imageProvider).length; i++) {
                final dir = await path_provider.getTemporaryDirectory();
                final targetPath = '${dir.absolute.path}/temp.jpg';
                final result = await FlutterImageCompress.compressAndGetFile(
                    ref.read(imageProvider)[i].path, targetPath,
                    quality: 50);
                print(result);
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
                await subcategoryDocRef
                    .collection('Ads')
                    .add({'adReference': activeAdDoc, 'createdAt': timeStamp});
              }
            }).then((_) {
              if (!context.mounted) {
                return;
              }
              resetFields();
              Navigator.of(popContext).pop();
              if (context.mounted) {
                Navigator.of(context).push(
                    CupertinoPageRoute(builder: (ctx) => const AdUploaded()));
              }
            });
          } catch (e) {
            if (!context.mounted) {
              return;
            }
            Navigator.of(popContext).pop();
            showCupertinoDialog(
              context: context,
              builder: (ctx) {
                return CupertinoAlertDialog(
                  title: Text('Alert', style: GoogleFonts.roboto()),
                  content: Text(e.toString(), style: GoogleFonts.roboto()),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Okay', style: GoogleFonts.roboto()),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
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
      showCupertinoDialog(
          context: context,
          builder: (ctx) {
            return CupertinoAlertDialog(
              title: Text('Alert', style: GoogleFonts.roboto()),
              content: Text(
                'You are Uploading more than 3 images',
                style: GoogleFonts.roboto(),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Okay', style: GoogleFonts.roboto()),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          });
    }
  }

  bool checkAtleastOneImage() {
    if (ref.read(imageProvider).isEmpty) {
      return true; // no image
    }
    return false; // Atleast 1 image has uploaded
  }

  uploadImageDialog() {
    showCupertinoDialog(
        context: context,
        builder: (ctx) {
          return CupertinoAlertDialog(
            title: Text('Alert', style: GoogleFonts.roboto()),
            content: Text('Please select atleast 1 image',
                style: GoogleFonts.roboto()),
            actions: [
              CupertinoDialogAction(
                child: Text('Okay', style: GoogleFonts.roboto()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void _nextPressed() {
    unfocusFields();
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
        saveMyAdToDB(Constants.mobilePhone);
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
        saveMyAdToDB(Constants.tablet);
      }
    } else if (widget.subCategoryName == Constants.mobileChargerLaptopCharger) {
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
        saveMyAdToDB(Constants.mobileChargerLaptopCharger);
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
        // For every other category i'm taking an empty string as category
        saveMyAdToDB('');
      }
    }
  }

  void chargerSelectionErrorText() {
    if (ref.read(selectChargerProvider) == -1) {
      ref
          .read(chargerError.notifier)
          .updateError('Please select a charger type');
    }
  }

  Consumer getAdTitle() {
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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
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

  Consumer setThePrice() {
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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
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
                      style: GoogleFonts.roboto(
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

  Consumer getAdDescription() {
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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
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

  Widget getCupertinoButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: CupertinoButton(
        color: CupertinoColors.activeBlue,
        child: Text(
          'Post Your Ad',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: () {
          _nextPressed();
        },
      ),
    );
  }

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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTextField(
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
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
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
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
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
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
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
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Widget mobileSubCategory() {
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
              setThePrice(),
              priceNotSetError(),
              const SizedBox(
                height: 20,
              ),
              imageContainer(),
              const SizedBox(
                height: 50,
              ),
              getCupertinoButton()
            ],
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
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  error,
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
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
                  style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
                ),
              );
      },
    );
  }

  Widget tabletSubCategory() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
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
                setThePrice(),
                priceNotSetError(),
                const SizedBox(
                  height: 20,
                ),
                imageContainer(),
                const SizedBox(
                  height: 50,
                ),
                getCupertinoButton()
              ],
            ),
          ),
        ),
      ),
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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
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
              setThePrice(),
              priceNotSetError(),
              const SizedBox(
                height: 20,
              ),
              imageContainer(),
              const SizedBox(
                height: 50,
              ),
              getCupertinoButton()
            ],
          ),
        ),
      ),
    );
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
                                color: CupertinoColors.systemGrey),
                          ),
                          Text(
                            'Upload Atmost 3 images',
                            style: GoogleFonts.roboto(
                                fontSize: 18,
                                color: CupertinoColors.systemGrey),
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
                                    child: Icon(
                                      CupertinoIcons.clear_circled_solid,
                                      color: CupertinoColors.destructiveRed,
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
          color: CupertinoColors.black,
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
                child: const Icon(
                  CupertinoIcons.add_circled_solid,
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
                                      color: CupertinoColors.systemGrey,
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

  Column columnImagesWhileEditingAd() {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: Container(
            color: CupertinoColors.activeBlue,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: CupertinoColors.activeGreen,
              border: Border(
                top: BorderSide(width: 0.5),
              ),
            ),
          ),
        )
      ],
    );
  }

  Container imageContainer() {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey),
          borderRadius: BorderRadius.circular(5),
        ),
        height: 300,
        child: columnImagesWhilePostingAd());
  }

  void dialog(BuildContext context, XFile image) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(
            'Alert',
            style: GoogleFonts.roboto(),
          ),
          content: Text(
            'Are you sure want to delete this image?',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Yes',
                style:
                    GoogleFonts.roboto(color: CupertinoColors.destructiveRed),
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
                style: GoogleFonts.roboto(),
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

  void _uploadImages(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: Text(
            'Select Either Camera or Gallery too Upload Images',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                _cameraPressed(ctx);
              },
              child: Text(
                'Camera',
                style: GoogleFonts.roboto(),
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(ctx).pop();
                _galleryPressed(ctx);
              },
              child: Text('Gallery', style: GoogleFonts.roboto()),
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.roboto(color: CupertinoColors.systemRed),
            ),
          ),
        );
      },
    );
  }

  Widget changeUIAccordingly(String subCategoryName, BuildContext context) {
    if (subCategoryName == Constants.mobilePhone) {
      return GestureDetector(
        onTap: () {
          unfocusFields();
        },
        child: mobileSubCategory(),
      );
    } else if (subCategoryName == Constants.tablet) {
      return tabletSubCategory();
    } else if (subCategoryName == Constants.mobileChargerLaptopCharger) {
      return chargerSubCategory();
    } else {
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
                setThePrice(),
                priceNotSetError(),
                const SizedBox(
                  height: 20,
                ),
                imageContainer(),
                const SizedBox(
                  height: 50,
                ),
                getCupertinoButton()
              ],
            ),
          ),
        ),
      );
    }
  }

  Container getContainer(String text, int selectedIndex, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: index == selectedIndex ? CupertinoColors.activeBlue : null,
        border: Border.all(
          color: CupertinoColors.systemGrey,
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
              color: index == selectedIndex ? CupertinoColors.white : null,
            ),
          ),
        ),
      ),
    );
  }

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
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: error == ''
                        ? CupertinoColors.black
                        : CupertinoColors.systemRed,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
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

  void resetFields() {
    unfocusFields();
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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        middle: Text(
          'Include some details',
          style: GoogleFonts.roboto(),
        ),
        leading: CupertinoButton(
            padding: EdgeInsetsDirectional.zero,
            child: const Icon(CupertinoIcons.back),
            onPressed: () {
              resetFields();
              Navigator.pop(context);
            }),
      ),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          resetFields();
        },
        child: GestureDetector(
          onTap: () {
            unfocusFields();
          },
          child: changeUIAccordingly(
            widget.subCategoryName,
            context,
          ),
        ),
      ),
    );
  }
}
