import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/localization_service.dart';
import '../services/assessment_service.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  List<AssessmentStage>? _stages;
  bool _isLoading = true;
  int _currentStageIndex = 0;
  int _currentQuestionIndex = 0;

  // Store answers: {questionId: answer}
  // Answer can be int (0/1 for Yes/No) or String (for open ended)
  final Map<String, dynamic> _answers = {};
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final service = LocalizationService();
    final country = service.selectedCountry ?? 'Algeria';
    final lang = service.currentLocale.languageCode;

    final stages = await AssessmentService().getQuestions(country, lang);

    if (mounted) {
      setState(() {
        _stages = stages;
        _isLoading = false;
      });
    }
  }

  void _submitAnswer(dynamic answer) {
    if (_stages == null) return;

    final currentStage = _stages![_currentStageIndex];
    final currentQuestion = currentStage.questions[_currentQuestionIndex];

    setState(() {
      _answers[currentQuestion.id] = answer;
      _textController.clear();

      if (_currentQuestionIndex < currentStage.questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        if (_currentStageIndex < _stages!.length - 1) {
          _currentStageIndex++;
          _currentQuestionIndex = 0;
        } else {
          _showResult();
        }
      }
    });
  }

  void _showResult() {
    // Calculate score for Yes/No questions
    // Assuming Yes = 1, No = 0.
    // High score = High dependency/risk
    int score = 0;
    _answers.forEach((key, value) {
      if (value is int) {
        score += value;
      }
    });

    String status;
    Color statusColor;

    // Simple logic: 30 yes/no questions roughly.
    if (score <= 5) {
      status = LocalizationService().translate('low_dependency');
      statusColor = Colors.green;
    } else if (score <= 15) {
      status = LocalizationService().translate('medium_dependency');
      statusColor = Colors.orange;
    } else {
      status = LocalizationService().translate('high_dependency');
      statusColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 60,
                color: Color(0xFF059669),
              ),
              const SizedBox(height: 16),
              Text(
                LocalizationService().translate('assessment_complete'),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                LocalizationService().translate('assessment_result_prefix'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Close screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    LocalizationService().translate('finish'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0FDF4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF059669)),
              const SizedBox(height: 16),
              Text(
                LocalizationService().translate('preparing_assessment'),
                style: GoogleFonts.poppins(
                  color: const Color(0xFF059669),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentStage = _stages![_currentStageIndex];
    final currentQuestion = currentStage.questions[_currentQuestionIndex];
    final progress =
        (_currentStageIndex * 10 + _currentQuestionIndex) /
        35.0; // Approx total

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF059669)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          LocalizationService().translate('assessment'),
          style: GoogleFonts.poppins(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: const Color(0xFFD1FAE5),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF059669),
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 24),

              // Stage Title
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentStage.title,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 8),

              // Stage Goal
              Text(
                currentStage.goal,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(),

              const Spacer(flex: 1),

              // Question
              Text(
                    currentQuestion.text,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  )
                  .animate(key: ValueKey(currentQuestion.id))
                  .fadeIn()
                  .slideX(begin: 0.1, end: 0),

              const Spacer(flex: 2),

              // Answer Options
              if (currentQuestion.type == AssessmentType.yesNo) ...[
                _buildOptionButton(
                  text: LocalizationService().translate('yes'),
                  onTap: () => _submitAnswer(1),
                  color: const Color(0xFF059669),
                ),
                const SizedBox(height: 16),
                _buildOptionButton(
                  text: LocalizationService().translate('no'),
                  onTap: () => _submitAnswer(0),
                  color: Colors.red[400]!,
                  isOutlined: true,
                ),
              ] else if (currentQuestion.type == AssessmentType.choice) ...[
                ...currentQuestion.options!.map(
                  (opt) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildOptionButton(
                      text: opt,
                      onTap: () => _submitAnswer(
                        opt == currentQuestion.options![0] ? 1 : 0,
                      ), // Assuming first is positive/active
                      color: const Color(0xFF059669),
                      isOutlined: true,
                    ),
                  ),
                ),
              ] else if (currentQuestion.type == AssessmentType.open) ...[
                TextField(
                  controller: _textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: LocalizationService().translate('type_answer'),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        _submitAnswer(_textController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ],

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: isOutlined ? 0 : 4,
          side: isOutlined ? BorderSide(color: color, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
