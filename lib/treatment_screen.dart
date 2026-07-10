import 'dart:async';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_colors.dart';
import 'treatment_library_item_model.dart';
import 'treatment_detail_screen.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  final searchController = TextEditingController();

  Future<List<TreatmentLibraryItemModel>>? treatmentFuture;

  Timer? searchDebounce;

  String selectedCrop = 'all';
  String selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    loadTreatments();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchDebounce?.cancel();
    super.dispose();
  }

  void loadTreatments() {
    String? cropType;

    if (selectedCrop == 'tomato') {
      cropType = 'tomato';
    } else if (selectedCrop == 'potato') {
      cropType = 'potato';
    } else if (selectedCrop == 'bell_pepper') {
      cropType = 'bell_pepper';
    }

    setState(() {
      treatmentFuture = ApiService.getTreatmentLibrary(
        cropType: cropType,
        search: searchController.text,
        lang: selectedLang,
      );
    });
  }

  void onSearchChanged(String value) {
    searchDebounce?.cancel();

    searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        loadTreatments();
      },
    );
  }

  void changeCropFilter(String crop) {
    setState(() {
      selectedCrop = crop;
    });

    loadTreatments();
  }

  Color severityColor(String severity) {
    final value = severity.toLowerCase();

    if (value.contains('severe')) return Colors.redAccent;
    if (value.contains('moderate')) return Colors.orangeAccent;
    if (value.contains('mild')) return AppColors.green;

    return AppColors.labelColor;
  }

  IconData cropIcon(String cropType) {
    final crop = cropType.toLowerCase();

    if (crop.contains('tomato')) return Icons.local_florist;
    if (crop.contains('potato')) return Icons.grass;
    if (crop.contains('bell') || crop.contains('pepper')) return Icons.eco;

    return Icons.spa;
  }

  void openTreatmentDetail(TreatmentLibraryItemModel treatment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentDetailScreen(
          treatment: treatment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Treatment Library',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search disease name...',
                    hintStyle: const TextStyle(
                      color: AppColors.hintColor,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.labelColor,
                    ),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              loadTreatments();
                            },
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.labelColor,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.inputBg,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterButton(
                        label: 'All',
                        value: 'all',
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        label: 'Tomato',
                        value: 'tomato',
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        label: 'Potato',
                        value: 'potato',
                      ),
                      const SizedBox(width: 8),
                      _filterButton(
                        label: 'Pepper',
                        value: 'bell_pepper',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<TreatmentLibraryItemModel>>(
              future: treatmentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.green,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _errorView(
                    snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', ''),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return _emptyView();
                }

                return RefreshIndicator(
                  color: AppColors.green,
                  backgroundColor: AppColors.cardBg,
                  onRefresh: () async {
                    loadTreatments();
                    await treatmentFuture;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (context, index) {
                      return _treatmentCard(items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required String value,
  }) {
    final isSelected = selectedCrop == value;

    return InkWell(
      onTap: () {
        changeCropFilter(value);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : AppColors.inputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _treatmentCard(TreatmentLibraryItemModel item) {
    final color = severityColor(item.severity);

    return InkWell(
      onTap: () {
        openTreatmentDetail(item);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Icon(
                cropIcon(item.cropType),
                color: AppColors.green,
                size: 26,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayDisease,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        item.displayCrop,
                        style: const TextStyle(
                          color: AppColors.labelColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _severityBadge(
                        item.displaySeverity,
                        color,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.labelColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              color: AppColors.labelColor,
              size: 72,
            ),
            SizedBox(height: 16),
            Text(
              'No treatments found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No treatments found for this search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.labelColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 58,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: loadTreatments,
              icon: const Icon(
                Icons.refresh,
                color: Colors.black,
              ),
              label: const Text(
                'TRY AGAIN',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}