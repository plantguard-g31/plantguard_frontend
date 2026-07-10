import 'package:flutter/material.dart';
import 'app_colors.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosisResultScreen({
    super.key,
    required this.result,
  });

  String _text(dynamic value, {String fallback = 'Not available'}) {
    if (value == null) return fallback;

    final text = value.toString().trim();
    if (text.isEmpty || text == 'null') return fallback;

    return text;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _confidencePercent(dynamic value) {
    double confidence = _toDouble(value);

    if (confidence <= 1) {
      confidence = confidence * 100;
    }

    return '${confidence.toStringAsFixed(1)}%';
  }

  bool get _isHealthy {
    final value = result['is_healthy'];

    if (value is bool) return value;

    return value.toString().toLowerCase() == 'true';
  }

  String get _diseaseName {
    return _text(
      result['disease'] ?? result['disease_label'],
      fallback: 'Unknown Disease',
    );
  }

  String get _severity {
    return _text(result['severity'], fallback: 'Not assigned');
  }

  List<dynamic> get _topPredictions {
    final top3 = result['top3'] ?? result['top_3_predictions'];

    if (top3 is List) {
      return top3;
    }

    return [];
  }

  Map<String, dynamic>? get _spreadingAlert {
    final alert = result['spreading_alert'];

    if (alert is Map) {
      return Map<String, dynamic>.from(alert);
    }

    return null;
  }

  bool get _hasLowConfidenceWarning {
    final warning = result['low_confidence_warning'];

    if (warning == null) return false;

    return warning.toString().trim().isNotEmpty &&
        warning.toString().trim() != 'false';
  }

  String get _lowConfidenceMessage {
    final warning = result['low_confidence_warning'];

    if (warning is bool && warning == true) {
      return 'Confidence is low. Please retake a clearer photo or consult an expert.';
    }

    return _text(
      warning,
      fallback:
          'Confidence is low. Please retake a clearer photo or consult an expert.',
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
          'Diagnosis Result',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMainResultCard(),
              const SizedBox(height: 14),

              if (_hasLowConfidenceWarning) ...[
                _buildWarningCard(
                  title: 'Low Confidence Warning',
                  message: _lowConfidenceMessage,
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: 14),
              ],

              _buildQuickStats(),
              const SizedBox(height: 14),

              _buildTreatmentCard(),
              const SizedBox(height: 14),

              _buildTopPredictionsCard(),
              const SizedBox(height: 14),

              _buildSpreadingAlertCard(),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'SCAN ANOTHER PLANT',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _buildMainResultCard() {
    final statusText = _isHealthy ? 'Healthy Plant' : 'Disease Detected';
    final statusIcon = _isHealthy ? Icons.check_circle : Icons.bug_report;
    final statusColor = _isHealthy ? AppColors.green : Colors.orangeAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 58,
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _diseaseName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isHealthy
                ? 'Your plant looks healthy. Keep monitoring regularly.'
                : 'Disease signs were detected. Follow the recommended remedy below.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallInfoCard(
            title: 'Confidence',
            value: _confidencePercent(result['confidence']),
            icon: Icons.analytics_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallInfoCard(
            title: 'Severity',
            value: _severity,
            icon: Icons.local_fire_department_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard() {
    return _buildSectionCard(
      title: 'Remedy & Treatment Plan',
      icon: Icons.medical_services_outlined,
      children: [
        _buildDetailRow(
          title: 'Recommended Pesticide',
          value: _text(result['pesticide']),
        ),
        _buildDetailRow(
          title: 'Dosage',
          value: _text(result['dosage']),
        ),
        _buildDetailRow(
          title: 'Application Timing',
          value: _text(result['application_timing']),
        ),
        _buildDetailRow(
          title: 'Safety Instructions',
          value: _text(result['safety_instructions']),
        ),
        _buildDetailRow(
          title: 'Pre-Harvest Interval',
          value: result['pre_harvest_interval_days'] == null
              ? 'Not available'
              : '${result['pre_harvest_interval_days']} days',
        ),
        _buildDetailRow(
          title: 'Source Reference',
          value: _text(result['source_reference']),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildTopPredictionsCard() {
    if (_topPredictions.isEmpty) {
      return _buildSectionCard(
        title: 'Top Predictions',
        icon: Icons.format_list_numbered,
        children: const [
          Text(
            'No top predictions available.',
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return _buildSectionCard(
      title: 'Top 3 Predictions',
      icon: Icons.format_list_numbered,
      children: List.generate(_topPredictions.length, (index) {
        final item = _topPredictions[index];

        String disease = 'Unknown';
        String confidence = '0.0%';
        String rank = '${index + 1}';

        if (item is Map) {
          disease = _text(
            item['disease'] ?? item['label'] ?? item['disease_label'],
            fallback: 'Unknown',
          );

          confidence = _confidencePercent(item['confidence']);
          rank = _text(item['rank'], fallback: '${index + 1}');
        }

        return Container(
          margin: EdgeInsets.only(
            bottom: index == _topPredictions.length - 1 ? 0 : 10,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.green,
                child: Text(
                  rank,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  disease,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                confidence,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSpreadingAlertCard() {
    final alert = _spreadingAlert;

    if (alert == null) {
      return _buildSectionCard(
        title: 'Spreading Alert',
        icon: Icons.notifications_active_outlined,
        children: const [
          Text(
            'No spreading alert data available.',
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    final triggered = alert['triggered'] == true;
    final disease = _text(alert['disease_label'], fallback: 'this disease');
    final count = _text(alert['count'], fallback: '0');

    if (!triggered) {
      return _buildSectionCard(
        title: 'Spreading Alert',
        icon: Icons.notifications_active_outlined,
        children: const [
          Text(
            'No spreading disease alert found in your recent diagnosis history.',
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    return _buildWarningCard(
      title: 'Spreading Disease Alert',
      message:
          '$disease has appeared $count times in your recent diagnosis history. Please monitor nearby plants and take action early.',
      icon: Icons.crisis_alert,
    );
  }

  Widget _buildWarningCard({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orangeAccent,
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.green,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.green,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          const Divider(
            color: AppColors.borderColor,
            height: 1,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}