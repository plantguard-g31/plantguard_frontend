import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_colors.dart';
import 'models/history_item_model.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<HistoryItemModel>> historyFuture;

  @override
  void initState() {
    super.initState();
    historyFuture = ApiService.getHistoryList();
  }

  Future<void> refreshHistory() async {
    setState(() {
      historyFuture = ApiService.getHistoryList();
    });

    await historyFuture;
  }

  Color severityColor(String severity) {
    final value = severity.toLowerCase();

    if (value == 'severe') {
      return Colors.redAccent;
    }

    if (value == 'moderate') {
      return Colors.orangeAccent;
    }

    if (value == 'mild') {
      return AppColors.green;
    }

    return AppColors.labelColor;
  }

  IconData cropIcon(String cropType) {
    final crop = cropType.toLowerCase();

    if (crop.contains('tomato')) {
      return Icons.local_florist;
    }

    if (crop.contains('potato')) {
      return Icons.grass;
    }

    if (crop.contains('bell')) {
      return Icons.eco;
    }

    return Icons.spa;
  }

  void openHistoryDetail(HistoryItemModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(
          historyId: item.id,
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
          'Diagnosis History',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<HistoryItemModel>>(
        future: historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.green,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorView(
              snapshot.error.toString().replaceFirst('Exception: ', ''),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return _buildEmptyView();
          }

          return RefreshIndicator(
            color: AppColors.green,
            backgroundColor: AppColors.cardBg,
            onRefresh: refreshHistory,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                return _buildHistoryCard(items[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(HistoryItemModel item) {
    final color = severityColor(item.severity);

    return InkWell(
      onTap: () => openHistoryDetail(item),
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
                    ),
                  ),
                  const SizedBox(height: 7),
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
                      const CircleAvatar(
                        radius: 2.5,
                        backgroundColor: AppColors.labelColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.displayDate,
                          style: const TextStyle(
                            color: AppColors.labelColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      _buildChip(
                        text: item.displayConfidence,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        text: item.severity,
                        color: color,
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

  Widget _buildChip({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
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
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return RefreshIndicator(
      color: AppColors.green,
      backgroundColor: AppColors.cardBg,
      onRefresh: refreshHistory,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 110),
          Icon(
            Icons.history,
            color: AppColors.labelColor,
            size: 74,
          ),
          SizedBox(height: 18),
          Text(
            'No diagnoses yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap Scan to check your first plant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 56,
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
              onPressed: refreshHistory,
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