import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'app_colors.dart';
import 'api_service.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import 'user_cache.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  String userName = "Loading...";
  String? profilePhotoUrl;
  String userRole = "Loading...";

  @override
  void initState() {
    super.initState();

    // Load cached data instantly
    loadCachedUser();

    // Refresh from API
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
  print("STEP 1 - loadUserProfile started");

  try {
    final user = await ApiService.getCurrentUser();

    print("STEP 2 - API Success");
    print("USER DATA: $user");

    if (!mounted) return;

    setState(() {
      userName = user['name'] ?? 'User';
     
      profilePhotoUrl = user['profile_picture_url'];

      print("STEP 3 - State Updated");
      print("PHOTO URL: $profilePhotoUrl");
    });
  } catch (e) {
    print("PROFILE ERROR: $e");
  }
}

  void _handleBottomNavigation(int index) {
  if (index == 0) {
    return;
  }

  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScanScreen(),
      ),
    );
  }

  if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }
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
        currentIndex: 0,
        onTap: _handleBottomNavigation,
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "PlantGuard",
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
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
                              size: 22,
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                "FARMER DASHBOARD",
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Welcome, $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              _buildCard(
                icon: Icons.history,
                title: "History",
                iconColor: AppColors.green,
              ),

              const SizedBox(height: 12),

              _buildCard(
                icon: Icons.menu_book_outlined,
                title: "Guide",
                iconColor: Colors.blue,
              ),

              const SizedBox(height: 12),

              _buildCard(
                icon: Icons.info_outline,
                title: "About Us",
                iconColor: Colors.white,
              ),

              const SizedBox(height: 12),

              _buildCard(
                icon: Icons.medical_services_outlined,
                title: "Treatment",
                iconColor: Colors.amber,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ScanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "DIAGNOSE YOUR PLANT",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
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

  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor,
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.labelColor,
          size: 16,
        ),
        onTap: () {},
      ),
    );
  }
}