// lib/payment_method_selection_screen.dart

import 'package:flutter/material.dart';

// -------- Model PaymentMethod --------
class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool hasDropdown;
  final List<PaymentMethod>? subMethods; // New: List of sub-methods

  PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.hasDropdown = false,
    this.subMethods, // Initialize subMethods
  });

  @override
  String toString() {
    return name;
  }
}

// -------- PaymentMethodSelectionScreen Widget --------
class PaymentMethodSelectionScreen extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final PaymentMethod? selectedSubMethod; // New: Pass selected sub-method

  const PaymentMethodSelectionScreen({
    Key? key,
    this.selectedMethod,
    this.selectedSubMethod, // Receive selected sub-method
  }) : super(key: key);

  @override
  State<PaymentMethodSelectionScreen> createState() => _PaymentMethodSelectionScreenState();
}

class _PaymentMethodSelectionScreenState extends State<PaymentMethodSelectionScreen> {
  PaymentMethod? _currentSelectedMethod;
  PaymentMethod? _currentSelectedSubMethod; // New: State for current selected sub-method

  // Daftar metode pembayaran yang tersedia dengan sub-metode
  late List<PaymentMethod> _paymentMethods;

  @override
  void initState() {
    super.initState();
    _paymentMethods = [
      PaymentMethod(
        id: 'cod',
        name: 'COD - Bayar Dulu',
        description: 'Bayar tunai kepada kurir saat pesanan tiba di alamat Anda. Pastikan jumlah uang sesuai dan siapkan uang pas.',
        icon: Icons.money,
        hasDropdown: false,
      ),
      PaymentMethod(
        id: 'cod_cek_dulu',
        name: 'COD - Cek Dulu',
        description: 'Anda dapat memeriksa barang sebelum melakukan pembayaran kepada kurir. Hanya untuk produk tertentu dan area tertentu.',
        icon: Icons.money,
        hasDropdown: false,
      ),
      PaymentMethod(
        id: 'transfer_bank',
        name: 'Transfer Bank',
        description: 'Bayar melalui transfer bank ke rekening yang ditunjuk.',
        icon: Icons.account_balance,
        hasDropdown: true,
        subMethods: [
          PaymentMethod(
            id: 'bca',
            name: 'Bank Central Asia (BCA)',
            description: 'Transfer ke rekening BCA. Pembayaran akan terverifikasi otomatis.',
            icon: Icons.account_balance, // Could use specific bank icons if available
          ),
          PaymentMethod(
            id: 'mandiri',
            name: 'Bank Mandiri',
            description: 'Transfer ke rekening Mandiri. Pembayaran akan terverifikasi otomatis.',
            icon: Icons.account_balance,
          ),
          PaymentMethod(
            id: 'bri',
            name: 'Bank Rakyat Indonesia (BRI)',
            description: 'Transfer ke rekening BRI. Pembayaran akan terverifikasi otomatis.',
            icon: Icons.account_balance,
          ),
          PaymentMethod(
            id: 'bni',
            name: 'Bank Negara Indonesia (BNI)',
            description: 'Transfer ke rekening BNI. Pembayaran akan terverifikasi otomatis.',
            icon: Icons.account_balance,
          ),
          PaymentMethod(
            id: 'other_bank',
            name: 'Bank Lainnya',
            description: 'Transfer ke bank selain yang terdaftar. Mungkin memerlukan verifikasi manual.',
            icon: Icons.account_balance,
          ),
        ],
      ),
      PaymentMethod(
        id: 'credit_debit_card',
        name: 'Kartu Kredit/Debit',
        description: 'Pembayaran aman menggunakan kartu kredit atau debit Anda.',
        icon: Icons.credit_card,
        hasDropdown: true,
        subMethods: [
          PaymentMethod(
            id: 'visa',
            name: 'Visa',
            description: 'Gunakan kartu Visa Anda untuk pembayaran. Aman dan cepat.',
            icon: Icons.credit_card, // Could use specific card icons
          ),
          PaymentMethod(
            id: 'mastercard',
            name: 'Mastercard',
            description: 'Gunakan kartu Mastercard Anda untuk pembayaran. Diterima secara global.',
            icon: Icons.credit_card,
          ),
          PaymentMethod(
            id: 'jcb',
            name: 'JCB',
            description: 'Gunakan kartu JCB Anda untuk pembayaran.',
            icon: Icons.credit_card,
          ),
          PaymentMethod(
            id: 'gpn',
            name: 'GPN (Gerbang Pembayaran Nasional)',
            description: 'Gunakan kartu debit berlogo GPN untuk transaksi domestik.',
            icon: Icons.credit_card,
          ),
        ],
      ),
    ];

    // Inisialisasi _currentSelectedMethod dan _currentSelectedSubMethod
    if (widget.selectedMethod != null) {
      _currentSelectedMethod = _paymentMethods.firstWhereOrNull((method) => method.id == widget.selectedMethod!.id);
      if (_currentSelectedMethod != null && widget.selectedSubMethod != null) {
        _currentSelectedSubMethod = _currentSelectedMethod!.subMethods?.firstWhereOrNull((subMethod) => subMethod.id == widget.selectedSubMethod!.id);
      }
    }

    // Default selection if nothing passed or found
    _currentSelectedMethod ??= _paymentMethods.firstWhereOrNull((method) => method.id == 'cod');
    _currentSelectedMethod ??= _paymentMethods.isNotEmpty ? _paymentMethods.first : null;
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

  // Method to get the data to return
  Map<String, PaymentMethod?> _getReturnData() {
    return {
      'selectedMethod': _currentSelectedMethod,
      'selectedSubMethod': _currentSelectedSubMethod,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metode Pembayaran'),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _getReturnData()), // Return map
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final bool isMainMethodSelected = _currentSelectedMethod?.id == method.id;

                if (method.hasDropdown) {
                  // Use ExpansionTile for methods with sub-options
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isMainMethodSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isMainMethodSelected ? Colors.red : Colors.grey[300]!,
                        width: isMainMethodSelected ? 2 : 1,
                      ),
                    ),
                    child: ExpansionTile(
                      key: PageStorageKey(method.id), // Important for state persistence
                      initiallyExpanded: isMainMethodSelected && _currentSelectedSubMethod != null, // Expand if this method is selected and has a sub-method
                      title: Row(
                        children: [
                          Icon(method.icon, color: Colors.grey[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              method.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.help_outline, color: Colors.grey),
                            onPressed: () {
                              _showInfoPopup(method.name, method.description);
                            },
                          ),
                          Checkbox(
                            value: isMainMethodSelected && _currentSelectedSubMethod == null, // Only checked if main method is selected AND no sub-method is selected yet (acting as generic selection)
                            onChanged: (bool? value) {
                              if (value == true) {
                                setState(() {
                                  _currentSelectedMethod = method;
                                  _currentSelectedSubMethod = null; // Clear sub-method if main is generically selected
                                });
                              }
                            },
                            activeColor: Colors.red,
                          ),
                        ],
                      ),
                      children: method.subMethods?.map((subMethod) {
                            final bool isSubMethodSelected = _currentSelectedSubMethod?.id == subMethod.id;
                            return Padding(
                              padding: const EdgeInsets.only(left: 30.0, right: 16.0, bottom: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _currentSelectedMethod = method; // Ensure main method is also selected
                                    _currentSelectedSubMethod = subMethod;
                                  });
                                },
                                child: Row(
                                  children: [
                                    Icon(subMethod.icon, color: Colors.grey[600]), // Use sub-method icon
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        subMethod.name,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSubMethodSelected ? FontWeight.bold : FontWeight.normal),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.help_outline, color: Colors.grey),
                                      onPressed: () {
                                        _showInfoPopup(subMethod.name, subMethod.description);
                                      },
                                    ),
                                    Checkbox(
                                      value: isSubMethodSelected,
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          setState(() {
                                            _currentSelectedMethod = method; // Ensure main method is also selected
                                            _currentSelectedSubMethod = subMethod;
                                          });
                                        }
                                      },
                                      activeColor: Colors.red,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  );
                } else {
                  // For methods without sub-options, use regular Card
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isMainMethodSelected && _currentSelectedSubMethod == null ? 4 : 1, // Only selected if main and no sub selected
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: (isMainMethodSelected && _currentSelectedSubMethod == null) ? Colors.red : Colors.grey[300]!,
                        width: (isMainMethodSelected && _currentSelectedSubMethod == null) ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _currentSelectedMethod = method;
                          _currentSelectedSubMethod = null; // Clear sub-method if non-dropdown is selected
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(method.icon, color: Colors.grey[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                method.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline, color: Colors.grey),
                              onPressed: () {
                                _showInfoPopup(method.name, method.description);
                              },
                            ),
                            Checkbox(
                              value: isMainMethodSelected && _currentSelectedSubMethod == null,
                              onChanged: (bool? value) {
                                if (value == true) {
                                  setState(() {
                                    _currentSelectedMethod = method;
                                    _currentSelectedSubMethod = null;
                                  });
                                }
                              },
                              activeColor: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _currentSelectedMethod == null
                  ? null
                  : () {
                      Navigator.pop(context, _getReturnData());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Konfirmasi',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to find first element or return null
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