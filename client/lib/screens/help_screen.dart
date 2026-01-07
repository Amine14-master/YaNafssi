import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../services/cloudinary_service.dart';
import '../services/localization_service.dart';
import '../widgets/language_popup.dart';
import 'package:firebase_database/firebase_database.dart';
import 'specialist_dashboard_screen.dart';
import 'helper/helper_main_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wilayaController = TextEditingController();
  final _communeController = TextEditingController();

  String? _selectedSpecialty;
  final List<String> _specialties = [
    'psychologist',
    'deen_helper',
    'sports_coach',
    'nutrition_specialist',
    'other',
  ];

  XFile? _idCardFront;
  XFile? _idCardBack;
  XFile? _selfie;
  XFile? _licenseImage;

  bool _isUploading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<void> _pickImage(ImageSource source, Function(XFile?) onPick) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        onPick(image);
      });
    }
  }

  Future<void> _submit() async {
    debugPrint('HelpScreen: _submit called');
    if (_formKey.currentState!.validate()) {
      if (_idCardFront == null ||
          _idCardBack == null ||
          _selfie == null ||
          _licenseImage == null) {
        debugPrint('HelpScreen: Validation failed - missing images');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService().translate('upload_required')),
          ),
        );
        return;
      }

      if (_selectedSpecialty == null) {
        debugPrint('HelpScreen: Validation failed - missing specialty');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService().translate('please_select_specialty'),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        debugPrint('HelpScreen: Starting image uploads...');
        // Upload images
        String? idFrontUrl = await _cloudinaryService.uploadImage(_idCardFront);
        debugPrint('HelpScreen: idFrontUrl: $idFrontUrl');
        String? idBackUrl = await _cloudinaryService.uploadImage(_idCardBack);
        debugPrint('HelpScreen: idBackUrl: $idBackUrl');
        String? selfieUrl = await _cloudinaryService.uploadImage(_selfie);
        debugPrint('HelpScreen: selfieUrl: $selfieUrl');
        String? licenseUrl = await _cloudinaryService.uploadImage(
          _licenseImage,
        );
        debugPrint('HelpScreen: licenseUrl: $licenseUrl');

        if (idFrontUrl != null &&
            idBackUrl != null &&
            selfieUrl != null &&
            licenseUrl != null) {
          debugPrint(
            'HelpScreen: All images uploaded successfully. Saving to Firebase...',
          );
          // Save to Realtime Database
          DatabaseReference ref = FirebaseDatabase.instance
              .ref('specialist_requests')
              .push();
          await ref.set({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'wilaya': _wilayaController.text,
            'commune': _communeController.text,
            'specialty': _selectedSpecialty,
            'idFrontUrl': idFrontUrl,
            'idBackUrl': idBackUrl,
            'selfieUrl': selfieUrl,
            'licenseUrl': licenseUrl,
            'status': 'pending',
            'timestamp': ServerValue.timestamp,
          });
          debugPrint('HelpScreen: Data saved to Firebase successfully.');

          if (mounted) {
            // Listen for status changes
            ref.onValue.listen((event) {
              debugPrint(
                'HelpScreen: Received database update: ${event.snapshot.value}',
              );
              final data = event.snapshot.value as Map?;
              if (data != null && data['status'] == 'approved') {
                debugPrint(
                  'HelpScreen: Status is approved. Navigating to SpecialistDashboardScreen.',
                );
                // Close dialog if open (this is a bit tricky, but we can just navigate)
                // Assuming the user is still on this screen with the dialog open
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SpecialistDashboardScreen(),
                  ),
                );
              }
            });
          }

          if (mounted) {
            debugPrint(
              'HelpScreen: Navigating to HelperMainScreen immediately (pending approval flow).',
            );
            // Navigate directly to Helper Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HelperMainScreen()),
            );
          }
        } else {
          debugPrint('HelpScreen: Image upload failed for one or more images.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService().translate('failed_upload')),
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        debugPrint('HelpScreen: Error during submission: $e');
        debugPrint('HelpScreen: Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('support_others'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [LanguagePopup(showText: false), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService().translate('join_community'),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ).animate().fadeIn().slideX(),
              const SizedBox(height: 8),
              Text(
                LocalizationService().translate('fill_details'),
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameController,
                label: LocalizationService().translate('full_name'),
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: LocalizationService().translate('phone_number'),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _wilayaController,
                      label: LocalizationService().translate('wilaya'),
                      icon: Icons.map_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _communeController,
                      label: LocalizationService().translate('commune'),
                      icon: Icons.location_city_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedSpecialty,
                decoration: InputDecoration(
                  labelText: LocalizationService().translate('specialty'),
                  prefixIcon: const Icon(
                    Icons.work_outline,
                    color: Color(0xFF059669),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF059669),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _specialties.map((String specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty,
                    child: Text(LocalizationService().translate(specialty)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSpecialty = newValue;
                  });
                },
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),

              const SizedBox(height: 32),

              Text(
                LocalizationService().translate('identity_verification'),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildImagePicker(
                      label: LocalizationService().translate('id_front'),
                      image: _idCardFront,
                      onTap: () => _pickImage(
                        ImageSource.gallery,
                        (file) => _idCardFront = file,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImagePicker(
                      label: LocalizationService().translate('id_back'),
                      image: _idCardBack,
                      onTap: () => _pickImage(
                        ImageSource.gallery,
                        (file) => _idCardBack = file,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildImagePicker(
                label: LocalizationService().translate('take_selfie'),
                image: _selfie,
                onTap: () =>
                    _pickImage(ImageSource.camera, (file) => _selfie = file),
                isWide: true,
              ),
              const SizedBox(height: 16),
              _buildImagePicker(
                label: LocalizationService().translate('license_certificate'),
                image: _licenseImage,
                onTap: () => _pickImage(
                  ImageSource.gallery,
                  (file) => _licenseImage = file,
                ),
                isWide: true,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          LocalizationService().translate('submit_application'),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${LocalizationService().translate('please_enter')} $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF059669)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? image,
    required VoidCallback onTap,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: isWide ? double.infinity : null,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null
                ? const Color(0xFF059669)
                : Colors.grey.shade300,
            width: image != null ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(image.path, fit: BoxFit.cover)
                        : Image.file(File(image.path), fit: BoxFit.cover),
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
