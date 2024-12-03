
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/UIPart/android_ios/Providers/brand_filter.dart';
import 'package:resell/constants/constants.dart';

class PhoneBrands extends ConsumerStatefulWidget {
  const PhoneBrands({super.key});

  @override
  ConsumerState<PhoneBrands> createState() => _PhoneBrandsState();
}

class _PhoneBrandsState extends ConsumerState<PhoneBrands> {
  final _searchTextField = TextEditingController();
  final _searchFocusNode = FocusNode();
  Widget _buildSectionHeader(String title) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey2,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CupertinoColors.black,
        ),
      ),
    );
  }

  Widget _buildBrandList(List<String> brands) {
    return Column(
      children: brands.map((brand) {
        return Column(
          children: [
            CupertinoListTile(
              title: Text(
                brand,
                style: GoogleFonts.roboto(),
              ),
              onTap: () {
                ref.read(brandFilterProvider.notifier).filterByBrand('');
                Navigator.of(context).pop({
                  'brand': brand,
                });
              },
            ),
            const Divider(height: 0.5, color: CupertinoColors.systemGrey4),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
            padding: EdgeInsetsDirectional.zero,
            child: const Icon(
              CupertinoIcons.clear,
              size: 25,
            ),
            onPressed: () {
              _searchFocusNode.unfocus();
              ref.read(brandFilterProvider.notifier).filterByBrand('');
              Navigator.of(context).pop();
            }),
        middle: Text(
          'Brand',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                CupertinoSearchTextField(
                  focusNode: _searchFocusNode,
                  controller: _searchTextField,
                  onChanged: (value) {
                    ref.read(brandFilterProvider.notifier).filterByBrand(value);
                  },
                  autocorrect: false,
                  placeholder: 'Search Brand',
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final brandList = ref.watch(brandFilterProvider);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _searchTextField.text.trim().isEmpty
                            ? ListView(
                                children: [
                                  _buildSectionHeader('All'),
                                  _buildBrandList(brandList),
                                ],
                              )
                            : ListView(
                                children: [
                                  _buildBrandList(brandList),
                                ],
                              ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
