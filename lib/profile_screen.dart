import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'app_colors.dart';
import 'api_service.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import 'change_password_screen.dart';
import 'user_cache.dart';
import 'farmer_dashboard.dart';
import 'scan_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Loading...';
  String userEmail = '';
  String userRole = 'Farmer';
  String? profilePhotoUrl;

  bool isLoadingProfile = true;
  bool isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    loadCachedUser();
    loadUserProfile();
  }

  Future<void> loadCachedUser() async {
    final cached = await UserCache.getUser();

    if (!mounted) return;

    setState(() {
      userName = cached['name'] ?? 'User';
      profilePhotoUrl = cached['photo_url'];
    });
  }

  Future<void> loadUserProfile() async {
    try {
      final user = await ApiService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        userName = user['name'] ?? 'User';
        userEmail = user['email'] ?? '';
        userRole = user['role'] ?? 'Farmer';
        profilePhotoUrl = user['profile_picture_url'];
        isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
      });

      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> pickAndUploadProfilePhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? pickedImage = await picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (pickedImage == null) {
        return;
      }

      setState(() {
        isUploadingPhoto = true;
      });

      final uploadedUrl = await ApiService.uploadProfilePhoto(
        pickedImage.path,
      );

      if (!mounted) return;

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        setState(() {
          profilePhotoUrl = uploadedUrl;
          isUploadingPhoto = false;
        });

        await UserCache.saveUser(
          name: userName,
          photoUrl: uploadedUrl,
        );

        showMessage(
          'Profile photo updated successfully.',
          isError: false,
        );
      } else {
        setState(() {
          isUploadingPhoto = false;
        });

        showMessage(
          'Failed to upload profile photo.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUploadingPhoto = false;
      });

      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
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
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Take a new photo',
                  style: TextStyle(color: AppColors.labelColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadProfilePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.green,
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Choose from gallery',
                  style: TextStyle(color: AppColors.labelColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadProfilePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: AppColors.labelColor,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.labelColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void showLogoutLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
        );
      },
    );
  }

  Future<void> logoutUser() async {
    final confirmLogout = await showLogoutConfirmation();

    if (!confirmLogout) {
      return;
    }

    if (!mounted) return;

    showLogoutLoading();

    await Future.delayed(const Duration(seconds: 1));

    await ApiService.logout();

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void openChangePasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  void openHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoryScreen(),
      ),
    );
  }

  void openHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmerDashboardScreen(),
      ),
    );
  }

  void openScanScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  void handleBottomNavigation(int index) {
    if (index == 0) {
      openHomeScreen();
      return;
    }

    if (index == 1) {
      openScanScreen();
      return;
    }

    if (index == 2) {
      openHistoryScreen();
      return;
    }

    if (index == 3) {
      return;
    }
  }

  void showComingSoon(String featureName) {
    showMessage(
      '$featureName will be added later.',
      isError: false,
    );
  }

  void showMessage(
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.cardBg,
      ),
    );
  }

  String formatRole(String role) {
    if (role.isEmpty) return 'Farmer';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgDark,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.labelColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        onTap: handleBottomNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoadingProfile
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.green,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _buildProfileHeader(),

                    const SizedBox(height: 24),

                    _sectionTitle('Account'),

                    _profileTile(
                      icon: Icons.lock_outline,
                      title: 'Change Password',
                      iconColor: AppColors.green,
                      onTap: openChangePasswordScreen,
                    ),

                    _profileTile(
                      icon: Icons.history,
                      title: 'Diagnosis History',
                      iconColor: Colors.orangeAccent,
                      onTap: openHistoryScreen,
                    ),

                    _profileTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      iconColor: Colors.blueAccent,
                      trailing: 'Off',
                      onTap: () {
                        showComingSoon('Notifications');
                      },
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('Settings'),

                    _profileTile(
                      icon: Icons.language,
                      title: 'Language',
                      iconColor: Colors.purpleAccent,
                      trailing: 'English',
                      onTap: () {
                        showComingSoon('Language setting');
                      },
                    ),

                    _profileTile(
                      icon: Icons.info_outline,
                      title: 'About PlantGuard',
                      iconColor: Colors.white,
                      onTap: () {
                        showComingSoon('About PlantGuard');
                      },
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: logoutUser,
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'LOGOUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.green,
                backgroundImage:
                    profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(profilePhotoUrl!)
                        : null,
                child: profilePhotoUrl == null || profilePhotoUrl!.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 56,
                      )
                    : null,
              ),

              if (isUploadingPhoto)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.green,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploadingPhoto ? null : showImageOptions,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.bgDark,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            userEmail.isEmpty ? 'No email available' : userEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.labelColor,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF13251B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green),
            ),
            child: Text(
              formatRole(userRole),
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 14),

          TextButton.icon(
            onPressed: isUploadingPhoto ? null : showImageOptions,
            icon: const Icon(
              Icons.upload,
              color: AppColors.green,
              size: 18,
            ),
            label: const Text(
              'Upload Profile Photo',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.labelColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  color: AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right,
              color: AppColors.labelColor,
            ),
          ],
        ),
      ),
    );
  }
}