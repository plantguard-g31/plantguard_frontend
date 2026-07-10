import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_colors.dart';

class HistoryDetailScreen extends StatefulWidget {
  final String historyId;

  const HistoryDetailScreen({
    super.key,
    required this.historyId,
  });

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<Map<String, dynamic>> detailFuture;

  @override
  void initState() {
    super.initState();
    detailFuture = ApiService.getHistoryDetail(widget.historyId);
  }

  String cleanText(dynamic value, {String fallback = 'Not available'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text.replaceAll('__', ' ').replaceAll('_', ' ');
  }

  String formatConfidence(dynamic value) {
    if (value == null) return '0.0%';

    double number = 0;

    if (value is num) {
      number = value.toDouble();
    } else {
      number = double.tryParse(value.toString()) ?? 0;
    }

    if (number <= 1) {
      number = number * 100;
    }

    return '${number.toStringAsFixed(1)}%';
  }

  String formatDate(dynamic value) {
    if (value == null) return 'Date not available';

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return 'Date not available';
    }
  }

  Color severityColor(String severity) {
    final value = severity.toLowerCase();

    if (value == 'severe') return Colors.redAccent;
    if (value == 'moderate') return Colors.orangeAccent;
    if (value == 'mild') return AppColors.green;

    return AppColors.labelColor;
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
          'History Detail',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: detailFuture,
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

          final data = snapshot.data ?? {};

          final treatment = data['treatment'] is Map<String, dynamic>
              ? data['treatment'] as Map<String, dynamic>
              : <String, dynamic>{};

          final disease = cleanText(
            data['disease_label'] ?? data['disease'],
            fallback: 'Unknown Disease',
          );

          final crop = cleanText(
            data['crop_type'] ?? data['crop'],
            fallback: 'Unknown Crop',
          ).toUpperCase();

          final severity = cleanText(
            data['severity'],
            fallback: 'Not assigned',
          );

          final confidence = formatConfidence(data['confidence']);
          final diagnosedAt = formatDate(data['diagnosed_at']);
          final severityChipColor = severityColor(severity);

          final preHarvestValue =
              treatment['pre_harvest_interval_days'] ??
              data['pre_harvest_interval_days'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainCard(
                  disease: disease,
                  crop: crop,
                  confidence: confidence,
                  severity: severity,
                  severityColor: severityChipColor,
                  diagnosedAt: diagnosedAt,
                ),

                const SizedBox(height: 18),

                const Text(
                  'Treatment Recommendation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                _buildInfoCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Pesticide / Treatment',
                  value: cleanText(
                    treatment['pesticide_name'] ??
                        treatment['pesticide'] ??
                        data['pesticide'],
                  ),
                ),

                _buildInfoCard(
                  icon: Icons.science_outlined,
                  title: 'Dosage',
                  value: cleanText(
                    treatment['dosage'] ?? data['dosage'],
                  ),
                ),

                _buildInfoCard(
                  icon: Icons.schedule,
                  title: 'Application Timing',
                  value: cleanText(
                    treatment['application_timing'] ??
                        data['application_timing'],
                  ),
                ),

                _buildInfoCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Safety Instructions',
                  value: cleanText(
                    treatment['safety_instructions'] ??
                        data['safety_instructions'],
                  ),
                ),

                _buildInfoCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Pre-Harvest Interval',
                  value: preHarvestValue == null
                      ? 'Not available'
                      : '${cleanText(preHarvestValue)} days',
                ),

                _buildInfoCard(
                  icon: Icons.link,
                  title: 'Source Reference',
                  value: cleanText(
                    treatment['source_reference'] ??
                        data['source_reference'],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard({
    required String disease,
    required String crop,
    required String confidence,
    required String severity,
    required Color severityColor,
    required String diagnosedAt,
  }) {
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
          const Icon(
            Icons.local_florist,
            color: AppColors.green,
            size: 42,
          ),

          const SizedBox(height: 14),

          Text(
            disease,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '$crop • $diagnosedAt',
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _buildChip(
                text: confidence,
                color: AppColors.green,
              ),
              const SizedBox(width: 10),
              _buildChip(
                text: severity,
                color: severityColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 24,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
              onPressed: () {
                setState(() {
                  detailFuture =
                      ApiService.getHistoryDetail(widget.historyId);
                });
              },
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}