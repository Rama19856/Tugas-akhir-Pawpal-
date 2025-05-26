import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/account_screen.dart';
import '../profile/addpet_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePageScreen extends StatefulWidget {
  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  String _selectedCategory = 'Dogs';
  String _location = 'Indonesia';
  String _searchText = '';
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _filteredPets = [];
  int _currentCarouselIndex = 0;
  PageController _pageController = PageController(initialPage: 0);
  String _userName = 'Pengguna'; // Default name
  String _greeting = '';
  List<String> _carouselImages = [
    'assets/carousel1.png',
    'assets/carousel2.png',
    'assets/carousel3.png',
  ];
  List<String> _favoritePosts = [];

  int _currentIndex = 0;
  Timer? _carouselTimer;
  late DateTime _promoEndTime;
  String _timeRemaining = '';
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print("[HomePage Lifecycle] initState called. Calling _loadAllData().");
    _loadAllData();
    _setupTimers();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("[HomePage Lifecycle] App resumed (from background/other app). Reloading all data.");
      Future.delayed(Duration(milliseconds: 100), () {
        _loadAllData();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _promoTimer?.cancel();
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    print("--- [HomePage] Starting _loadAllData... ---");
    setState(() {
      _isLoading = true;
      _pets = []; // Clear current pets to ensure fresh load
      _filteredPets = []; // Clear current filtered pets
    });

    try {
      await _loadPets();
      await _loadFavorites();
      await _loadPromoEndTime();
      await _loadUserName(); // Memuat nama pengguna
      _updateGreeting();

      // Ensure filter is applied after all pets are loaded
      _applyFilterAndSearch();
    } catch (e) {
      print("ERROR [HomePage] Error during _loadAllData: $e");
    } finally {
      setState(() {
        _isLoading = false;
        print("--- [HomePage] _loadAllData completed. Total pets loaded: ${_pets.length}, Filtered pets: ${_filteredPets.length} ---");
        if (_filteredPets.isNotEmpty) {
          print("[HomePage] First filtered pet (for verification): ${_filteredPets.first['name']} (ID: ${_filteredPets.first['id']})");
        }
      });
    }
  }

  void _setupTimers() {
    _promoTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      _updateTimeRemaining();
    });
    _carouselTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentCarouselIndex < _carouselImages.length - 1) {
          _currentCarouselIndex++;
        } else {
          _currentCarouselIndex = 0;
        }
        _pageController.animateToPage(
          _currentCarouselIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> _loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsData = prefs.getStringList('pets') ?? [];
    List<Map<String, dynamic>> tempPets = [];
    print("[HomePage][LoadPets] Raw pets data from SharedPreferences (string list, length: ${petsData.length}): $petsData");

    for (var petString in petsData) {
      try {
        final decoded = json.decode(petString);
        tempPets.add({
          'id': decoded['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          'category': decoded['category'] ?? 'Unknown',
          'name': decoded['name'] ?? 'Unknown Pet',
          'gender': decoded['gender'] ?? 'Unknown',
          'age': decoded['age'] ?? 'Unknown',
          'breed': decoded['breed'] ?? 'Unknown',
          'address': decoded['address'] ?? 'Unknown',
          'description': decoded['description'] ?? 'No description.',
          'imagePath': decoded['imagePath'],
          'imageBytes': decoded['imageBytes'],
        });
      } catch (e) {
        print("ERROR [HomePage][LoadPets] Failed to decode pet data from SharedPreferences: $e for string: $petString");
      }
    }

    _pets = tempPets;
    print("[HomePage][LoadPets] Pets loaded into _pets list. Total pets: ${_pets.length}");
  }

  Future<void> _savePets() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final petsData = _pets.map((pet) => json.encode(pet)).toList();
      await prefs.setStringList('pets', petsData);
      print("[HomePage][SavePets] Pets saved successfully. Total pets: ${_pets.length}");
    } catch (e) {
      print("ERROR [HomePage][SavePets] Failed to save pets to SharedPreferences: $e");
    }
  }

  void _applyFilterAndSearch() {
    setState(() {
      _filteredPets = _pets.where((pet) {
        final matchesCategory = (pet['category'] ?? 'Unknown') == _selectedCategory;
        final matchesSearch = _searchText.isEmpty ||
                              (pet['name'] ?? '').toLowerCase().contains(_searchText.toLowerCase()) ||
                              (pet['breed'] ?? '').toLowerCase().contains(_searchText.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
      print("[HomePage][Filter] Filtered pets (Category: '$_selectedCategory', Search: '$_searchText'): ${_filteredPets.length} pets.");
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'Pengguna'; // Default "Pengguna" jika tidak ada
      print("[HomePage][LoadUserName] User name loaded: $_userName");
    });
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 10) {
      setState(() { _greeting = 'Selamat Pagi!'; });
    } else if (hour >= 10 && hour < 18) {
      setState(() { _greeting = 'Selamat Siang!'; });
    } else if (hour >= 18 && hour < 22) {
      setState(() { _greeting = 'Selamat Malam!'; });
    } else {
      setState(() { _greeting = 'Selamat Tidur!'; });
    }
  }

  Future<void> _loadPromoEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    final endTimeString = prefs.getString('promoEndTime');
    if (endTimeString != null) {
      _promoEndTime = DateTime.parse(endTimeString);
      if (_promoEndTime.isBefore(DateTime.now())) {
        _resetPromoEndTime();
      }
    } else {
      _resetPromoEndTime();
    }
    _updateTimeRemaining();
  }

  Future<void> _resetPromoEndTime() async {
    _promoEndTime = DateTime.now().add(Duration(hours: 24));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('promoEndTime', _promoEndTime.toIso8601String());
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final difference = _promoEndTime.difference(now);
    if (difference.isNegative) {
      setState(() { _timeRemaining = 'Promo Berakhir!'; });
      _promoTimer?.cancel();
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;
      setState(() {
        _timeRemaining = '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePosts = prefs.getStringList('favorite_posts') ?? [];
      print("[HomePage][LoadFavorites] Favorites loaded: $_favoritePosts");
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_posts', _favoritePosts);
    print("[HomePage][SaveFavorites] Favorites saved: $_favoritePosts");
  }

  Future<void> _searchData(String query) async {
    setState(() {
      _isLoading = true;
      _searchText = query;
      print("[HomePage][Search] Search text changed to: '$_searchText'");
    });
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      _applyFilterAndSearch();
      _isLoading = false;
    });
  }

  void _toggleFavorite(String postId) {
    setState(() {
      if (_favoritePosts.contains(postId)) {
        _favoritePosts.remove(postId);
        print("[HomePage][Favorite] Removed from favorites: $postId");
      } else {
        _favoritePosts.add(postId);
        print("[HomePage][Favorite] Added to favorites: $postId");
      }
      _saveFavorites();
    });
  }

  Widget _buildPetItem(Map<String, dynamic> pet) {
    final isFavorite = _favoritePosts.contains(pet['id']);
    return GestureDetector(
      onTap: () {
        _showPetDetails(context, pet);
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: _getImageWidget(pet),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          pet['name'] ?? 'Nama Tidak Ada',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleFavorite(pet['id']);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Jenis Kelamin: ${pet['gender'] ?? 'Tidak Ada'}',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getImageWidget(Map<String, dynamic> pet) {
    Key imageKey = ValueKey('pet_image_${pet['id']}');

    if (kIsWeb && pet['imageBytes'] != null && (pet['imageBytes'] as String).isNotEmpty) {
      try {
        final decodedBytes = base64Decode(pet['imageBytes']);
        return Image.memory(
          decodedBytes,
          key: imageKey,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            print("ERROR [Image Widget] Image.memory failed for web (ID: ${pet['id']}): $error");
            return _buildDefaultImagePlaceholder();
          },
        );
      } catch (e) {
        print("ERROR [Image Widget] Failed to decode imageBytes for web (ID: ${pet['id']}): $e");
        return _buildDefaultImagePlaceholder();
      }
    } else if (!kIsWeb && pet['imagePath'] != null && (pet['imagePath'] as String).isNotEmpty) {
      final file = File(pet['imagePath']);
      if (file.existsSync()) {
        return Image.file(
          file,
          key: imageKey,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) {
            print("ERROR [Image Widget] Image.file failed for non-web (ID: ${pet['id']}): $error");
            return _buildDefaultImagePlaceholder();
          },
        );
      } else {
        print("[Image Widget] Image file DOES NOT exist at path: ${pet['imagePath']} (ID: ${pet['id']})");
        return _buildDefaultImagePlaceholder();
      }
    }
    print("[Image Widget] No valid image data for pet (ID: ${pet['id']}). Showing placeholder.");
    return _buildDefaultImagePlaceholder();
  }

  Widget _buildDefaultImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(child: Icon(Icons.pets, size: 50, color: Colors.grey)),
    );
  }

  void _showPetDetails(BuildContext context, Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: _getImageWidget(pet),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(Icons.favorite, color: _favoritePosts.contains(pet['id']) ? Colors.red : Colors.white),
                        onPressed: () {
                          _toggleFavorite(pet['id']);
                          Navigator.pop(context);
                          _showPetDetails(context, pet);
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? 'Nama Tidak Ada',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildDetailRow('Kategori', pet['category'] ?? 'Tidak Ada'),
                      _buildDetailRow('Jenis Kelamin', pet['gender'] ?? 'Tidak Ada'),
                      _buildDetailRow('Usia', pet['age'] ?? 'Tidak Ada'),
                      _buildDetailRow('Ras', pet['breed'] ?? 'Tidak Ada'),
                      _buildDetailRow('Alamat', pet['address'] ?? 'Tidak Ada'),
                      SizedBox(height: 10),
                      Text(
                        'Deskripsi:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(pet['description'] ?? 'Tidak Ada Deskripsi'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            child: Text('Edit', style: TextStyle(color: Colors.blue)),
                            onPressed: () {
                              Navigator.pop(context);
                              _editPet(pet);
                            },
                          ),
                          TextButton(
                            child: Text('Hapus', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              _deletePet(pet['id']);
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text('Tutup'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editPet(Map<String, dynamic> pet) async {
    print("[HomePage] Navigating to edit pet with ID: ${pet['id']}");
    final updatedPet = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPetScreen(),
        settings: RouteSettings(arguments: pet),
      ),
    );
    if (updatedPet != null) {
      print("[HomePage] Received updated pet data: $updatedPet");
      _loadAllData();
    } else {
      print("[HomePage] No pet data returned from Edit screen (user cancelled or no changes).");
    }
  }

  void _deletePet(String id) async {
    setState(() {
      _pets.removeWhere((pet) => pet['id'] == id);
      _favoritePosts.remove(id);
    });
    await _savePets();
    await _saveFavorites();
    _applyFilterAndSearch();
    print("[HomePage] Pet with ID $id deleted and UI updated. Total pets: ${_pets.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Utama', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              print("[HomePage] Navigating to AddPetScreen to add new pet (from AppBar).");
              final newPet = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddPetScreen()),
              );
              if (newPet != null) {
                print("[HomePage] Returned from AddPetScreen with new pet data. Reloading all data.");
                _loadAllData();
              } else {
                print("[HomePage] No new pet returned from AddPetScreen (user cancelled or no data).");
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Displaying the user's name from SharedPreferences
                GestureDetector(
                  onTap: () {}, // Perhaps navigate to a dedicated profile view later
                  child: Row(
                    children: [
                      // Using a simple person icon for now
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text(
                        _userName, // Display dynamic user name
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _showLocationMenu(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on),
                      Text(_location),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _showSearchDialog(context);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This greeting already uses _userName, so it's good
                  Text(
                    'Hai $_userName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(_greeting),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _carouselImages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image(
                            image: AssetImage(_carouselImages[index]),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          if (index == 0)
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'Berakhir: $_timeRemaining',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                onPageChanged: (int index) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryItem('Dogs', 'assets/dog.png'),
                  _buildCategoryItem('Cats', 'assets/Cat.png'),
                  _buildCategoryItem('Birds', 'assets/bird.png'),
                  _buildCategoryItem('Rabbits', 'assets/rabbit.png'),
                ],
              ),
            ),
            SizedBox(height: 20),
            _filteredPets.isEmpty
                ? Center(child: Text('Tidak ada hewan ditemukan di kategori ini atau hasil pencarian.'))
                : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: _filteredPets.length,
              itemBuilder: (context, index) {
                return _buildPetItem(_filteredPets[index]);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              print("[HomePage] BottomNav Home tapped. Reloading all data.");
              _loadAllData();
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/marketplace');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 3:
              print("[HomePage] Navigating to AccountScreen via BottomNav.");
              // Passing current favorites list to AccountScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(favoritePosts: _favoritePosts),
                ),
              ).then((_) {
                // This will be called when AccountScreen is popped
                print("[HomePage] Returned from AccountScreen. Calling _loadAllData() to refresh UI.");
                _loadAllData(); // Reload all data including potentially updated name or profile picture
              });
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

  Widget _buildCategoryItem(String category, String imagePath) {
    bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = category;
                _applyFilterAndSearch();
                print("[HomePage] Selected category: $_selectedCategory. Re-applying filter.");
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? Colors.red : Colors.grey[300],
              foregroundColor: isSelected ? Colors.white : Colors.black,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              children: [
                Image.asset(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                Text(category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Indonesia'),
              onTap: () {
                setState(() { _location = 'Indonesia'; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('USA'),
              onTap: () {
                setState(() { _location = 'USA'; });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Japan'),
              onTap: () {
                setState(() { _location = 'Japan'; });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    TextEditingController _searchDialogController = TextEditingController(text: _searchText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cari Hewan Peliharaan'),
          content: TextField(
            controller: _searchDialogController,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Masukkan nama atau ras'),
            onSubmitted: (text) {
              _searchData(text);
              Navigator.of(context).pop();
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cari'),
              onPressed: () {
                _searchData(_searchDialogController.text);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                _searchData('');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}