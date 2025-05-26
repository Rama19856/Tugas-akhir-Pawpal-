// lib/pet_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal/pet.dart'; // Import kelas Pet dari file yang baru dibuat

class PetStorageService {
  static const String _petsKey = 'pets';

  Future<List<Pet>> loadPets() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> petsJson = prefs.getStringList(_petsKey) ?? [];
    return petsJson.map((s) => Pet.fromJson(json.decode(s) as Map<String, dynamic>)).toList();
  }

  Future<void> savePets(List<Pet> pets) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> petsJson = pets.map((pet) => json.encode(pet.toJson())).toList();
    await prefs.setStringList(_petsKey, petsJson);
    print("[PetStorageService] Successfully saved ${pets.length} pets to SharedPreferences.");
  }

  Future<void> addPet(Pet pet) async {
    final pets = await loadPets();
    pets.add(pet);
    await savePets(pets);
  }

  Future<void> updatePet(Pet updatedPet) async {
    final pets = await loadPets();
    final index = pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      pets[index] = updatedPet;
      await savePets(pets);
    } else {
      print("[PetStorageService] Pet with ID ${updatedPet.id} not found for update.");
    }
  }

  Future<void> deletePet(String petId) async {
    final pets = await loadPets();
    pets.removeWhere((p) => p.id == petId);
    await savePets(pets);
    print("[PetStorageService] Successfully deleted pet with ID: $petId");
  }

  Future<void> toggleFavorite(String petId) async {
    final pets = await loadPets();
    final index = pets.indexWhere((p) => p.id == petId);
    if (index != -1) {
      // Menggunakan copyWith untuk memperbarui objek Pet secara immutable
      pets[index] = pets[index].copyWith(isFavorite: !pets[index].isFavorite);
      await savePets(pets);
      print("[PetStorageService] Toggled favorite status for pet with ID: $petId to ${pets[index].isFavorite}");
    }
  }

  loadFavorites() {}

  loadUserName() {}
}