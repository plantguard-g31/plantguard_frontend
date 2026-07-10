import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'app_colors.dart';
import 'api_service.dart';
import 'diagnosis_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1280,
      maxHeight: 1280,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  void removeSelectedImage() {
    setState(() {
      selectedImage = null;
    });
  }

  Future<void> diagnosePlant() async {
  if (selectedImage == null) {
    showError('Please select or capture a plant image first.');
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final result = await ApiService.diagnosePlantImage(
      imagePath: selectedImage!.path,
      cropType: 'tomato',
    );

    if (!mounted) return;

    print('DIAGNOSIS SUCCESS RESULT: $result');

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisResultScreen(
          result: result,
        ),
      ),
    );

    if (!mounted) return;

    // This clears the selected image when user comes back
    setState(() {
      selectedImage = null;
    });
  } catch (e) {
    if (!mounted) return;

    showError(
      e.toString().replaceFirst('Exception: ', ''),
    );
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.green,
                ),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Open camera',
                  style: TextStyle(color: AppColors.labelColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.green,
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Pick existing photo',
                  style: TextStyle(color: AppColors.labelColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildSelectedImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            selectedImage!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: isLoading ? null : removeSelectedImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.70),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
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
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: const Text(
          'Scan Plant',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco,
                      color: AppColors.green,
                      size: 46,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select Leaf Photo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Take or choose a clear photo of the plant leaf.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.labelColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => pickImage(ImageSource.camera),
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Camera',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => pickImage(ImageSource.gallery),
                            icon: const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.green,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Expanded(
                child: GestureDetector(
                  onTap: isLoading ? null : showImageOptions,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: selectedImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: AppColors.labelColor,
                                size: 64,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No photo selected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Tap here to choose photo',
                                style: TextStyle(
                                  color: AppColors.labelColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : buildSelectedImagePreview(),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              if (selectedImage != null)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : diagnosePlant,
                    icon: isLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.eco,
                            color: Colors.black,
                          ),
                    label: Text(
                      isLoading ? 'DIAGNOSING...' : 'DIAGNOSE THIS LEAF',
                      style: const TextStyle(
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
}