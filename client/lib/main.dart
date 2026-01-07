import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'screens/help_screen.dart';
import 'screens/country_selection_screen.dart';
import 'screens/hooked_options_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/localization_service.dart';
import 'widgets/language_popup.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocalizationService(),
      builder: (context, child) {
        return MaterialApp(
          title: LocalizationService().translate('app_name'),
          debugShowCheckedModeBanner: false,
          locale: LocalizationService().currentLocale,
          supportedLocales: const [Locale('en'), Locale('fr'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF059669), // Emerald 600
              primary: const Color(0xFF059669),
              secondary: const Color(0xFF10B981), // Emerald 500
              surface: Colors.white,
              background: const Color(0xFFF0FDF4), // Emerald 50
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
            scaffoldBackgroundColor: const Color(0xFFF0FDF4),
          ),
          home: const CountrySelectionScreen(),
        );
      },
    );
  }
}

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Language Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const LanguagePopup(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logo / Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF059669).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.spa_rounded,
                      size: 64,
                      color: Color(0xFF059669),
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 32),

                  // Title with Shimmer
                  Shimmer.fromColors(
                        baseColor: const Color(0xFF064E3B),
                        highlightColor: const Color(0xFF34D399),
                        child: Text(
                          LocalizationService().translate('app_name'),
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 12),

                  Text(
                    LocalizationService().translate('tagline'),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 800.ms),

                  const Spacer(flex: 3),

                  // Help Me Button
                  _buildOptionCard(
                    context,
                    title: LocalizationService().translate('help_me'),
                    subtitle: LocalizationService().translate('analyze_danger'),
                    icon: Icons.shield_rounded,
                    color: const Color(0xFFEF4444), // Red for urgency
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => HelpMeAnalysisScreen()),
                    ),
                    delay: 300,
                    isFullWidth: true,
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          title: LocalizationService().translate('im_hooked'),
                          subtitle: LocalizationService().translate(
                            'start_recovery',
                          ),
                          icon: Icons.person_outline_rounded,
                          color: const Color(0xFF059669),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HookedOptionsScreen(),
                            ),
                          ),
                          delay: 400,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptionCard(
                          context,
                          title: LocalizationService().translate(
                            'i_want_to_help',
                          ),
                          subtitle: LocalizationService().translate(
                            'offer_support',
                          ),
                          icon: Icons.volunteer_activism_outlined,
                          color: const Color(0xFF047857),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => HelpScreen()),
                          ),
                          delay: 600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            width: isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }
}

class HelpMeAnalysisScreen extends StatefulWidget {
  const HelpMeAnalysisScreen({super.key});

  @override
  State<HelpMeAnalysisScreen> createState() => _HelpMeAnalysisScreenState();
}

class _HelpMeAnalysisScreenState extends State<HelpMeAnalysisScreen> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _analysisResult;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _analysisResult = null;
      });
    }
  }

  Future<void> _analyzeSituation() async {
    if (_textController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService().translate('please_provide_input'),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      List<Map<String, dynamic>> content = [];

      if (_textController.text.isNotEmpty) {
        content.add({
          "type": "text",
          "text":
              "Analyze this situation for potential danger, drug dependency risks, or health risks. Context: ${_textController.text}. Respond in ${LocalizationService().currentLocale.languageCode == 'ar'
                  ? 'Arabic'
                  : LocalizationService().currentLocale.languageCode == 'fr'
                  ? 'French'
                  : 'English'}.",
        });
      }

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        content.add({
          "type": "image_url",
          "image_url": {"url": "data:image/jpeg;base64,$base64Image"},
        });
      }

      // If only image, add a prompt
      if (_textController.text.isEmpty && _selectedImage != null) {
        content.insert(0, {
          "type": "text",
          "text":
              "Analyze this image for potential danger, drug dependency risks, or health risks. Identify if there are any medicaments, substances, or signs of distress. Respond in ${LocalizationService().currentLocale.languageCode == 'ar'
                  ? 'Arabic'
                  : LocalizationService().currentLocale.languageCode == 'fr'
                  ? 'French'
                  : 'English'}.",
        });
      }

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'google/gemini-flash-1.5', // Supports vision
          'messages': [
            {'role': 'user', 'content': content},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _analysisResult = data['choices'][0]['message']['content'];
        });
      } else {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _analysisResult =
            "${LocalizationService().translate('error_analyzing')} ($e)";
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService().translate('risk_analysis'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [LanguagePopup(showText: false), SizedBox(width: 8)],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFEF4444)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocalizationService().translate('describe_situation'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationService().translate('enter_details_hint'),
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: LocalizationService().translate('text_hint'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(LocalizationService().translate('take_photo')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(LocalizationService().translate('upload')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeSituation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isAnalyzing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      LocalizationService().translate('analyze_btn'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),

            if (_analysisResult != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFEF4444),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          LocalizationService().translate('analysis_result'),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _analysisResult!,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        height: 1.6,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }
}
