import 'package:flutter/material.dart';
import 'package:pawpal/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'addpet_screen.dart';
import 'favorite_screen.dart';
import 'homepage_screen.dart';
import 'cart_screen.dart'; // Add this line
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert'; // For base64 encoding/decoding
import 'package:pawpal/image_util.dart'; // Import ImageUtil

class AccountScreen extends StatefulWidget {
  final List<String> favoritePosts;

  AccountScreen({Key? key, required this.favoritePosts}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = 'Pengguna'; // Default name
  String? _profileImagePath; // For mobile/desktop
  String? _profileImageBytesBase64; // For web

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Pengguna';
      _profileImagePath = prefs.getString('profileImagePath');
      _profileImageBytesBase64 = prefs.getString('profileImageBytesBase64');
      print("[AccountScreen] User name loaded: $_userName");
      print("[AccountScreen] Profile image path loaded: $_profileImagePath");
      print("[AccountScreen] Profile image bytes (base64) loaded (length): ${_profileImageBytesBase64?.length ?? 0}");
    });
  }

  Future<void> _pickAndSaveProfileImage() async {
    final pickedImageResult = await ImageUtil.pickImage();
    if (pickedImageResult != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (kIsWeb) {
          _profileImageBytesBase64 = base64Encode(pickedImageResult['imageBytes']);
          _profileImagePath = null; // Clear path if on web
          prefs.setString('profileImageBytesBase64', _profileImageBytesBase64!);
          prefs.remove('profileImagePath'); // Remove old path if exists
          print("[AccountScreen] Web profile image saved (bytes length: ${pickedImageResult['imageBytes'].length}).");
        } else {
          _profileImagePath = pickedImageResult['imagePath'];
          _profileImageBytesBase64 = null; // Clear bytes if on mobile
          prefs.setString('profileImagePath', _profileImagePath!);
          prefs.remove('profileImageBytesBase64'); // Remove old bytes if exists
          print("[AccountScreen] Mobile profile image saved (path: $_profileImagePath).");
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto profil berhasil diperbarui!')),
      );
    } else {
      print("[AccountScreen] No profile image selected or pick cancelled.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 200,
            color: Colors.red,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickAndSaveProfileImage, // Panggil fungsi pilih gambar saat avatar disentuh
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ImageUtil.buildProfileImageWidget(
                          imagePath: _profileImagePath,
                          imageBytesBase64: _profileImageBytesBase64,
                          radius: 50,
                          defaultWidget: Icon(Icons.person, size: 50, color: Colors.grey), // Default icon
                        ),
                        // Overlay untuk ikon edit
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Icon(Icons.edit, size: 18, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userName, // Tampilkan nama dari SharedPreferences
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildMenuItem(context, 'Add pet', Icons.add, () async {
                      print("[AccountScreen] Navigating to AddPetScreen from Account.");
                      final addedOrUpdatedPet = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPetScreen(),
                        ),
                      );
                      if (addedOrUpdatedPet != null) {
                        print("[AccountScreen] Received data from AddPetScreen: $addedOrUpdatedPet. (HomePage will refresh on resume).");
                      } else {
                        print("[AccountScreen] AddPetScreen returned null. (User cancelled or no data).");
                      }
                    }),
                    _buildMenuItem(context, 'Favorites', Icons.favorite, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesScreen(favoritePosts: widget.favoritePosts),
                        ),
                      );
                    }),
                    _buildMenuItem(context, 'Profile', Icons.person, () {
                      // Implementasi untuk Profile
                    }),
                    _buildMenuItem(context, 'Cart', Icons.shopping_cart, () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => CartScreen(),
                   ),
                 );
               }),
                    _buildMenuItem(context, 'Settings', Icons.settings, () {
                      // Implementasi untuk Settings
                    }),
                    _buildMenuItem(context, 'Log out', Icons.logout, () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // Hapus semua data pengguna (termasuk nama dan foto profil)
                      print("[AccountScreen] User logged out. SharedPreferences cleared.");
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()), // Kembali ke login
                        (Route<dynamic> route) => false, // Hapus semua rute sebelumnya
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: 3, // Current index for AccountScreen
        onTap: (int index) {
          switch (index) {
            case 0:
              print("[AccountScreen] BottomNav Home tapped. Redirecting to HomePage.");
              Navigator.pushReplacementNamed(context, '/homepage');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/marketplace');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 3:
              // Already on Account, no need to navigate
              break;
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Marketplace',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}