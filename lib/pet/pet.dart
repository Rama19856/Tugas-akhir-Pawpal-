// lib/pet.dart
import 'dart:typed_data';
import 'dart:convert'; // Untuk base64Encode/Decode jika imageBytes digunakan
import 'package:uuid/uuid.dart'; // Pastikan package 'uuid' ada di pubspec.yaml

// Pastikan Anda telah menambahkan package uuid di pubspec.yaml:
// dependencies:
//   flutter:
//   uuid: ^4.0.0 # atau versi terbaru yang stabil

class Pet {
  final String id;
  String category;
  String name;
  String gender;
  String age;
  String breed;
  String address;
  String description;
  String? imagePath; // For mobile/desktop file path
  Uint8List? imageBytes; // For web (base64 decoded bytes)
  bool isFavorite; // New field for favorit

  Pet({
    String? id, // ID opsional saat membuat baru, akan di-generate jika null
    required this.name,
    this.category = 'Dogs', // Sesuaikan default category jika 'Adopsi Hewan'
    required this.gender,
    required this.age,
    required this.breed,
    required this.address,
    required this.description,
    this.imagePath,
    this.imageBytes,
    this.isFavorite = false, // Default to false
  }) : id = id ?? const Uuid().v4(); // Generate ID unik jika tidak disediakan

  // Convert Pet object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'name': name,
      'gender': gender,
      'age': age,
      'breed': breed,
      'address': address,
      'description': description,
      'imagePath': imagePath,
      // Encode Uint8List to base64 String for storage
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null,
      'isFavorite': isFavorite,
    };
  }

  // Create Pet object from JSON Map
  factory Pet.fromJson(Map<String, dynamic> json) {
    Uint8List? bytes;
    if (json['imageBytes'] != null) {
      try {
        bytes = base64Decode(json['imageBytes']);
      } catch (e) {
        print("Error decoding imageBytes from JSON: $e");
        bytes = null;
      }
    }
    return Pet(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      age: json['age'] as String,
      breed: json['breed'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      imagePath: json['imagePath'] as String?,
      imageBytes: bytes,
      isFavorite: json['isFavorite'] as bool? ?? false, // Handle null case
    );
  }

  // Metode copyWith
  Pet copyWith({
    String? id,
    String? category,
    String? name,
    String? gender,
    String? age,
    String? breed,
    String? address,
    String? description,
    String? imagePath,
    Uint8List? imageBytes,
    bool? isFavorite,
  }) {
    return Pet(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      address: address ?? this.address,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      imageBytes: imageBytes ?? this.imageBytes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}