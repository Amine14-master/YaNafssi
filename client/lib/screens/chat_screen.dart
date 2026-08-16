import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/localization_service.dart';
import '../widgets/language_popup.dart';
import 'assessment_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': LocalizationService().translate('chat_intro'), 'isUser': false},
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _controller.clear();
      _isLoading = true;
    });

    final languageCode = LocalizationService().currentLocale.languageCode;
    final country = LocalizationService().selectedCountry ?? 'Algeria';
    String targetLanguage = 'English';
    if (languageCode == 'ar' && country == 'Algeria') {
      targetLanguage = 'Algerian Darija (written in Arabic script)';
    } else if (languageCode == 'en') {
      targetLanguage = 'English ($country accent/dialect)';
    } else if (languageCode == 'fr') {
      targetLanguage = 'French ($country accent/dialect)';
    } else if (languageCode == 'ar') {
      targetLanguage = 'Arabic ($country dialect)';
    } else {
      targetLanguage = '$languageCode ($country accent/dialect)';
    }

    try {
      final apiKey = 'AIzaSyALLDHf2L4rNWr-8RxiKOyzDM7S2ujSd4s';
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemma-4-31b-it:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                    'You are a compassionate and supportive AI assistant for people recovering from addiction. Listen to them, offer empathy, and encourage them gently. Keep responses concise and supportive.\n\nCRITICAL INSTRUCTIONS:\n1. ALWAYS respond DIRECTLY to the user in exactly this language/dialect: $targetLanguage, REGARDLESS of the language the user types in.\n2. DO NOT output any internal thoughts, translation steps, or structured metadata (like "User input:", "Context:", "Translation:").\n3. Provide ONLY the final, direct conversational reply.'
              }
            ]
          },
          'contents': _messages.map(
            (m) => {
              'role': m['isUser'] ? 'user' : 'model',
              'parts': [{'text': m['text']}],
            },
          ).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botReply = data['candidates'][0]['content']['parts'][0]['text'];

        if (mounted) {
          setState(() {
            _messages.add({'text': botReply, 'isUser': false});
          });
        }
      } else {
        print('Gemini API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load response');
      }
    } catch (e) {
      print('Chat Error Exception: $e');
      if (mounted) {
        setState(() {
          _messages.add({
            'text': LocalizationService().translate('chat_error'),
            'isUser': false,
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService().translate('support_chat'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          const LanguagePopup(showText: false),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AssessmentScreen()),
              );
            },
            child: Text(
              LocalizationService().translate('assessment'),
              style: GoogleFonts.poppins(
                color: const Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFF0FDF4),
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  LocalizationService().translate('talk_listening'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ).animate().shimmer(
                  duration: 2000.ms,
                  color: const Color(0xFF34D399),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'];
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF059669) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'],
                      style: GoogleFonts.poppins(
                        color: isUser ? Colors.white : const Color(0xFF1F2937),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0);
              },
            ),
          ),
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (index) =>
                          Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF059669),
                                  shape: BoxShape.circle,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .scale(delay: (index * 200).ms, duration: 600.ms),
                    ),
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: LocalizationService().translate('type_message'),
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF059669),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
