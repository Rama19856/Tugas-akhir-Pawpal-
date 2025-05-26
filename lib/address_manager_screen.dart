// lib/address_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

// -------- Model Address --------
class Address {
  final String id; // Unique ID for each address
  String name;
  String phoneNumber;
  String fullAddress;
  String cityProvincePostalCode;
  bool isPrimary;

  Address({
    String? id, // Make id optional in constructor, generate if null
    required this.name,
    required this.phoneNumber,
    required this.fullAddress,
    required this.cityProvincePostalCode,
    this.isPrimary = false,
  }) : id = id ?? const Uuid().v4(); // Generate UUID if ID is not provided

  // For easy display or debugging
  @override
  String toString() {
    return '$name ($phoneNumber)\n$fullAddress\n$cityProvincePostalCode';
  }

  // Method to create a copy of the address
  Address copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? fullAddress,
    String? cityProvincePostalCode,
    bool? isPrimary,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullAddress: fullAddress ?? this.fullAddress,
      cityProvincePostalCode: cityProvincePostalCode ?? this.cityProvincePostalCode,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

// -------- AddressSelectionScreen Widget --------
class AddressSelectionScreen extends StatefulWidget {
  final List<Address> addresses;
  final Address? selectedAddress;

  const AddressSelectionScreen({
    Key? key,
    required this.addresses,
    this.selectedAddress,
  }) : super(key: key);

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  late List<Address> _addresses;
  Address? _currentSelectedAddress;

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the addresses list to allow modifications within this screen
    _addresses = widget.addresses.map((addr) => addr.copyWith()).toList();

    // Initialize _currentSelectedAddress based on the passed selectedAddress,
    // or if null, try to find the primary, or the first address.
    if (widget.selectedAddress != null) {
      _currentSelectedAddress = _addresses.firstWhereOrNull((addr) => addr.id == widget.selectedAddress!.id);
    }

    if (_currentSelectedAddress == null && _addresses.isNotEmpty) {
      _currentSelectedAddress = _addresses.firstWhereOrNull((addr) => addr.isPrimary) ?? _addresses.first;
    } else if (_currentSelectedAddress == null && _addresses.isEmpty) {
      _currentSelectedAddress = null;
    }

    _ensurePrimaryAddress(); // Ensure there's always one primary address
  }

  // Helper to ensure there's always one primary address if the list is not empty
  void _ensurePrimaryAddress() {
    if (_addresses.isNotEmpty) {
      if (!_addresses.any((addr) => addr.isPrimary)) {
        // If no primary, make the first one primary
        setState(() { // setState because we are modifying _addresses directly
          _addresses.first.isPrimary = true;
        });
      } else {
        // Ensure only one primary, but don't force _currentSelectedAddress to be primary here.
        // This logic just cleans up multiple primaries.
        Address? primaryFound;
        for (var addr in _addresses) {
          if (addr.isPrimary) {
            if (primaryFound == null) {
              primaryFound = addr;
            } else {
              setState(() { // setState because we are modifying _addresses directly
                addr.isPrimary = false; // Set duplicates to false
              });
            }
          }
        }
      }
    } else {
      _currentSelectedAddress = null; // No addresses, no selected address
    }
  }


