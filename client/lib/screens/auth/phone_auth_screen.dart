import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/localization_service.dart';
import '../help_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) _navigateToApplication();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'Verification failed')),
            );
            setState(() => _isLoading = false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty || _verificationId == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (mounted) _navigateToApplication();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Invalid code')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToApplication() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Phone Authentication',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _codeSent ? 'Enter OTP' : 'Enter Phone Number',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _codeSent
                  ? 'We have sent an SMS with a confirmation code to your phone.'
                  : 'Please enter your phone number in international format (e.g. +213...) to receive a verification code.',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            if (!_codeSent) ...[
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number (with country code)',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF059669)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPhone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Send Code',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ] else ...[
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '6-digit OTP Code',
                  prefixIcon: const Icon(Icons.message, color: Color(0xFF059669)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                maxLength: 6,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Verify Code',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
