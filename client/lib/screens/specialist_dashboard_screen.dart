import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/localization_service.dart';

class SpecialistDashboardScreen extends StatelessWidget {
  const SpecialistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('specialist_dashboard'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.dashboard_customize_rounded,
              size: 80,
              color: Color(0xFF059669),
            ).animate().scale(),
            const SizedBox(height: 24),
            Text(
              LocalizationService().translate('welcome_specialist'),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              LocalizationService().translate('start_helping'),
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
