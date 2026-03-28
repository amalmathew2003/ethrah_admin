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
        _pickedImages = selectedImages;
      });
    }
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add New Product',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Product Name'),
              const SizedBox(height: 16),
              _buildTextField(_descController, 'Description', maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_priceController, 'Price (e.g. 12500)', isNumeric: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_categoryController, 'Category (ethnic/jewellery)')),
                ],
              ),
              const SizedBox(height: 16),
              // Image Picker UI
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _pickedImages.isNotEmpty 
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _pickedImages.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final image = _pickedImages[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: kIsWeb
                                  ? Image.network(
                                      image.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(image.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          );
                        },
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Pick Product Images (Select Multiple)', style: TextStyle(color: Colors.grey)),
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

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFD4AF37))),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Field required' : null,
    );
  }
}
