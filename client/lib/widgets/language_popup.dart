import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/localization_service.dart';

class LanguagePopup extends StatelessWidget {
  final bool showText;
  final Color color;

  const LanguagePopup({
    super.key,
    this.showText = true,
    this.color = const Color(0xFF059669),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalizationService(),
      builder: (context, child) {
        return PopupMenuButton<String>(
          onSelected: (String code) {
            LocalizationService().changeLocale(code);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'en', child: Text('English')),
            const PopupMenuItem<String>(value: 'fr', child: Text('Français')),
            const PopupMenuItem<String>(value: 'ar', child: Text('العربية')),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, color: color, size: 20),
                if (showText) ...[
                  const SizedBox(width: 8),
                  Text(
                    LocalizationService().currentLocale.languageCode
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down_rounded, color: color, size: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
