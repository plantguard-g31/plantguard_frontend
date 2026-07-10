import 'package:flutter/material.dart';

import 'app_colors.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

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
          'PlantGuard Guide',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),

              const SizedBox(height: 18),

              _sectionTitle(
                icon: Icons.auto_awesome,
                title: 'How It Works',
              ),

              const SizedBox(height: 10),

              _stepCard(
                number: '1',
                text: 'Take or upload a photo of the affected leaf.',
              ),
              _stepCard(
                number: '2',
                text: 'AI analyzes your photo in a few seconds.',
              ),
              _stepCard(
                number: '3',
                text:
                    'Get your diagnosis — disease name, confidence score, and severity.',
              ),
              _stepCard(
                number: '4',
                text:
                    'Follow the treatment we recommend for your crop.',
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                icon: Icons.camera_alt_outlined,
                title: 'Tips for a Better Diagnosis',
              ),

              const SizedBox(height: 10),

              _tipCard(
                icon: Icons.wb_sunny_outlined,
                text: 'Use natural daylight — avoid dark or shadowy areas.',
              ),
              _tipCard(
                icon: Icons.center_focus_strong,
                text: 'Focus on the affected leaf, not the whole plant.',
              ),
              _tipCard(
                icon: Icons.zoom_in,
                text: 'Fill the frame — get close and avoid blurry shots.',
              ),
              _tipCard(
                icon: Icons.filter_1,
                text:
                    'Photograph one leaf at a time for the clearest result.',
              ),
              _tipCard(
                icon: Icons.water_drop_outlined,
                text:
                    'Avoid wet, dusty, or damaged leaves if possible.',
              ),

              const SizedBox(height: 16),

              _photoExampleCard(),

              const SizedBox(height: 22),

              _sectionTitle(
                icon: Icons.analytics_outlined,
                title: 'Understanding Your Diagnosis',
              ),

              const SizedBox(height: 10),

              _resultInfoCard(
                icon: Icons.percent,
                title: 'Confidence Bar',
                description:
                    'Shows how sure PlantGuard is about the disease it found. Higher means more certain.',
              ),
              _resultInfoCard(
                icon: Icons.warning_amber_rounded,
                title: 'Severity Badge',
                description:
                    'Color-coded green, yellow, or red to show how serious the issue is at a glance.',
              ),
              _resultInfoCard(
                icon: Icons.medical_services_outlined,
                title: 'Treatment',
                description:
                    'Matched to both the disease and its severity, based on verified agricultural guidelines.',
              ),

              const SizedBox(height: 22),

              _sectionTitle(
                icon: Icons.help_outline,
                title: 'Frequently Asked Questions',
              ),

              const SizedBox(height: 10),

              _faqCard(
                question: 'What if my diagnosis seems wrong?',
                answer:
                    'Try retaking the photo in better lighting, focused on the affected area. If it still seems off, the disease may not be in our current database yet.',
              ),
              _faqCard(
                question: 'Do I need internet to use PlantGuard?',
                answer:
                    'Yes, an internet connection is required to analyze your photo and get a diagnosis.',
              ),
              _faqCard(
                question: 'Which crops does PlantGuard support?',
                answer:
                    'PlantGuard currently supports Tomato, Potato, and Pepper crops.',
              ),
              _faqCard(
                question: 'Is my diagnosis history saved?',
                answer:
                    'Yes, every diagnosis is automatically saved so you can track your crop health over time.',
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.eco,
            color: AppColors.green,
            size: 46,
          ),
          SizedBox(height: 14),
          Text(
            'Welcome to PlantGuard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Diagnose your crop in seconds using AI — no expert needed.',
            style: TextStyle(
              color: AppColors.labelColor,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.green,
          size: 22,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _stepCard({
    required String number,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.green,
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 24,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoExampleCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _photoExampleBox(
              icon: Icons.check_circle,
              title: 'Good Photo',
              subtitle: 'Clear, close, bright',
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _photoExampleBox(
              icon: Icons.cancel,
              title: 'Bad Photo',
              subtitle: 'Blurry, dark, far',
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoExampleBox({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
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
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
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

  Widget _faqCard({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          iconColor: AppColors.green,
          collapsedIconColor: AppColors.labelColor,
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: [
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.labelColor,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}