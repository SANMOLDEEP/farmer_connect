import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _equipmentNameController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _pricePerHourController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'Tractor';
  String _selectedCondition = 'Good';
  int _selectedYear = DateTime.now().year;
  File? _imageFile;
  String? _imageBase64;
  bool _isUploading = false;

  final List<String> _categories = [
    'Tractor',
    'Harvester',
    'Thresher',
    'Irrigation Pump',
    'Seed Drill',
    'Plough',
    'Sprayer',
    'Cultivator',
    'Rotavator',
    'Others',
  ];

  final List<String> _conditions = ['Excellent', 'Good', 'Fair'];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _submitEquipment() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an equipment image')),
      );
      return;
    }

    if (_isUploading) return;
    setState(() => _isUploading = true);

    try {
      final equipmentData = {
        'equipmentName': _equipmentNameController.text.trim(),
        'category': _selectedCategory,
        'pricePerDay': double.parse(_pricePerDayController.text.trim()),
        'pricePerHour': _pricePerHourController.text.trim().isNotEmpty
            ? double.parse(_pricePerHourController.text.trim())
            : null,
        'description': _descriptionController.text.trim(),
        'specifications': _specificationsController.text.trim(),
        'imageUrl': _imageBase64,
        'ownerName': _ownerNameController.text.trim(),
        'ownerPhone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'postedDate': FieldValue.serverTimestamp(),
        'isAvailable': true,
        'whatsappNumber': _whatsappController.text.trim().isNotEmpty
            ? _whatsappController.text.trim()
            : null,
        'yearOfManufacture': _selectedYear,
        'condition': _selectedCondition,
      };

      await FirebaseFirestore.instance.collection('equipment').add(equipmentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Equipment listed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Equipment'),
        backgroundColor: Colors.brown[700],
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Listing equipment...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image picker
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Gallery'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Camera'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 64, color: Colors.grey[600]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Equipment Photo',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Equipment name
                    TextFormField(
                      controller: _equipmentNameController,
                      decoration: InputDecoration(
                        labelText: 'Equipment Name *',
                        hintText: 'e.g., John Deere 5310',
                        prefixIcon: const Icon(Icons.agriculture),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    // Category & Condition
                    // ✅ FIXED: Category & Condition - No overflow
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: 'Category *',
          prefixIcon: const Icon(Icons.category, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        isExpanded: true, // ✅ Prevents overflow
        items: _categories.map((cat) => 
          DropdownMenuItem(
            value: cat,
            child: Text(
              cat,
              style: const TextStyle(fontSize: 14), // ✅ Smaller font
              overflow: TextOverflow.ellipsis,
            ),
          )
        ).toList(),
        onChanged: (value) => setState(() => _selectedCategory = value!),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _selectedCondition,
        decoration: InputDecoration(
          labelText: 'Condition *',
          prefixIcon: const Icon(Icons.star, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        isExpanded: true, // ✅ Prevents overflow
        items: _conditions.map((cond) => 
          DropdownMenuItem(
            value: cond,
            child: Text(
              cond,
              style: const TextStyle(fontSize: 14), // ✅ Smaller font
              overflow: TextOverflow.ellipsis,
            ),
          )
        ).toList(),
        onChanged: (value) => setState(() => _selectedCondition = value!),
      ),
    ),
  ],
),
                    const SizedBox(height: 16),

                    // Year & Prices
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: InputDecoration(
                              labelText: 'Year *',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: List.generate(30, (i) => DateTime.now().year - i)
                                .map((year) => DropdownMenuItem(
                                      value: year,
                                      child: Text(year.toString()),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedYear = value!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _pricePerDayController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price/Day *',
                              prefixIcon: const Icon(Icons.currency_rupee),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Required';
                              if (double.tryParse(value!) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price per hour (optional)
                    TextFormField(
                      controller: _pricePerHourController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price/Hour (Optional)',
                        prefixIcon: const Icon(Icons.access_time),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the equipment...',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Specifications
                    TextFormField(
                      controller: _specificationsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Specifications',
                        hintText: 'Engine power, capacity, features, etc.',
                        prefixIcon: const Icon(Icons.settings),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Owner Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'Phone *',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        if (value!.length != 10) return '10 digits';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: 'WhatsApp (Optional)',
                        prefixIcon: const Icon(Icons.chat),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        counterText: '',
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
                        hintText: 'Village, City',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _submitEquipment,
                        icon: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.upload),
                        label: Text(_isUploading ? 'Uploading...' : 'List Equipment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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
    _equipmentNameController.dispose();
    _pricePerDayController.dispose();
    _pricePerHourController.dispose();
    _descriptionController.dispose();
    _specificationsController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}