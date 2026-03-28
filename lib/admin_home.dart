import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Product Fields
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _materialController = TextEditingController();
  final _careController = TextEditingController();
  
  List<XFile> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(selectedImages);
      });
    }
  }

  void _removeSelectedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImages.isEmpty && _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick images or provide a URL')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      List<String> galleryUrls = [];
      String? mainImageUrl;

      // 1. Upload Images to Supabase Storage
      if (_pickedImages.isNotEmpty) {
        for (int i = 0; i < _pickedImages.length; i++) {
          final image = _pickedImages[i];
          // Using a simple timestamp for filename to avoid "bucket is add" confusion
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final bytes = await image.readAsBytes();
          
          await supabase.storage.from('product').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
          
          final String publicUrl = supabase.storage.from('product').getPublicUrl(fileName);
          galleryUrls.add(publicUrl);
        }
        mainImageUrl = galleryUrls.first;
      } else {
        mainImageUrl = _imageUrlController.text;
        galleryUrls = [mainImageUrl];
      }

      // 2. Add to products table
      final productData = {
        'name': _nameController.text,
        'description': _descController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'image_url': mainImageUrl,
        'gallery_images': galleryUrls, // Storing multiple images
        'category': _categoryController.text,
        'material': _materialController.text,
        'care_instructions': _careController.text,
        'is_active': true,
      };

      await supabase.from('products').insert(productData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      // Clear fields
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _categoryController.clear();
      _materialController.clear();
      _careController.clear();
      setState(() {
        _pickedImages = [];
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethrah Admin - Add Product'),
        backgroundColor: const Color(0xFF4A342E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create New Product',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A342E),
                  fontFamily: 'PlayfairDisplay',
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Product Name', icon: Icons.shopping_bag_outlined),
              const SizedBox(height: 16),
              _buildTextField(_descController, 'Description', maxLines: 3, icon: Icons.description_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price (₹)', isNumeric: true, icon: Icons.currency_rupee)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_categoryController, 'Category', icon: Icons.category_outlined)),
                ],
              ),
              const SizedBox(height: 24),
              
              // Image Picker Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Product Images',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A342E)),
                      ),
                      if (_pickedImages.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_pickedImages.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (_pickedImages.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() => _pickedImages = []),
                      icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 20),
                      label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Image Picker Box/List
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _pickedImages.isNotEmpty 
                  ? ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length + 1,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        if (index == _pickedImages.length) {
                          // "Add More" Button at end of list
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 130,
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFD4AF37), size: 30),
                                  SizedBox(height: 8),
                                  Text('Add More', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        }
                        
                        final image = _pickedImages[index];
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 130,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb
                                    ? Image.network(image.path, fit: BoxFit.cover)
                                    : Image.file(File(image.path), fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _removeSelectedImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('MAIN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ),
                          ],
                        );
                      },
                    )
                  : InkWell(
                      onTap: _pickImages,
                      borderRadius: BorderRadius.circular(12),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 48, color: Color(0xFFD4AF37)),
                          SizedBox(height: 12),
                          Text(
                            'Select Product Images',
                            style: TextStyle(color: Color(0xFF4A342E), fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text('Supports multiple images at once', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_imageUrlController, 'Or Enter Image URL (Optional)'),
              const SizedBox(height: 16),
              _buildTextField(_materialController, 'Material (e.g. Pure Silk)'),
              const SizedBox(height: 16),
              _buildTextField(_careController, 'Care Instructions'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFD4AF37),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ADD PRODUCT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumeric = false, IconData? icon}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFD4AF37)) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Field required' : null,
    );
  }
}
