import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_colors.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedCrop = 'all';
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? analyticsData;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await ApiService.getAnalytics(
        cropType: selectedCrop == 'all' ? null : selectedCrop,
      );

      if (!mounted) return;

      setState(() {
        analyticsData = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  void changeCrop(String crop) {
    if (selectedCrop == crop) return;

    setState(() {
      selectedCrop = crop;
    });

    loadAnalytics();
  }

  int intValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String cleanDiseaseName(dynamic value) {
    if (value == null) return 'Not available';

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return 'Not available';
    }

    return text
        .replaceAll('__', ' ')
        .replaceAll('_', ' ')
        .replaceAll('  ', ' ');
  }

  String cropLabel(String crop) {
    if (crop == 'all') return 'All';
    if (crop == 'tomato') return 'Tomato';
    if (crop == 'potato') return 'Potato';
    if (crop == 'bell_pepper') return 'Bell Pepper';
    return crop;
  }

  List<dynamic> diseaseFrequencyList(Map<String, dynamic> data) {
    final value = data['disease_frequency'];

    if (value is List) {
      return value;
    }

    return [];
  }

  Map<String, dynamic> spreadingAlert(Map<String, dynamic> data) {
    final value = data['spreading_alert'];

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {
      'triggered': false,
      'disease_label': null,
      'count': 0,
    };
  }

  String spreadingAlertMessage(Map<String, dynamic> alert) {
    final backendMessage = alert['message_en'];

    if (backendMessage != null &&
        backendMessage.toString().trim().isNotEmpty) {
      return backendMessage.toString();
    }

    final disease = cleanDiseaseName(
      alert['disease_name'] ?? alert['disease_label'],
    );

    final count = intValue(alert['count']);

    return 'Spreading disease alert: $disease has been detected $count times in the last 30 days.';
  }

  int maxDiseaseCount(List<dynamic> diseaseList) {
    int max = 0;

    for (final item in diseaseList) {
      if (item is Map) {
        final count = intValue(item['count']);
        if (count > max) {
          max = count;
        }
      }
    }

    return max == 0 ? 1 : max;
  }

  double healthScore(Map<String, dynamic> data) {
    final total = intValue(data['total_diagnoses']);
    final healthy = intValue(data['healthy_count']);

    if (total == 0) return 0;

    return healthy / total;
  }

  String healthStatus(double score) {
    if (score >= 0.75) return 'Good Health';
    if (score >= 0.45) return 'Needs Attention';
    return 'High Risk';
  }

  Color healthStatusColor(double score) {
    if (score >= 0.75) return AppColors.green;
    if (score >= 0.45) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String trendInsight(Map<String, dynamic> data) {
    final healthy = intValue(data['healthy_count']);
    final diseased = intValue(data['diseased_count']);
    final total = intValue(data['total_diagnoses']);

    if (total == 0) {
      return 'No diagnosis trend is available yet.';
    }

    if (diseased > healthy) {
      return 'Diseased scans are higher than healthy scans this month. Check nearby plants and follow treatment early.';
    }

    if (healthy > diseased) {
      return 'Your crop health looks better this month. Keep monitoring regularly.';
    }

    return 'Healthy and diseased scans are balanced this month. Continue scanning to track changes.';
  }

  String recommendationText(Map<String, dynamic> data) {
    final total = intValue(data['total_diagnoses']);
    final diseased = intValue(data['diseased_count']);
    final mostCommon = cleanDiseaseName(data['most_common_disease']);

    if (total == 0) {
      return 'Start by scanning affected leaves to build your crop health record.';
    }

    if (diseased == 0) {
      return 'No disease pattern detected. Keep scanning weekly to monitor your crops.';
    }

    if (mostCommon != 'Not available') {
      return 'Most common issue is $mostCommon. Check nearby plants and use the treatment guide if symptoms match.';
    }

    return 'Disease signs were found. Review your history and follow recommended treatment for each diagnosis.';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Plant Analytics',
            style: TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.green,
            labelColor: AppColors.green,
            unselectedLabelColor: AppColors.labelColor,
            tabs: [
              Tab(
                icon: Icon(Icons.dashboard_outlined),
                text: 'Overview',
              ),
              Tab(
                icon: Icon(Icons.bug_report_outlined),
                text: 'Diseases',
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildCropFilterTabs(),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      )
                    : errorMessage != null
                        ? _buildErrorPage()
                        : TabBarView(
                            children: [
                              _buildOverviewPage(),
                              _buildDiseasePage(),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _cropButton('all'),
          _cropButton('tomato'),
          _cropButton('potato'),
          _cropButton('bell_pepper'),
        ],
      ),
    );
  }

  Widget _cropButton(String crop) {
    final bool isSelected = selectedCrop == crop;

    return GestureDetector(
      onTap: () => changeCrop(crop),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.borderColor,
          ),
        ),
        child: Text(
          cropLabel(crop),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewPage() {
    final data = analyticsData ?? {};
    final totalDiagnoses = intValue(data['total_diagnoses']);
    final healthyCount = intValue(data['healthy_count']);
    final diseasedCount = intValue(data['diseased_count']);
    final alert = spreadingAlert(data);
    final alertTriggered = alert['triggered'] == true;
    final score = healthScore(data);

    if (totalDiagnoses == 0) {
      return _scrollPage(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildEmptyState(),
        ],
      );
    }

    return _scrollPage(
      children: [
        _buildHeaderCard(),

        const SizedBox(height: 16),

        if (alertTriggered) ...[
          _buildSpreadingAlertBanner(alert),
          const SizedBox(height: 16),
        ],

        _buildHealthScoreCard(score),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _summaryBox(
                title: 'Total',
                value: totalDiagnoses.toString(),
                icon: Icons.analytics_outlined,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryBox(
                title: 'Healthy',
                value: healthyCount.toString(),
                icon: Icons.check_circle_outline,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryBox(
                title: 'Diseased',
                value: diseasedCount.toString(),
                icon: Icons.bug_report_outlined,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildTrendInsightCard(data),

        const SizedBox(height: 16),

        _buildRecommendationCard(data),
      ],
    );
  }

  Widget _buildDiseasePage() {
    final data = analyticsData ?? {};
    final totalDiagnoses = intValue(data['total_diagnoses']);
    final mostCommon = cleanDiseaseName(data['most_common_disease']);
    final diseaseList = diseaseFrequencyList(data);

    if (totalDiagnoses == 0) {
      return _scrollPage(
        children: [
          _buildDiseaseHeaderCard(),
          const SizedBox(height: 16),
          _buildEmptyState(),
        ],
      );
    }

    return _scrollPage(
      children: [
        _buildDiseaseHeaderCard(),

        const SizedBox(height: 16),

        _buildMostCommonCard(mostCommon),

        const SizedBox(height: 16),

        _buildDiseaseFrequencyCard(diseaseList),
      ],
    );
  }

  Widget _scrollPage({required List<Widget> children}) {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: loadAnalytics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          ...children,
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.insights,
            color: AppColors.green,
            size: 44,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '30-Day Crop Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'See crop health score, recent activity, and alert status.',
                  style: TextStyle(
                    color: AppColors.labelColor,
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

  Widget _buildDiseaseHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.bug_report_outlined,
            color: Colors.orangeAccent,
            size: 44,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disease Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'View common diseases and how often they appeared.',
                  style: TextStyle(
                    color: AppColors.labelColor,
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

  Widget _buildSpreadingAlertBanner(Map<String, dynamic> alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3B1111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.crisis_alert,
            color: Colors.redAccent,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Spreading Alert',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  spreadingAlertMessage(alert),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
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

  Widget _buildHealthScoreCard(double score) {
    final percent = (score * 100).round();
    final color = healthStatusColor(score);
    final status = healthStatus(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score,
                  strokeWidth: 8,
                  color: color,
                  backgroundColor: AppColors.inputBg,
                ),
                Center(
                  child: Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crop Health Score',
                  style: TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Based on healthy and diseased diagnoses from the last 30 days.',
                  style: TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 12.5,
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

  Widget _summaryBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 26,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendInsightCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.trending_up,
            color: Colors.orangeAccent,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Disease Trend Insight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  trendInsight(data),
                  style: const TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMostCommonCard(String mostCommon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            color: Colors.orangeAccent,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Common Disease',
                  style: TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  mostCommon == 'Not available'
                      ? 'No disease found'
                      : 'Most common: $mostCommon',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
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

  Widget _buildDiseaseFrequencyCard(List<dynamic> diseaseList) {
    final maxCount = maxDiseaseCount(diseaseList);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.format_list_bulleted,
                color: AppColors.green,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Disease Frequency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (diseaseList.isEmpty)
            const Text(
              'No disease records found in the last 30 days.',
              style: TextStyle(
                color: AppColors.labelColor,
                fontSize: 13,
              ),
            )
          else
            ...List.generate(diseaseList.length, (index) {
              final item = diseaseList[index];

              String diseaseName = 'Unknown Disease';
              int count = 0;

              if (item is Map) {
                diseaseName = cleanDiseaseName(
                  item['disease_name'] ?? item['disease_label'],
                );
                count = intValue(item['count']);
              }

              final progress = count / maxCount;

              return _diseaseProgressRow(
                diseaseName: diseaseName,
                count: count,
                progress: progress,
                showBottomSpace: index != diseaseList.length - 1,
              );
            }),
        ],
      ),
    );
  }

  Widget _diseaseProgressRow({
    required String diseaseName,
    required int count,
    required double progress,
    required bool showBottomSpace,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpace ? 14 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  diseaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count times',
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              color: AppColors.green,
              backgroundColor: AppColors.inputBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13251B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_outlined,
            color: AppColors.green,
            size: 30,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Helpful Recommendation',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendationText(data),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.eco_outlined,
            color: AppColors.green,
            size: 54,
          ),
          SizedBox(height: 14),
          Text(
            'No diagnoses in the last 30 days.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Start scanning your plants!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPage() {
    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: loadAnalytics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ?? 'Failed to load analytics.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: loadAnalytics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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