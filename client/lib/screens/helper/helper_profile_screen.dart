import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/localization_service.dart';

class HelperProfileScreen extends StatelessWidget {
  const HelperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('profile'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          LocalizationService().translate('profile_details'),
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
