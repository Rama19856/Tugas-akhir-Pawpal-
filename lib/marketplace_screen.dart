// lib/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:pawpal/addpet_screen.dart';
import 'package:pawpal/homepage_screen.dart';
import 'package:pawpal/pet.dart';
import 'package:pawpal/pet_storage_service.dart';
import 'package:pawpal/product_management.dart'; // Import ini untuk Product, ProductStorageService, dan AddProductScreen
import 'package:pawpal/product_detail_screen.dart'; // Import halaman detail produk baru
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pawpal/pet_detail_screen.dart';
import 'package:pawpal/product_managemnet.dart'; // <--- PASTIKAN PATH INI BENAR SESUAI LOKASI FILE ANDA

class MarketplaceScreen extends StatefulWidget {
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'Adopsi Hewan'; // Default selected category
  List<Pet> _allPets = [];
  List<Product> _allProducts = []; // List to store all products
  List<dynamic> _displayItems = []; // Combined list for display (Pets or Products)
  final PetStorageService _petStorageService = PetStorageService();
  final ProductStorageService _productStorageService = ProductStorageService(); // Product storage service

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load both pets and products
  }

  Future<void> _loadItems() async {
    await _loadPets();
    await _loadProducts(); // Load products
    _updateDisplayItems(); // Update the list based on selected category
  }

  Future<void> _loadPets() async {
    final loadedPets = await _petStorageService.loadPets();
    setState(() {
      _allPets = loadedPets;
    });
    print("[MarketplaceScreen] Loaded ${_allPets.length} pets from SharedPreferences.");
  }

  Future<void> _loadProducts() async {
    final loadedProducts = await _productStorageService.loadProducts();
    setState(() {
      _allProducts = loadedProducts;
    });
    print("[MarketplaceScreen] Loaded ${_allProducts.length} products from SharedPreferences.");
  }

  void _updateDisplayItems() {
    setState(() {
      if (_selectedCategory == 'Adopsi Hewan') {
        _displayItems = List.from(_allPets)..shuffle();
        print("[MarketplaceScreen] Displaying ${_displayItems.length} shuffled pets for Adopsi Hewan.");
      } else {
        _displayItems = List.from(_allProducts); // Display products for 'Kebutuhan'
        print("[MarketplaceScreen] Displaying ${_displayItems.length} products for Kebutuhan.");
      }
    });
  }

  Widget _buildImage(dynamic item, {double size = 100}) {
    String? imagePath;
    Uint8List? imageBytes;

    if (item is Pet) {
      imagePath = item.imagePath;
      imageBytes = item.imageBytes;
    } else if (item is Product) {
      imagePath = item.imagePath;
      imageBytes = item.imageBytes;
    }

    if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
      return Image.memory(imageBytes, height: size, width: size, fit: BoxFit.cover);
    } else if (!kIsWeb && imagePath != null && File(imagePath!).existsSync()) {
      return Image.file(File(imagePath), height: size, width: size, fit: BoxFit.cover);
    } else {
      return Container(
        height: size,
        width: size,
        color: Colors.grey[200],
        child: Icon(item is Pet ? Icons.pets : Icons.shopping_bag, size: size * 0.5, color: Colors.grey),
      );
    }
  }

  // Metode _showPetDetailsDialog ini TIDAK dihapus,
  // tetapi tidak akan dipanggil lagi untuk navigasi utama kartu hewan peliharaan.
  // Ini tetap ada jika ada bagian lain dari kode Anda yang masih memanggilnya,
  // namun Anda mungkin ingin menghapusnya jika sudah tidak digunakan sama sekali.
  void _showPetDetailsDialog(Pet pet) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: _buildImage(pet, size: double.infinity),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(pet.gender.toLowerCase() == 'male' ? Icons.male : (pet.gender.toLowerCase() == 'female' ? Icons.female : Icons.question_mark),
                              color: pet.gender.toLowerCase() == 'male' ? Colors.blue : (pet.gender.toLowerCase() == 'female' ? Colors.pink : Colors.grey)),
                          const SizedBox(width: 4),
                          Text(pet.gender),
                          const SizedBox(width: 16),
                          const Icon(Icons.cake_outlined, size: 20),
                          const SizedBox(width: 4),
                          Text(pet.age),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 4),
                          Text(pet.address),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(pet.description),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              pet.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: pet.isFavorite ? Colors.red : null,
                              size: 30,
                            ),
                            onPressed: () async {
                              await _petStorageService.toggleFavorite(pet.id);
                              Navigator.of(context).pop(); // Tutup dialog
                              _loadPets(); // Muat ulang pets untuk refresh status favorit
                            },
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.of(context).pop(); // Tutup dialog detail
                              final updatedPetResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPetScreen(),
                                  settings: RouteSettings(arguments: pet), // Pass the Pet object for editing
                                ),
                              );
                              if (updatedPetResult == true) {
                                _loadPets(); // Muat ulang data jika ada perubahan
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final confirmDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: const Text('Apakah Anda yakin ingin menghapus hewan ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmDelete == true) {
                                await _petStorageService.deletePet(pet.id);
                                Navigator.of(context).pop(); // Tutup dialog detail
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Hewan berhasil dihapus!')),
                                );
                                _loadPets(); // Muat ulang data setelah dihapus
                              }
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Hapus'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedCategory == 'Kebutuhan') // Show add button only for 'Kebutuhan'
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.black),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
                if (result == true) {
                  _loadItems(); // Reload all items to update the product list
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Adopsi Hewan';
                          _updateDisplayItems();
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Adopsi Hewan',
                            style: TextStyle(
                              color: _selectedCategory == 'Adopsi Hewan'
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          if (_selectedCategory == 'Adopsi Hewan')
                            Container(
                              width: 80,
                              height: 2,
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Kebutuhan';
                          _updateDisplayItems();
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            'Kebutuhan',
                            style: TextStyle(
                              color: _selectedCategory == 'Kebutuhan'
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          if (_selectedCategory == 'Kebutuhan')
                            Container(
                              width: 80,
                              height: 2,
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayItems.isEmpty
                ? Center(
                    child: Text(
                      _selectedCategory == 'Adopsi Hewan'
                          ? 'Tidak ada hewan untuk adopsi. Tambahkan beberapa di profil Anda!'
                          : 'Belum ada produk di kategori ini. Tambahkan produk baru!',
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8, // Disesuaikan agar lebih proporsional
                      ),
                      itemCount: _displayItems.length,
                      itemBuilder: (context, index) {
                        final item = _displayItems[index];
                        return GestureDetector(
                          // --- Bagian yang diubah dimulai di sini ---
                          onTap: () async {
                            if (item is Pet) {
                              // Navigasi ke PetDetailScreen saat mengetuk kartu hewan peliharaan
                              final bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PetDetailScreen(pet: item), // Meneruskan objek Pet
                                ),
                              );
                              // Muat ulang item jika ada perubahan (misalnya favorit atau hapus) dari PetDetailScreen
                              if (result == true) {
                                _loadItems();
                              }
                            } else if (item is Product) {
                              // Navigasi ke ProductDetailScreen untuk produk (fungsi yang sudah ada)
                              final bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: item),
                                ),
                              );
                              if (result == true) {
                                _loadItems();
                              }
                            }
                          },
                          // --- Bagian yang diubah berakhir di sini ---
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                        child: Hero( // Tambahkan Hero Widget di sini
                                          tag: item.id, // Tag harus unik untuk setiap item (pet atau product)
                                          child: _buildImage(item, size: double.infinity),
                                        ),
                                      ),
                                      if (item is Pet) // Only show favorite icon for pets
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await _petStorageService.toggleFavorite(item.id);
                                              _loadItems(); // Muat ulang untuk update UI favorit
                                            },
                                            child: Icon(
                                              item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: item.isFavorite ? Colors.red : Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      if (item is Pet) // Only show gender icon for pets
                                        Positioned(
                                          bottom: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.white70,
                                            child: Icon(
                                              item.gender.toLowerCase() == 'male' ? Icons.male : (item.gender.toLowerCase() == 'female' ? Icons.female : Icons.question_mark),
                                              size: 18,
                                              color: item.gender.toLowerCase() == 'male' ? Colors.blue : (item.gender.toLowerCase() == 'female' ? Colors.pink : Colors.grey),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item is Pet ? item.name : (item as Product).name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (item is Pet)
                                        Text(
                                          '${item.breed}, ${item.age}',
                                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      if (item is Product)
                                        Text(
                                          item.price,
                                          style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        item is Pet ? item.address : (item as Product).address,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
        currentIndex: 1, // Set the initial index to Marketplace
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/homepage');
              break;
            case 1:
            // Marketplace is already selected, do nothing or refresh
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/account');
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
}