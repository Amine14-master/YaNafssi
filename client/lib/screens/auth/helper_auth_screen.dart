import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/localization_service.dart';
import '../help_screen.dart';
import 'phone_auth_screen.dart';

class HelperAuthScreen extends StatefulWidget {
  const HelperAuthScreen({super.key});

  @override
  State<HelperAuthScreen> createState() => _HelperAuthScreenState();
}

class _HelperAuthScreenState extends State<HelperAuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (isLogin) {
        // Sign In
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Sign Up
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        await userCred.user?.updateDisplayName(_nameController.text.trim());
      }
      
      if (mounted) {
        // Navigate to the HelpScreen to complete application or view status
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HelpScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('support_others') ?? 'Support Others',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isLogin ? 'Sign In to Help' : 'Sign Up to Help',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 32),
              
              if (!isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: LocalizationService().translate('full_name') ?? 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF059669)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF059669)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Please enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF059669)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitAuth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isLogin ? 'Sign In' : 'Sign Up',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 16),
              
              if (isLogin) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
                    );
                  },
                  icon: const Icon(Icons.phone_android, color: Color(0xFF059669)),
                  label: Text('Sign in with Phone', style: GoogleFonts.poppins(color: const Color(0xFF059669))),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: Color(0xFF059669)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
                  style: GoogleFonts.poppins(color: const Color(0xFF059669)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}