import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:goal_path/core/theme/app_colors.dart';
import 'package:goal_path/core/constants/app_sizes.dart';
import 'package:goal_path/core/constants/app_strings.dart';
import 'package:goal_path/features/home/add_item_screen.dart';
import 'package:goal_path/features/home/edit_item_screen.dart';
import 'package:goal_path/core/providers/purchases_provider.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  XFile? _image;
  int _currentIndex = 0;
  bool _isSearchiing = false;
  bool _hasActiveSort = false;
  final TextEditingController _searchController = TextEditingController();
  // final List<Map<String, dynamic>> purchases = [];

  List<Map<String, dynamic>> _filteredPurchases 
  (List<Map<String, dynamic>> purchases) {
    List<Map<String, dynamic>> result = List.from(purchases);

    if (_searchController.text.isNotEmpty) {
      result = result.where((item) =>
        item['name'].toString().toLowerCase()
            .contains(_searchController.text.toLowerCase())).toList();
    }
    
    if (_selectedFilterCategory != null) {
      result = result.where((item) =>
          item['category'] == _selectedFilterCategory).toList();
    }

    if (_filterUnpurchased == true && _filterPurchased != true) {
      result = result.where((item) => item['purchased'] != true).toList();
    } else if (_filterPurchased == true && _filterUnpurchased != true) {
      result = result.where((item) => item['purchased'] == true).toList();
    }

    if (_selectedSort == 'newest') {
      result.sort((a, b) => b['date'].compareTo(a['date']));
    } else if (_selectedSort == 'oldest') {
      result.sort((a, b) => a['date'].compareTo(b['date']));
    } else if (_selectedSort == 'high') {
      result.sort((a, b) {
        final aPrice = int.tryParse(a['price'].toString().replaceAll(' ', '')) ?? 0;
        final bPrice = int.tryParse(b['price'].toString().replaceAll(' ', '')) ?? 0;
        return bPrice.compareTo(aPrice);
      });
    } else if (_selectedSort == 'low') {
      result.sort((a, b) {
        final aPrice = int.tryParse(a['price'].toString().replaceAll(' ', '')) ?? 0;
        final bPrice = int.tryParse(b['price'].toString().replaceAll(' ', '')) ?? 0;
        return aPrice.compareTo(bPrice);
      });
    }
    return result;
  }
  
  String? _selectedFilterCategory;
  bool? _filterUnpurchased;
  bool? _filterPurchased;
  String _selectedSort = 'newest';
  bool _hasActiveFilter = false;

  @override
  Widget build(BuildContext context) {

    final purchases = context.watch<PurchasesProvider>().purchases;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text(
          'My purchases',
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: 'SF Pro Display',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.watch<PurchasesProvider>().purchases.isEmpty
                        ? const Color(0xFF252B35)
                        : const Color(0x4DFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          CupertinoIcons.search,
                          color: AppColors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 8,),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onTap: () => setState(() => _isSearchiing = true),
                            onChanged: (value) => setState(() {}),
                            style: const TextStyle(
                              color: AppColors.textOnDark,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _searchController.clear()),
                          child: const Padding(
                            padding: EdgeInsetsGeometry.only(right: 8),
                            child: Icon(
                              Icons.cancel,
                              color: AppColors.grey,
                              size: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                if (!_isSearchiing) ...[
                  const SizedBox(width: 8),
                _iconButton('assets/icons/ic_filter.svg'),
                const SizedBox(width: 8),
                _iconButton('assets/icons/ic_sort.svg'),
              ],
              if (_isSearchiing)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSearchiing = false;
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: AppSizes.fontBody,
                    ),
                  )
                )
                
              ],
            ),
          ),
          Expanded(
            child: purchases.isEmpty
                ? _buildEmptyState()
                : _filteredPurchases(purchases).isEmpty
                  ? const Center(
                    child: Text(
                      'No result',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        color: Color(0x99FFFFFF),
                        fontSize: AppSizes.fontButton,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ) : _buildPurchaseList(purchases),
          ),
          if (_currentIndex == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async{
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddItemScreen()),
                  );
                  if (result != null) {
                    context.read<PurchasesProvider>().addPurchase(result);
                  }
                },
                child: const Text(
                  '+ Add item',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    
    );
  }
  // исправлен параметр String вместо IconData
  Widget _iconButton(String iconPath) {
    final isFilter = iconPath.contains('filter');
    final hasActive = isFilter ? _hasActiveFilter : _hasActiveSort;

    return GestureDetector(
      onTap: () => isFilter ? _showFilterSheet() : _showSortSheet(),
      child: Stack(
        children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.read<PurchasesProvider>().purchases.isEmpty
            ? const Color(0xFF252B35)
            : Color(0x4DFFFFFF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                AppColors.grey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (hasActive)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Color(0xFFD33636),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/empty.json',
          width: 220,
          height: 220,
          repeat: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Your purchases\nwill be displayed here',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: AppColors.grey,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseList(List<Map<String, dynamic>> purchases) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: _filteredPurchases(purchases).length,
      separatorBuilder: (_,_) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = _filteredPurchases(purchases)[index];
        return _buildPurchaseCard(item);
      },
    );
  }

  Widget _buildPurchaseCard(Map<String, dynamic> item) {
    
  String formatPrice(dynamic price) {
  // 1. Санды алуу
  String rawPrice = price?.toString() ?? '0';
  String cleanPrice = rawPrice.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleanPrice.isEmpty) cleanPrice = '0';
  
  // 2. Intке айландыруу
  int amount = int.tryParse(cleanPrice) ?? 0;
  
  // 3. 3ке бөлүп форматтоо (пробел менен)
  String formatted = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]} '
  ).trim();
  
  return formatted;
}
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditItemScreen(
              item: item, 
              itemIndex: context.read<PurchasesProvider>().purchases.toList().indexOf(item),
            ),
          ),
        );

        if (result == null) return;

        if (result['action'] == 'save') {
          context.read<PurchasesProvider>().updatePurchase(result['index'], result['item']);
        } else if (result['action'] == 'delete') {
          context.read<PurchasesProvider>().deletePurchase(result['index']);
        }
      },
      child: Container(
        height: 92,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF334132C7),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item['image'] != null
              ? kIsWeb
                ? Image.memory(item['image'] as Uint8List, width: 60, height: 60, fit: BoxFit.cover,)
                : Image.file(File(item['image']), width: 60, height: 60, fit: BoxFit.cover,)
              : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item['purchased'] == true)...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5,),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Purchased',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          color: Color(0xFF36C23B),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 14 * 0.02,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    item['name']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 20,
                      letterSpacing: 14 * 0.02,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    item['category']?.toString() ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${formatPrice(item['price'])}',
                  style: const TextStyle(
                    color: AppColors.textOnDark,
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 14 * 0.02,
                  ),
                ),
                Text(
                  item['date']?.toString() ?? '',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 14 * 0.02,
                    fontFamily: 'SF Pro Display',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showFilterSheet() {
    String? tempCategory = _selectedFilterCategory;
    bool tempUnpurchased = _filterUnpurchased ?? false;
    bool tempPurchased = _filterPurchased ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20),),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        tempCategory = null;
                        tempUnpurchased = false;
                        tempPurchased = false;
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: Color(0xffD33636),
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.fontButton,
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Filter',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontFamily: "SF Pro Text",
                        fontWeight: FontWeight.w500,
                        fontSize: AppSizes.fontButton,
                        letterSpacing: 14 * 0.02,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                    CupertinoIcons.clear_circled, 
                    color: AppColors.grey,
                    size: 33,
                  ),
                  )
                ],
              ),
              const SizedBox(height: 16,),

              const Text(
                'Category',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w500,
                  fontSize: AppSizes.fontButton,
                  letterSpacing: 14 * 0.02,
                ),
              ),
              const SizedBox(height: 13,),
              Wrap(
                spacing: 9,
                runSpacing: 8,
                children: AppStrings.categories.map((cat) {
                  final isSelected = tempCategory == cat;
                  return GestureDetector(
                    onTap: () => setModalState(() => 
                        tempCategory = isSelected ? null : cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                          ? AppColors.primary
                          : const Color(0xFF33FFFFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                ? Colors.white
                                : AppColors.textOnDark,
                              fontSize: AppSizes.fontL,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 4,),
                            const Icon(
                              Icons.close,
                                color: Colors.white,
                                size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16,),
              const Text(
                'Purchase status',
                style: TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: AppSizes.fontButton,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SF Pro Display',
                  letterSpacing: 14 * 0.02,
                ),
              ),
              const SizedBox(height: 12,),
              Row(
              children: [
                _filterCheckbox(
                  label: 'Unpurchased',
                  isChecked: tempUnpurchased,
                  checkedColor: const Color(0xFFD33636),
                  onTap: () => setModalState(
                      () => tempUnpurchased = !tempUnpurchased),
                ),
                const SizedBox(width: 24),
                _filterCheckbox(
                  label: 'Purchased',
                  isChecked: tempPurchased,
                  checkedColor: AppColors.primary,
                  onTap: () => setModalState(
                      () => tempPurchased = !tempPurchased),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Apply кнопка
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (tempCategory != null ||
                          tempUnpurchased ||
                          tempPurchased)
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {
                    _selectedFilterCategory = tempCategory;
                    _filterUnpurchased = tempUnpurchased ? true : null;
                    _filterPurchased = tempPurchased ? true : null;
                    _hasActiveFilter = tempCategory != null ||
                        tempUnpurchased ||
                        tempPurchased;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Apply',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }

 void _showSortSheet() {
  String tempSort = _selectedSort;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text('Sort',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textOnDark,
                        fontSize: AppSizes.fontButton,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 14 * 0.02,
                      )),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(
                    CupertinoIcons.clear_circled, 
                    color: AppColors.grey,
                    size: 33,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sort опциялары
            ...[
              ('newest', 'Newest'),
              ('oldest', 'Oldest'),
              ('high', 'Price: High to low'),
              ('low', 'Price: Low to high'),
            ].map((option) {
              final isSelected = tempSort == option.$1;
              return GestureDetector(
                // ДОБАВИЛИ: активдүүнү кайра басса — тандоо жок болот
                onTap: () => setModalState(() =>
                    tempSort = isSelected ? '' : option.$1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(option.$2,
                            style: const TextStyle(
                              color: AppColors.textOnDark,
                              fontSize: AppSizes.fontButton,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'SF Pro Display',
                              letterSpacing: 14 * 0.02,
                            ),
                          ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            // Apply
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tempSort.isNotEmpty
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  setState(() {
                    _selectedSort = tempSort;
                    _hasActiveSort = tempSort.isNotEmpty && tempSort != 'newest';
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Apply',
                    style: TextStyle(
                      fontSize: AppSizes.fontButton,
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 14 * 0.02,
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  Widget _filterCheckbox({
  required String label,
  required bool isChecked,
  required Color checkedColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isChecked ? checkedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isChecked ? checkedColor : AppColors.grey,
              width: 1.5,
            ),
          ),
          child: isChecked
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
              color: isChecked ? AppColors.textOnDark : AppColors.grey,
              fontSize: 16,
              fontFamily: 'SF Pro Display',
            )),
      ],
    ),
  );
}
}

Widget _buildPlaceholder() {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: const Color(0xFF252B35),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.image_outlined, color: Colors.grey),
  );
}