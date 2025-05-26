// lib/voucher_selection_screen.dart

import 'package:flutter/material.dart';

// -------- Model Voucher --------
class Voucher {
  final String id;
  final String name;
  final String description;
  final double discountAmount; // Nominal diskon
  final bool isPercentage; // True if discount is percentage, false if fixed amount
  final double? minPurchase; // Minimum purchase to use voucher
  final double? maxDiscount; // Max discount for percentage vouchers (optional)
  final bool isShippingVoucher; // New: True if this voucher is for shipping

  Voucher({
    required this.id,
    required this.name,
    required this.description,
    required this.discountAmount,
    this.isPercentage = false,
    this.minPurchase,
    this.maxDiscount,
    this.isShippingVoucher = false, // Initialize as false by default
  });

  // Helper to get display string for discount
  String get discountDisplay {
    if (isPercentage) {
      String display = '${(discountAmount * 100).toInt()}%';
      if (maxDiscount != null && maxDiscount! > 0) {
        display += ' (Max. Rp${maxDiscount!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')})';
      }
      return display;
    } else {
      return 'Rp${discountAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
  }

  String get fullDisplay {
    String display = name;
    if (minPurchase != null && minPurchase! > 0) {
      display += ' (Min. Blj Rp${minPurchase!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')})';
    }
    return display;
  }

  @override
  String toString() {
    return name;
  }
}

// -------- VoucherSelectionScreen Widget --------
class VoucherSelectionScreen extends StatefulWidget {
  final Voucher? selectedVoucher;
  final int currentTotalPrice;
  final List<Voucher>? availableVouchers;

  const VoucherSelectionScreen({
    Key? key,
    this.selectedVoucher,
    required this.currentTotalPrice,
    this.availableVouchers,
  }) : super(key: key);

  @override
  State<VoucherSelectionScreen> createState() => _VoucherSelectionScreenState();
}

class _VoucherSelectionScreenState extends State<VoucherSelectionScreen> {
  Voucher? _currentSelectedVoucher;

  // Dummy list of vouchers (default for store vouchers)
  final List<Voucher> _defaultStoreVouchers = [
    Voucher(
      id: 'DISC10K',
      name: 'Diskon Rp10.000',
      description: 'Potongan harga langsung Rp10.000 untuk semua produk.',
      discountAmount: 10000,
      isPercentage: false,
      minPurchase: 50000,
    ),
    Voucher(
      id: 'HEMAT20P',
      name: 'Diskon 20%',
      description: 'Potongan harga 20% maksimal Rp25.000.',
      discountAmount: 0.20,
      isPercentage: true,
      minPurchase: 75000,
      maxDiscount: 25000,
    ),
    Voucher(
      id: 'GRATISONGKIR',
      name: 'Gratis Ongkir',
      description: 'Potongan ongkir s/d Rp15.000 dengan minimal belanja Rp30.000.',
      discountAmount: 15000, // Representing max shipping discount
      isPercentage: false,
      minPurchase: 30000,
      isShippingVoucher: true, // Mark as shipping voucher
    ),
    Voucher(
      id: 'CASHBACK5K',
      name: 'Cashback Rp5.000',
      description: 'Dapatkan cashback Rp5.000 dalam bentuk koin PawPal.',
      discountAmount: 5000,
      isPercentage: false,
      minPurchase: 40000,
    ),
  ];

  late List<Voucher> _displayVouchers;

  @override
  void initState() {
    super.initState();
    _displayVouchers = widget.availableVouchers ?? _defaultStoreVouchers;

    if (widget.selectedVoucher != null) {
      _currentSelectedVoucher = _displayVouchers.firstWhereOrNull(
        (voucher) => voucher.id == widget.selectedVoucher!.id,
      );
    }
  }

  void _showInfoPopup(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isVoucherApplicable(Voucher voucher) {
    if (voucher.minPurchase == null) {
      return true;
    }
    return widget.currentTotalPrice >= voucher.minPurchase!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Voucher'),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _currentSelectedVoucher),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _displayVouchers.length,
              itemBuilder: (context, index) {
                final voucher = _displayVouchers[index];
                final bool isSelected = _currentSelectedVoucher?.id == voucher.id;
                final bool isApplicable = _isVoucherApplicable(voucher);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isSelected ? Colors.red : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: isApplicable
                        ? () {
                            setState(() {
                              _currentSelectedVoucher = voucher;
                            });
                          }
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Opacity(
                        opacity: isApplicable ? 1.0 : 0.5,
                        child: Row(
                          children: [
                            const Icon(Icons.confirmation_number, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    voucher.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    voucher.description,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                  if (voucher.minPurchase != null && voucher.minPurchase! > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Min. Belanja: Rp${voucher.minPurchase!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isApplicable ? Colors.orange[700] : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline, color: Colors.grey),
                              onPressed: () {
                                _showInfoPopup(voucher.name, voucher.description);
                              },
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: isApplicable
                                  ? (bool? value) {
                                      setState(() {
                                        _currentSelectedVoucher = value == true ? voucher : null;
                                      });
                                    }
                                  : null,
                              activeColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentSelectedVoucher = null;
                      });
                      Navigator.pop(context, null);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Batalkan Voucher',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentSelectedVoucher == null
                        ? null
                        : () {
                            Navigator.pop(context, _currentSelectedVoucher);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Gunakan Voucher',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}