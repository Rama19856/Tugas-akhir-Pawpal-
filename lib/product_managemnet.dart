// lib/product_management.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

// ===============================================
// DEFINISI KELAS PRODUCT (Tidak ada perubahan di sini, sudah benar)
// ===============================================
class Product {
  String id;
  String name;
  String category;
  String description;
  String price;
  String? imagePath;
  Uint8List? imageBytes; // Pastikan ini ada
  String address;
  List<String> options;
  int stock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.address,
    this.imagePath,
    this.imageBytes,
    this.options = const [],
    this.stock = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'imageBytes': imageBytes != null ? base64Encode(imageBytes!) : null, // Konversi Uint8List ke String Base64
      'address': address,
      'options': options,
      'stock': stock,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      price: json['price'],
      imagePath: json['imagePath'],
      imageBytes: json['imageBytes'] != null ? base64Decode(json['imageBytes']) : null, // Dekode dari String Base64
      address: json['address'],
      options: List<String>.from(json['options'] ?? []),
      stock: json['stock'] ?? 0,
    );
  }
}

// ===============================================
// DEFINISI PRODUCTSTORAGESERVICE (Tidak ada perubahan signifikan di sini)
// ===============================================
class ProductStorageService {
  static const String _productsKey = 'products';

  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? productsJson = prefs.getStringList(_productsKey);
    if (productsJson == null) {
      return [];
    }
    return productsJson.map((jsonString) {
      return Product.fromJson(json.decode(jsonString));
    }).toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> productsJson = products.map((product) {
      return json.encode(product.toJson());
    }).toList();
    await prefs.setStringList(_productsKey, productsJson);
  }

  Future<void> addProduct(Product product) async {
    final List<Product> products = await loadProducts();
    products.add(product);
    await saveProducts(products);
  }

  Future<void> updateProduct(Product updatedProduct) async {
    final List<Product> products = await loadProducts();
    final int index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
      await saveProducts(products);
    }
  }

  Future<void> deleteProduct(String productId) async {
    List<Product> products = await loadProducts();
    products.removeWhere((product) => product.id == productId);
    await saveProducts(products);
  }
}

// ===============================================
// DEFINISI ADDPRODUCTSCREEN (Revisi pada _pickImage dan _submitForm)
// ===============================================
class AddProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddProductScreen({Key? key, this.productToEdit}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _addressController = TextEditingController();
  final _optionsController = TextEditingController();
  final _stockController = TextEditingController();

  String? _imagePath;
  Uint8List? _imageBytes; // Pastikan ini ada
  final ProductStorageService _productStorageService = ProductStorageService();
  bool _isEditing = false;
  String _productId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _isEditing = true;
      _productId = widget.productToEdit!.id;
      _nameController.text = widget.productToEdit!.name;
      _categoryController.text = widget.productToEdit!.category;
      _descriptionController.text = widget.productToEdit!.description;
      _priceController.text = widget.productToEdit!.price;
      _addressController.text = widget.productToEdit!.address;
      _imagePath = widget.productToEdit!.imagePath;
      _imageBytes = widget.productToEdit!.imageBytes; // Pastikan ini dimuat
      _optionsController.text = widget.productToEdit!.options.join(', ');
      _stockController.text = widget.productToEdit!.stock.toString();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Baca bytes gambar terlepas dari platform (penting untuk penyimpanan)
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes; // Simpan bytes untuk persistent storage
        if (!kIsWeb) {
          _imagePath = image.path; // Simpan path jika bukan web
        } else {
          _imagePath = null; // Path tidak relevan di web
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final List<String> optionsList = _optionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final int parsedStock = int.tryParse(_stockController.text) ?? 0;

      final newProduct = Product(
        id: _productId,
        name: _nameController.text,
        category: _categoryController.text,
        description: _descriptionController.text,
        price: _priceController.text,
        address: _addressController.text,
        imagePath: _imagePath,
        imageBytes: _imageBytes, // Pastikan ini digunakan
        options: optionsList,
        stock: parsedStock,
      );

      if (_isEditing) {
        await _productStorageService.updateProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui!')),
        );
      } else {
        await _productStorageService.addProduct(newProduct);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
      }

      Navigator.pop(context, true);
    }
  }

  Widget _buildProductImage() {
    if (_imageBytes != null && _imageBytes!.isNotEmpty) {
      return Image.memory(_imageBytes!, height: 150, width: 150, fit: BoxFit.cover);
    } else if (!kIsWeb && _imagePath != null && File(_imagePath!).existsSync()) {
      return Image.file(File(_imagePath!), height: 150, width: 150, fit: BoxFit.cover);
    } else {
      return Container(
        height: 150,
        width: 150,
        color: Colors.grey[200],
        child: Icon(Icons.shopping_bag, size: 75, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Produk' : 'Tambah Produk Baru'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: _buildProductImage(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.text_fields),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori (misal: Makanan, Mainan, Perawatan)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Produk',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga (misal: Rp 50.000)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Lokasi Penjual',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _optionsController,
                decoration: InputDecoration(
                  labelText: 'Opsi Produk (pisahkan dengan koma, misal: Tuna, Salmon)',
                  hintText: 'Opsional',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok Produk',
                  hintText: 'Opsional (misal: 100)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.inventory),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Perbarui Produk' : 'Tambah Produk',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _addressController.dispose();
    _optionsController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}