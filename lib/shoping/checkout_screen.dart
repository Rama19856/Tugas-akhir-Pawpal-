import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pawpal/shoping/payment_method_selection.dart';
import 'package:pawpal/profile/payment_status_screen.dart';
import 'package:pawpal/shoping/product_management.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pawpal/address_manager_screen.dart';
import 'package:pawpal/payment_method_selection_screen.dart';
import 'package:pawpal/product_managemnet.dart';
import 'package:pawpal/shoping/voucher_selection_screen.dart';
import 'package:pawpal/profile/cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final String? selectedOption;
  final int quantity;

  const CheckoutScreen({
    Key? key,
    required this.product,
    this.selectedOption,
    required this.quantity,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Address> _userAddresses = [
    Address(
      name: 'anin',
      phoneNumber: '6285791353746',
      fullAddress: 'Jalan Danau Buyan 67 E13, Sawojajar, Kedungkandang, Malang',
      cityProvincePostalCode: 'KEDUNGKANDANG, KOTA MALANG, JAWA TIMUR, ID 65139',
      isPrimary: true,
    ),
    Address(
      name: 'Beauty',
      phoneNumber: '6285232116705',
      fullAddress: 'SMK Telkom Malang, Jl. Danau Ranau Raya, Sawojajar, Kedungkandang',
      cityProvincePostalCode: 'KEDUNGKANDANG, KOTA MALANG, JAWA TIMUR, ID 65139',
      isPrimary: false,
    ),
  ];

  late Address _selectedAddress;
  late PaymentMethod _selectedPaymentMethod;
  PaymentMethod? _selectedSubPaymentMethod;
  Voucher? _selectedStoreVoucher;
  Voucher? _selectedAppVoucher;

  final List<Voucher> _appVouchers = [
    Voucher(
      id: 'PPHAPPY50',
      name: 'PawPal Happy 50%',
      description: 'Diskon 50% hingga Rp30.000 untuk semua pembelian.',
      discountAmount: 0.50,
      isPercentage: true,
      minPurchase: 60000,
      maxDiscount: 30000,
    ),
    Voucher(
      id: 'PPNEWUSER20K',
      name: 'PawPal Pengguna Baru Rp20.000',
      description: 'Potongan harga langsung Rp20.000 khusus pengguna baru PawPal.',
      discountAmount: 20000,
      isPercentage: false,
      minPurchase: 100000,
    ),
    Voucher(
      id: 'PPFREESHIP',
      name: 'PawPal Gratis Ongkir',
      description: 'Gratis ongkir s/d Rp20.000 untuk semua transaksi.',
      discountAmount: 20000,
      isPercentage: false,
      minPurchase: 50000,
      isShippingVoucher: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeSelectedAddress();
    _selectedPaymentMethod = PaymentMethod(
      id: 'cod',
      name: 'COD - Bayar Dulu',
      description: '',
      icon: Icons.money,
      hasDropdown: false,
    );
    _selectedSubPaymentMethod = null;
    _selectedStoreVoucher = null;
    _selectedAppVoucher = null;
  }

  void _initializeSelectedAddress() {
    if (_userAddresses.isNotEmpty) {
      _selectedAddress = _userAddresses.firstWhere(
        (addr) => addr.isPrimary,
        orElse: () {
          if (_userAddresses.isNotEmpty) {
            _userAddresses.first.isPrimary = true;
            return _userAddresses.first;
          }
          return _createDefaultAddress();
        },
      );
    } else {
      _selectedAddress = _createDefaultAddress();
      _userAddresses.add(_selectedAddress);
    }
  }

  Address _createDefaultAddress() {
    return Address(
      name: 'Nama Lengkap',
      phoneNumber: 'Nomor Telepon',
      fullAddress: 'Jalan Lengkap',
      cityProvincePostalCode: 'Kota, Provinsi, Kode Pos',
      isPrimary: true,
    );
  }

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

  Future<void> _navigateToAddressSelection() async {
    final Map<String, dynamic>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressSelectionScreen(
          addresses: _userAddresses,
          selectedAddress: _selectedAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _userAddresses = List<Address>.from(result['updatedAddresses']);
        _selectedAddress = result['selectedAddress'] as Address;
        if (!_userAddresses.any((addr) => addr.id == _selectedAddress.id)) {
          _initializeSelectedAddress();
        }
      });
    }
  }

  Future<void> _navigateToPaymentMethodSelection() async {
    final Map<String, PaymentMethod?>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionScreen(
          selectedMethod: _selectedPaymentMethod,
          selectedSubMethod: _selectedSubPaymentMethod,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPaymentMethod = result['selectedMethod']!;
        _selectedSubPaymentMethod = result['selectedSubMethod'];
      });
    }
  }

  Future<void> _navigateToStoreVoucherSelection(int currentTotalPrice) async {
    final Voucher? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherSelectionScreen(
          selectedVoucher: _selectedStoreVoucher,
          currentTotalPrice: currentTotalPrice,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedStoreVoucher = result;
        if (_selectedStoreVoucher!.isShippingVoucher && _selectedAppVoucher?.isShippingVoucher == true) {
          _selectedAppVoucher = null; 
        }
      });
    } else {
      setState(() {
        _selectedStoreVoucher = null;
      });
    }
  }

  Future<void> _navigateToAppVoucherSelection(int currentTotalPrice) async {
    final Voucher? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherSelectionScreen(
          selectedVoucher: _selectedAppVoucher,
          currentTotalPrice: currentTotalPrice,
          availableVouchers: _appVouchers,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAppVoucher = result;
        if (_selectedAppVoucher!.isShippingVoucher && _selectedStoreVoucher?.isShippingVoucher == true) {
          _selectedStoreVoucher = null;
        }
      });
    } else {
      setState(() {
        _selectedAppVoucher = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceValue = int.tryParse(widget.product.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final totalProductPrice = priceValue * widget.quantity;
    final serviceFee = 1620;
    final shippingFee = 15000;

    double storeProductDiscount = 0;
    double storeShippingDiscount = 0;
    if (_selectedStoreVoucher != null) {
      if (_selectedStoreVoucher!.isShippingVoucher) {
        storeShippingDiscount = _selectedStoreVoucher!.discountAmount;
        if (storeShippingDiscount > shippingFee) {
          storeShippingDiscount = shippingFee.toDouble();
        }
      } else {
        if (_selectedStoreVoucher!.isPercentage) {
          storeProductDiscount = totalProductPrice * _selectedStoreVoucher!.discountAmount;
          if (_selectedStoreVoucher!.maxDiscount != null && storeProductDiscount > _selectedStoreVoucher!.maxDiscount!) {
            storeProductDiscount = _selectedStoreVoucher!.maxDiscount!;
          }
        } else {
          storeProductDiscount = _selectedStoreVoucher!.discountAmount;
        }
        if (storeProductDiscount > totalProductPrice) {
          storeProductDiscount = totalProductPrice.toDouble(); 
        }
      }
    }

    double appProductDiscount = 0;
    double appShippingDiscount = 0;

    if (_selectedAppVoucher != null) {
      if (_selectedAppVoucher!.isShippingVoucher) {
        appShippingDiscount = _selectedAppVoucher!.discountAmount;
        if (appShippingDiscount > (shippingFee - storeShippingDiscount)) { 
          appShippingDiscount = (shippingFee - storeShippingDiscount).toDouble();
        }
      } else {
        final priceForAppProductDiscountCalculation = totalProductPrice - storeProductDiscount;
        if (_selectedAppVoucher!.isPercentage) {
          appProductDiscount = priceForAppProductDiscountCalculation * _selectedAppVoucher!.discountAmount;
          if (_selectedAppVoucher!.maxDiscount != null && appProductDiscount > _selectedAppVoucher!.maxDiscount!) {
            appProductDiscount = _selectedAppVoucher!.maxDiscount!;
          }
        } else {
          appProductDiscount = _selectedAppVoucher!.discountAmount;
        }
        if (appProductDiscount > priceForAppProductDiscountCalculation) {
          appProductDiscount = priceForAppProductDiscountCalculation.toDouble(); 
        }
      }
    }

    final totalProductDiscount = storeProductDiscount + appProductDiscount;
    final totalShippingDiscount = storeShippingDiscount + appShippingDiscount;

    final finalShippingFee = shippingFee - totalShippingDiscount;

    final totalPaymentBeforeDiscount = totalProductPrice + serviceFee + shippingFee;
    final totalPaymentAfterDiscount = totalPaymentBeforeDiscount - totalProductDiscount - totalShippingDiscount;

    String paymentMethodDisplayName = _selectedPaymentMethod.name;
    if (_selectedSubPaymentMethod != null) {
      paymentMethodDisplayName += ' (${_selectedSubPaymentMethod!.name})';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _navigateToAddressSelection,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_selectedAddress.name} (+${_selectedAddress.phoneNumber})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddress.fullAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddress.cityProvincePostalCode,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (_selectedAddress.isPrimary)
                        const SizedBox(height: 8),
                      if (_selectedAddress.isPrimary)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Alamat Utama',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImage(
                        widget.product.imageBytes ?? widget.product.imagePath,
                        height: 60,
                        width: 60,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selectedOption != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.selectedOption!,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ),
                          Text(
                            '${widget.quantity}x ${widget.product.price}',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Voucher Toko',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _navigateToStoreVoucherSelection(totalProductPrice),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedStoreVoucher == null
                              ? 'Pilih atau Masukkan Kode'
                              : _selectedStoreVoucher!.fullDisplay,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedStoreVoucher == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Voucher PawPal (Aplikasi)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _navigateToAppVoucherSelection(totalProductPrice),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAppVoucher == null
                              ? 'Pilih atau Masukkan Kode'
                              : _selectedAppVoucher!.fullDisplay,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedAppVoucher == null ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, color: Colors.red),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Garansi tiba : 19-22 Mar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ongkos Kirim: Rp${finalShippingFee.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: finalShippingFee == 0 ? Colors.green : Colors.grey[600],
                          fontWeight: finalShippingFee == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Voucher s/d Rp10.000 jika pesanan tidak tiba 22 Mar 2025',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Rincian Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total 1 Produk'),
                        Text('Rp${totalProductPrice.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Layanan 😊'),
                        Text('Rp${serviceFee.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Biaya Pengiriman'),
                        Text('Rp${shippingFee.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}'),
                      ],
                    ),
                    if (_selectedStoreVoucher != null && storeProductDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon Produk Toko (${_selectedStoreVoucher!.name})', style: const TextStyle(color: Colors.green)),
                          Text(
                            '- Rp${storeProductDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedStoreVoucher != null && storeShippingDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon Ongkir Toko (${_selectedStoreVoucher!.name})', style: const TextStyle(color: Colors.green)),
                          Text(
                            '- Rp${storeShippingDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedAppVoucher != null && appProductDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon Produk Aplikasi (${_selectedAppVoucher!.name})', style: const TextStyle(color: Colors.green)),
                          Text(
                            '- Rp${appProductDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedAppVoucher != null && appShippingDiscount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon Ongkir Aplikasi (${_selectedAppVoucher!.name})', style: const TextStyle(color: Colors.green)),
                          Text(
                            '- Rp${appShippingDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Rp${totalPaymentAfterDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (Match m) => '\${m[1]}.')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _navigateToPaymentMethodSelection,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_selectedPaymentMethod.icon, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        paymentMethodDisplayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (value) {}),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: 'Dengan melanjutkan, Saya setuju dengan '),
                          TextSpan(
                            text: 'Syarat dan Ketentuan',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' yang berlaku.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            String finalPaymentMethod = _selectedPaymentMethod.name;
            if (_selectedSubPaymentMethod != null) {
              finalPaymentMethod += ' (\${_selectedSubPaymentMethod!.name})';
            }
            String voucherInfo = '';
            if (_selectedStoreVoucher != null) {
              voucherInfo += ' (Toko: \${_selectedStoreVoucher!.name})';
            }
            if (_selectedAppVoucher != null) {
              voucherInfo += ' (Aplikasi: \${_selectedAppVoucher!.name})';
            }

            CartScreen.orders.add(Order(
              product: widget.product,
              quantity: widget.quantity,
              paymentMethod: finalPaymentMethod,
              totalAmount: totalPaymentAfterDiscount.toInt(),
              status: 'Dikemas',
            ));

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentStatusScreen()),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pesanan berhasil diproses dengan metode $finalPaymentMethod$voucherInfo! Total: Rp${totalPaymentAfterDiscount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}')),
            );
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
            'Checkout',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
