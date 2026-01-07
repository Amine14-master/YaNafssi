import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/localization_service.dart';
import 'chat_screen.dart';

class MoodSelectionScreen extends StatelessWidget {
  const MoodSelectionScreen({super.key});

  List<Map<String, String>> get moods => [
    {'emoji': '😔', 'label': LocalizationService().translate('mood_sad')},
    {'emoji': '😤', 'label': LocalizationService().translate('mood_angry')},
    {'emoji': '😰', 'label': LocalizationService().translate('mood_anxious')},
    {'emoji': '😐', 'label': LocalizationService().translate('mood_neutral')},
    {'emoji': '🙂', 'label': LocalizationService().translate('mood_okay')},
    {'emoji': '😫', 'label': LocalizationService().translate('mood_tired')},
    {
      'emoji': '🤯',
      'label': LocalizationService().translate('mood_overwhelmed'),
    },
    {'emoji': '🥺', 'label': LocalizationService().translate('mood_lonely')},
    {'emoji': '🤕', 'label': LocalizationService().translate('mood_hurt')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService().translate('how_feel'),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                  height: 1.2,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),

              const SizedBox(height: 16),

              Text(
                LocalizationService().translate('select_mood'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: moods.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ChatScreen()),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF059669,
                                  ).withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  moods[index]['emoji']!,
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  moods[index]['label']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: (100 * index).ms)
                        .scale(curve: Curves.easeOutBack);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
