import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'treatment_library_item_model.dart';

class TreatmentDetailScreen extends StatelessWidget {
  final TreatmentLibraryItemModel treatment;

  const TreatmentDetailScreen({
    super.key,
    required this.treatment,
  });

  Color severityColor(String severity) {
    final value = severity.toLowerCase();

    if (value.contains('severe')) {
      return Colors.redAccent;
    }

    if (value.contains('moderate')) {
      return Colors.orangeAccent;
    }

    if (value.contains('mild')) {
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

    if (crop.contains('bell') || crop.contains('pepper')) {
      return Icons.eco;
    }

    return Icons.spa;
  }

  String cleanText(String value) {
    final text = value.trim();

    if (text.isEmpty || text == 'null') {
      return 'Not available';
    }

    return text.replaceAll('__', ' ').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final color = severityColor(treatment.severity);

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
          'Treatment Detail',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(color),

            const SizedBox(height: 20),

            const Text(
              'Recommended Treatment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.medical_services_outlined,
              title: 'Pesticide Name',
              value: cleanText(treatment.pesticideName),
              isLarge: true,
            ),

            _buildInfoCard(
              icon: Icons.science_outlined,
              title: 'Dosage',
              value: cleanText(treatment.dosage),
              highlight: true,
            ),

            _buildInfoCard(
              icon: Icons.schedule,
              title: 'Application Timing',
              value: cleanText(treatment.applicationTiming),
            ),

            _buildInfoCard(
              icon: Icons.health_and_safety_outlined,
              title: 'Safety Instructions',
              value: cleanText(treatment.safetyInstructions),
            ),

            _buildInfoCard(
              icon: Icons.calendar_month_outlined,
              title: 'Pre-Harvest Interval',
              value: treatment.displayPreHarvestInterval,
            ),

            _buildInfoCard(
              icon: Icons.link,
              title: 'Source Reference',
              value: cleanText(treatment.sourceReference),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color severityChipColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            cropIcon(treatment.cropType),
            color: AppColors.green,
            size: 48,
          ),

          const SizedBox(height: 14),

          Text(
            treatment.displayDisease,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            treatment.displayCrop,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          _buildSeverityBadge(
            treatment.displaySeverity,
            severityChipColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '$text Severity',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    bool highlight = false,
    bool isLarge = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: highlight ? AppColors.green : AppColors.borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 25,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  value,
                  style: TextStyle(
                    color: highlight ? AppColors.green : Colors.white,
                    fontSize: isLarge ? 20 : 14.5,
                    fontWeight:
                        highlight || isLarge ? FontWeight.bold : FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}