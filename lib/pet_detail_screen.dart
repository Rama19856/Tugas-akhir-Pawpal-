// lib/pet_detail_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pawpal/pet.dart'; // Pastikan model Pet diimpor dengan benar
import 'package:pawpal/pet_storage_service.dart'; // Pastikan PetStorageService diimpor dengan benar

class PetDetailScreen extends StatefulWidget {
  final Pet pet;

  PetDetailScreen({required this.pet});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final PetStorageService _petStorageService = PetStorageService();
  late Pet _currentPet;

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;
  }

  Widget _buildImage() {
    // Menggunakan Hero widget untuk transisi gambar yang mulus
    return Hero(
      tag: _currentPet.id, // Tag harus unik, gunakan ID pet
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: SizedBox(
          width: double.infinity,
          height: 300, // Tinggi gambar disesuaikan
          child: kIsWeb && _currentPet.imageBytes != null && _currentPet.imageBytes!.isNotEmpty
              ? Image.memory(
                  _currentPet.imageBytes!,
                  fit: BoxFit.cover,
                )
              : (!kIsWeb && _currentPet.imagePath != null && File(_currentPet.imagePath!).existsSync()
                  ? Image.file(
                      File(_currentPet.imagePath!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.pets, size: 80, color: Colors.grey)),
                    )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background keseluruhan
      // Hapus bottomNavigationBar dari sini
      // bottomNavigationBar: BottomNavigationBar(...)
      body: Stack(
        children: [
          // Background Merah di bagian atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350, // Sesuaikan tinggi background merah
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
          ),
          // Gambar Hewan di dalam background merah
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildImage(),
          ),
          // Custom AppBar (tetap di dalam Stack untuk overlay)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, // Padding atas
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context, true); // Kembali dan beri sinyal untuk reload data
                    },
                  ),
                ),
                const Text(
                  'Pet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Icon placeholder (bisa diganti dengan icon edit/delete jika diperlukan)
                const SizedBox(width: 40),
              ],
            ),
          ),
          // Konten Utama Pet Detail (menggunakan SingleChildScrollView)
          Positioned.fill(
            top: 320, // Posisi start konten putih
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0), // Padding bawah agar tombol terlihat jelas
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.only(top: 0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentPet.name,
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _currentPet.address,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                      ),
                                      // Karena lokasi sudah digabung dengan teks, kita bisa hapus yang ini jika tidak ada info "tahun" lagi.
                                      // Jika (5) adalah usia, sesuaikan
                                      // const SizedBox(width: 4),
                                      // Text(
                                      //   '(${_currentPet.age.split(' ')[0]})', // Ambil angka usia saja jika formatnya "X tahun"
                                      //   style: TextStyle(color: Colors.grey[700], fontSize: 16),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await _petStorageService.toggleFavorite(_currentPet.id);
                                  setState(() {
                                    // Perbarui status isFavorite pada objek _currentPet
                                    _currentPet = _currentPet.copyWith(
                                        isFavorite: !_currentPet.isFavorite);
                                  });
                                },
                                child: Icon(
                                  _currentPet.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: _currentPet.isFavorite ? Colors.red : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Chip Gender
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentPet.gender == 'Male' ? 'Male Sex' : 'Female Sex',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Chip Usia
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentPet.age,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Chip Breed (jika ada data breed yang terpisah)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _currentPet.breed, // Atau data lain yang relevan
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey[200],
                                    // Ganti dengan gambar profil owner jika ada
                                    child: const Icon(Icons.person, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Janihshhh', // Nama owner hardcoded, ganti dengan data pet jika ada
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Previous Owner',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                                            SizedBox(width: 4),
                                            Text('London', style: TextStyle(color: Colors.grey)), // Lokasi owner hardcoded
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Ikon chat dan telepon yang lebih kecil agar mirip gambar
                                  // Menggunakan InkWell untuk efek visual saat ditekan
                                  InkWell(
                                    onTap: () { /* Aksi untuk chat */ },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.chat_bubble_outline, color: Colors.blue, size: 24),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  InkWell(
                                    onTap: () { /* Aksi untuk telepon */ },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.call, color: Colors.green, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Details',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currentPet.description,
                            textAlign: TextAlign.justify,
                            maxLines: 4, // Tampilkan beberapa baris saja
                            overflow: TextOverflow.ellipsis,
                          ),
                          TextButton(
                            onPressed: () {
                              // Aksi untuk "See More" (bisa buka dialog atau halaman baru dengan deskripsi lengkap)
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Full Description'),
                                  content: SingleChildScrollView(
                                    child: Text(_currentPet.description),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Text(
                              'See More',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Spasi sebelum tombol aksi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0), // Padding horizontal untuk tombol
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                            onPressed: () {
                              // Aksi chat
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Aksi Adopt Now
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Anda ingin mengadopsi ${_currentPet.name}!') ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Adopt now',
                              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Spasi di bagian paling bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}