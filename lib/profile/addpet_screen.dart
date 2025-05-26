// lib/addpet_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
// import 'dart:convert'; // Tidak lagi diperlukan di sini karena Pet model yang menanganinya

// Import model dan service yang sudah direvisi
import '../pet/pet.dart'; // Menggunakan pet.dart Anda (pastikan path ini benar)
import '../pet/pet_storage_service.dart'; // Pastikan path ini benar

class AddPetScreen extends StatefulWidget {
  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  File? _imageFile; // Untuk mobile/desktop
  Uint8List? _imageBytesForWeb; // Untuk web (langsung Uint8List)

  String selectedCategory = 'Dogs'; // Kategori default
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Pet? _editingPet; // Untuk mode edit
  final PetStorageService _petService = PetStorageService(); // Gunakan PetService

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _editingPet = Pet.fromJson(args); // Konversi Map ke objek Pet
        _populateFields();
      }
    });
  }

  void _populateFields() {
    if (_editingPet != null) {
      setState(() {
        selectedCategory = _editingPet!.category;
        petNameController.text = _editingPet!.name;
        genderController.text = _editingPet!.gender;
        ageController.text = _editingPet!.age;
        breedController.text = _editingPet!.breed;
        addressController.text = _editingPet!.address;
        descriptionController.text = _editingPet!.description;

        if (kIsWeb && _editingPet!.imageBytes != null) {
          _imageBytesForWeb = _editingPet!.imageBytes; // Langsung pakai Uint8List dari model
          _imageFile = null;
          print("[AddPetScreen][Populate] Populated imageBytes for web (length: ${_imageBytesForWeb?.length ?? 0})");
        } else if (!kIsWeb && _editingPet!.imagePath != null) {
          try {
            final file = File(_editingPet!.imagePath!);
            if (file.existsSync()) {
              _imageFile = file;
              _imageBytesForWeb = null;
              print("[AddPetScreen][Populate] Populated image from file path: ${_imageFile!.path}");
            } else {
              print("[AddPetScreen][Populate] Image file DOES NOT exist at path: ${_editingPet!.imagePath}");
              _imageFile = null;
            }
          } catch (e) {
            print("[AddPetScreen][Populate] Error loading image file from path: $e");
            _imageFile = null;
          }
        } else {
          print("[AddPetScreen][Populate] No image data to populate.");
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _imageBytesForWeb = result.files.first.bytes; // Langsung simpan bytes
            _imageFile = null; // Ensure File is null for web
            print("[AddPetScreen][PickImage] Image picked for web. Bytes length: ${_imageBytesForWeb?.length ?? 0}");
          });
        }
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _imageBytesForWeb = null; // Ensure Bytes is null for non-web
            print("[AddPetScreen][PickImage] Image picked for non-web. Path: ${_imageFile?.path}");
          });
        }
      }
    } catch (e) {
      print('[AddPetScreen][PickImage] Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _imageBytesForWeb != null && _imageBytesForWeb!.isNotEmpty) {
      return Image.memory(_imageBytesForWeb!, height: 100, width: 100, fit: BoxFit.cover);
    } else if (!kIsWeb && _imageFile != null && _imageFile!.existsSync()) {
      return Image.file(_imageFile!, height: 100, width: 100, fit: BoxFit.cover);
    } else {
      return Container(
        height: 100,
        width: 100,
        color: Colors.grey[200],
        child: const Center(child: Text('Belum ada gambar', textAlign: TextAlign.center, style: TextStyle(fontSize: 12))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingPet != null ? 'Edit Hewan Peliharaan' : 'Tambah Hewan Peliharaan'),
        backgroundColor: Colors.red,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/cha.jpg'), // Pastikan aset ini ada
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Pilih Kategori',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 20),
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(labelText: 'Nama Hewan'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: genderController,
                    decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: 'Usia'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: breedController,
                    decoration: const InputDecoration(labelText: 'Ras'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                  const SizedBox(height: 20),
                  _buildImagePreview(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (petNameController.text.isEmpty ||
                          genderController.text.isEmpty ||
                          ageController.text.isEmpty ||
                          breedController.text.isEmpty ||
                          addressController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          (_imageFile == null && _imageBytesForWeb == null)) { // Periksa _imageBytesForWeb untuk web
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap isi semua field dan pilih gambar')),
                        );
                        print("[AddPetScreen] Validation failed: Some fields are empty or no image selected.");
                        return;
                      }

                      final Pet petToSave = Pet(
                        id: _editingPet?.id ?? const Uuid().v4(), // Gunakan Uuid().v4() untuk ID baru
                        category: selectedCategory,
                        name: petNameController.text,
                        gender: genderController.text,
                        age: ageController.text,
                        breed: breedController.text,
                        address: addressController.text,
                        description: descriptionController.text,
                        imagePath: kIsWeb ? null : _imageFile?.path,
                        imageBytes: kIsWeb ? _imageBytesForWeb : null, // Langsung simpan Uint8List
                        isFavorite: _editingPet?.isFavorite ?? false, // Maintain favorite status
                      );

                      print("[AddPetScreen] Constructed petData to save: ${petToSave.toJson()}");

                      if (_editingPet != null) {
                        await _petService.updatePet(petToSave);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hewan berhasil diupdate!')),
                        );
                        print("[AddPetScreen] Updated existing pet with ID: ${petToSave.id}");
                      } else {
                        await _petService.addPet(petToSave);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Hewan berhasil ditambahkan!')),
                        );
                        print("[AddPetScreen] Added new pet with ID: ${petToSave.id}");
                      }

                      // Mengembalikan objek Pet yang sudah diupdate/ditambahkan ke HomePageScreen
                      // Ini akan memicu refresh di HomePageScreen
                      Navigator.pop(context, petToSave.toJson());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_editingPet != null ? 'Update Hewan' : 'Tambah Hewan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, String imagePath) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedCategory = category;
                print("[AddPetScreen] Selected category: $selectedCategory");
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
}