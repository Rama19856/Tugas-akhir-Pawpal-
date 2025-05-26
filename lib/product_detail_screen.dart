// lib/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:pawpal/product_management.dart';
import 'package:pawpal/checkout_screen.dart';
import 'package:pawpal/product_managemnet.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductStorageService _productStorageService = ProductStorageService();
  int _currentImageIndex = 0;
  List<dynamic> _productImages = [];
  String? _selectedOption;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProductImages();
    if (widget.product.options.isNotEmpty) {
      _selectedOption = widget.product.options.first;
    }
  }

  void _loadProductImages() {
    _productImages = []; // Reset images

    // Tambahkan gambar utama jika ada
    if (widget.product.imageBytes != null && widget.product.imageBytes!.isNotEmpty) {
      _productImages.add(widget.product.imageBytes);
    } else if (!kIsWeb && widget.product.imagePath != null && File(widget.product.imagePath!).existsSync()) {
      _productImages.add(widget.product.imagePath);
    }

    // Jika tidak ada gambar, tambahkan placeholder
    if (_productImages.isEmpty) {
      _productImages.add(null);
    }
    // Tambahkan dummy images jika hanya ada satu dan kita ingin simulasi galeri
    // Hanya lakukan jika ada gambar utama
    if (_productImages.length == 1 && _productImages[0] != null) {
      // Duplikat gambar utama untuk simulasi galeri (jika hanya ada 1 gambar asli)
      _productImages.add(_productImages[0]);
      _productImages.add(_productImages[0]);
    }
  }

  // Fungsi _buildImage yang sama persis dengan di CheckoutScreen
  Widget _buildImage(dynamic imageData, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    if (kIsWeb && imageData is Uint8List && imageData.isNotEmpty) {
      return Image.memory(
        imageData,
        height: height,
        width: width,
        fit: fit,
      );
    } else if (!kIsWeb && imageData is String && File(imageData).existsSync()) {
      return Image.file(
        File(imageData),
        height: height,
        width: width,
        fit: fit,
      );
    } else if (imageData is Uint8List && imageData.isNotEmpty) {
      // Fallback for Uint8List on non-web
      return Image.memory(
        imageData,
        height: height,
        width: width,
        fit: fit,
      );
    } else {
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: Icon(Icons.shopping_bag, size: (height ?? 100) * 0.5, color: Colors.grey),
      );
    }
  }

  Future<void> _deleteProduct() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
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
      await _productStorageService.deleteProduct(widget.product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil dihapus!')),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _showBuyOptionsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImage(
                            _productImages.isNotEmpty ? _productImages[_currentImageIndex] : null,
                            height: 60,
                            width: 60),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.product.price,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                          ),
                          Text(
                            'Stok: ${widget.product.stock}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  if (widget.product.options.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: widget.product.options.map((option) {
                            final isSelected = _selectedOption == option;
                            return ChoiceChip(
                              label: Text(option),
                              selected: isSelected,
                              selectedColor: Colors.red[100],
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.red : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? Colors.red : Colors.grey,
                              ),
                              onSelected: (selected) {
                                setStateModal(() {
                                  _selectedOption = selected ? option : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                      ],
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setStateModal(() {
                                if (_quantity > 1) _quantity--;
                              });
                            },
                          ),
                          Text(_quantity.toString(), style: const TextStyle(fontSize: 18)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                            onPressed: () {
                              setStateModal(() {
                                if (_quantity < widget.product.stock) {
                                  _quantity++;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Stok tidak mencukupi!')),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.product.options.isNotEmpty && _selectedOption == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Silakan pilih opsi produk!')),
                          );
                          return;
                        }

                        Navigator.pop(context); // Tutup pop-up
                        // Navigasi ke halaman CheckoutScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              product: widget.product, // Pastikan product ini memiliki imageBytes/imagePath yang benar
                              selectedOption: _selectedOption,
                              quantity: _quantity,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Beli Sekarang',
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fungsi berbagi belum diimplementasikan')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fungsi favorit belum diimplementasikan')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.red,
              height: 250,
              width: double.infinity,
              child: Center(
                child: Hero(
                  tag: widget.product.id,
                  child: _buildImage(
                      _productImages.isNotEmpty ? _productImages[_currentImageIndex] : null,
                      height: 200,
                      fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (_productImages.length > 1) // Hanya tampilkan jika ada lebih dari 1 gambar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: SizedBox(
                    height: 60,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: _productImages.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentImageIndex == index ? Colors.red : Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: _buildImage(_productImages[index], height: 50, width: 50),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.price,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text('4.9 Penilaian Produk', style: TextStyle(color: Colors.grey[600])),
                      const Spacer(),
                      Text('2,1RB Terjual', style: TextStyle(color: Colors.grey[600])), // Contoh Terjual
                    ],
                  ),
                  Text('Stok: ${widget.product.stock}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const Divider(height: 25, thickness: 1),

                  Row(
                    children: [
                      const Icon(Icons.category, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.category,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        widget.product.address,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deskripsi Produk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.delivery_dining, size: 22, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Diperkirakan diterima : 15 sampai 16 Maret\nDapatkan voucher s/d Rp10.000 jika pesanan terlambat.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.security, size: 22, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '15 hari pengembalian - 100% Original',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProductScreen(productToEdit: widget.product),
                          ),
                        );
                        if (result == true) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text('Edit', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteProduct,
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text('Hapus', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.red, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fungsi chat belum diimplementasikan')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.red, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fungsi tambah ke keranjang belum diimplementasikan')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _showBuyOptionsPopup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}