  void _addEditAddress({Address? addressToEdit}) async {
    final TextEditingController nameController =
        TextEditingController(text: addressToEdit?.name);
    final TextEditingController phoneController =
        TextEditingController(text: addressToEdit?.phoneNumber);
    final TextEditingController fullAddressController =
        TextEditingController(text: addressToEdit?.fullAddress);
    final TextEditingController cityProvincePostalCodeController =
        TextEditingController(text: addressToEdit?.cityProvincePostalCode);
    bool isPrimary = addressToEdit?.isPrimary ?? false;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Use StatefulBuilder for dialog to update isPrimary checkbox
          builder: (context, setStateDialog) { // Renamed setState to setStateDialog to avoid conflict
            return AlertDialog(
              title: Text(addressToEdit == null ? 'Tambah Alamat Baru' : 'Edit Alamat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: fullAddressController,
                      decoration: const InputDecoration(labelText: 'Alamat Lengkap (Jl, RT/RW, Kecamatan, Desa)'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: cityProvincePostalCodeController,
                      decoration: const InputDecoration(labelText: 'Kota, Provinsi, Kode Pos'),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: isPrimary,
                          onChanged: (bool? newValue) {
                            setStateDialog(() { // Use setStateDialog
                              isPrimary = newValue ?? false;
                            });
                          },
                        ),
                        const Text('Jadikan Alamat Utama'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  style: TextButton.styleFrom( // Remove border for TextButton
                    foregroundColor: Colors.grey, // Consistent color
                  ),
                ),
                TextButton( // Changed from ElevatedButton to TextButton for consistent style
                  child: Text(addressToEdit == null ? 'Tambah' : 'Simpan'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty &&
                        fullAddressController.text.isNotEmpty &&
                        cityProvincePostalCodeController.text.isNotEmpty) {

                      setState(() { // Main screen setState to apply changes
                        // Before adding/editing, set all others to not primary if this one will be primary
                        if (isPrimary) {
                          for (var addr in _addresses) {
                            addr.isPrimary = false;
                          }
                        }

                        if (addressToEdit == null) {
                          // Add new address
                          final newAddress = Address(
                            name: nameController.text,
                            phoneNumber: phoneController.text,
                            fullAddress: fullAddressController.text,
                            cityProvincePostalCode: cityProvincePostalCodeController.text,
                            isPrimary: isPrimary,
                          );
                          _addresses.add(newAddress);
                          _currentSelectedAddress = newAddress; // Automatically select newly added
                        } else {
                          // Edit existing address
                          final index = _addresses.indexWhere((addr) => addr.id == addressToEdit.id);
                          if (index != -1) {
                            _addresses[index].name = nameController.text;
                            _addresses[index].phoneNumber = phoneController.text;
                            _addresses[index].fullAddress = fullAddressController.text;
                            _addresses[index].cityProvincePostalCode = cityProvincePostalCodeController.text;
                            _addresses[index].isPrimary = isPrimary;
                            // If the edited address was the current selected, update the reference
                            if (_currentSelectedAddress?.id == _addresses[index].id) {
                              _currentSelectedAddress = _addresses[index];
                            }
                          }
                        }

                        _ensurePrimaryAddress(); // Re-evaluate primary status after changes
                      }); // end main screen setState

                      Navigator.of(dialogContext).pop(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Semua kolom harus diisi!')),
                      );
                    }
                  },
                  style: TextButton.styleFrom( // Remove border for TextButton
                    foregroundColor: Colors.red, // Consistent color
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() {
        // This setState triggers a rebuild of the AddressSelectionScreen itself
        // if changes were made and confirmed from the dialog.
      });
    }
  }

  void _deleteAddress(Address addressToDelete) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Alamat'),
          content: const Text('Anda yakin ingin menghapus alamat ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            TextButton( // Changed from ElevatedButton to TextButton for consistent style
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() { // Main screen setState
                  _addresses.removeWhere((addr) => addr.id == addressToDelete.id);
                  if (_currentSelectedAddress?.id == addressToDelete.id) {
                    _currentSelectedAddress = null; // Clear selected if deleted
                  }
                  _ensurePrimaryAddress(); // Ensure primary address after deletion
                });
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to get the data that should be returned to the previous screen
  Map<String, dynamic> _getReturnData() {
    // The selectedAddress to return is always _currentSelectedAddress, which reflects user's last explicit selection.
    // If somehow no address is selected (e.g., all were deleted), then it's null.
    return {
      'selectedAddress': _currentSelectedAddress,
      'updatedAddresses': _addresses, // Return the full updated list
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Alamat'),
        backgroundColor: Colors.red,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _getReturnData()), // Pass back selected address and updated list
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada alamat yang tersimpan. Tambahkan satu!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      // isSelected is based on _currentSelectedAddress directly
                      final isSelected = _currentSelectedAddress?.id == address.id;

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
                          // The main tap on the card selects the address
                          onTap: () {
                            setState(() {
                              _currentSelectedAddress = address;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Checkbox also selects the address
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        if (value == true) {
                                          setState(() {
                                            _currentSelectedAddress = address;
                                          });
                                        }
                                      },
                                      activeColor: Colors.red, // Make checkbox red when active
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${address.name} (+${address.phoneNumber})',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton( // Use TextButton for "Ubah"
                                      onPressed: () => _addEditAddress(addressToEdit: address),
                                      child: const Text('Ubah'),
                                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton( // Use TextButton for "Hapus"
                                      onPressed: () => _deleteAddress(address),
                                      child: const Text('Hapus'),
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.fullAddress,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.cityProvincePostalCode,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                if (address.isPrimary)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Utama',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addEditAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder( // Tetap gunakan ini untuk rounded corners
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0, // Hapus bayangan
                foregroundColor: Colors.white, // Warna teks
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0), // Make button full width
              ),
              child: const Text(
                'Tambah Alamat Baru',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _currentSelectedAddress == null
                  ? null // Disable button if no address is selected
                  : () {
                      Navigator.pop(context, _getReturnData());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Green color for "Pilih Alamat"
                shape: RoundedRectangleBorder( // Tetap gunakan ini untuk rounded corners
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0, // Hapus bayangan
                foregroundColor: Colors.white, // Warna teks
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: const Text(
                'Pilih Alamat',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to find first element or return null (if not already built-in by Flutter version)
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