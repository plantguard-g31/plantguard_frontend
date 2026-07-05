import 'dart:convert';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'farmer_dashboard.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'user_cache.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'scan_screen.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = "Loading...";
  String userRole = "Farmer";
  File? selectedImage;
  String? profilePhotoUrl;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 1. show cached data instantly
    loadCachedUser();

    // 2. then refresh from API
    loadUserProfile();
  }

  // ---------------- CACHE LOAD ----------------
  Future<void> loadCachedUser() async {
    final cached = await UserCache.getUser();

    if (!mounted) return;

    setState(() {
      userName = cached['name'] ?? 'User';
      profilePhotoUrl = cached['profile_picture_url'];
    });
  }

  // ---------------- API LOAD ----------------
  Future<void> loadUserProfile() async {
    try {
      final user = await ApiService.getCurrentUser();
print("USER DATA: $user");
print("PHOTO URL: ${user['profile_picture_url']}");

      if (!mounted) return;

      setState(() {
        userName = user['name'] ?? 'User';
        userRole = user['role'] ?? 'Farmer';
        profilePhotoUrl = user['profile_picture_url'];
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        userName = "User";
        userRole = "Farmer";
      });
    }
  }

  // ---------------- IMAGE PICK ----------------
  Future<void> pickAndUploadImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });

    final photoUrl =
        await ApiService.uploadProfilePhoto(image.path);

    if (photoUrl != null) {
      await UserCache.saveUser(
        name: userName,
        photoUrl: photoUrl,
      );
    }

    await loadUserProfile();
  }

  // ---------------- IMAGE OPTIONS ----------------
  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: AppColors.green),
                title: const Text("Camera",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.green),
                title: const Text("Gallery",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- LOGOUT ----------------
  Future<void> logoutUser() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // ---------------- NAVIGATION ----------------
  void handleBottomNavigation(int index) {
  if (index == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmerDashboardScreen(),
      ),
    );
  }

  if (index == 1) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  if (index == 3) {
    return; // Already on Profile
  }
}

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.labelColor,
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        onTap: handleBottomNavigation,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: "Scan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      "PlantGuard",
      style: TextStyle(
        color: AppColors.green,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),

    CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.green,
      backgroundImage:
          profilePhotoUrl != null &&
                  profilePhotoUrl!.isNotEmpty
              ? CachedNetworkImageProvider(
                  profilePhotoUrl!,
                )
              : null,
      child: profilePhotoUrl == null ||
              profilePhotoUrl!.isEmpty
          ? const Icon(
              Icons.person,
              color: Colors.white,
            )
          : null,
    ),
  ],
),

              const SizedBox(height: 35),

              GestureDetector(
                onTap: showImageOptions,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.green,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : (profilePhotoUrl != null &&
                              profilePhotoUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(
                              profilePhotoUrl!,
                            )
                          : null,
                  child: selectedImage == null &&
                          (profilePhotoUrl == null ||
                              profilePhotoUrl!.isEmpty)
                      ? const Icon(Icons.person,
                          color: Colors.white, size: 58)
                      : null,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                userRole,
                style: const TextStyle(
                  color: AppColors.labelColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 35),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "SETTINGS",
                  style: TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              _profileTile(
                icon: Icons.notifications_none,
                title: "Notifications",
                iconColor: AppColors.green,
                trailing: "On",
              ),

              _profileTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                iconColor: AppColors.labelColor,
              ),

              _profileTile(
                icon: Icons.history,
                title: "History",
                iconColor: AppColors.labelColor,
              ),

              const SizedBox(height: 24),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "ACCOUNT",
                  style: TextStyle(
                    color: AppColors.labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: logoutUser,
                child: Container(
                  height: 58,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.borderColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 14),
                      Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    String? trailing,
  }) {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null)
            Text(trailing,
                style: const TextStyle(
                    color: AppColors.green)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right,
              color: AppColors.labelColor),
        ],
      ),
    );
  }
}