import 'dart:convert';
import 'package:http/http.dart' as http;

class AssessmentQuestion {
  final String id;
  final String text;
  final AssessmentType type;
  final List<String>? options;

  AssessmentQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'],
      text: json['text'],
      type: AssessmentType.values.firstWhere(
        (e) => e.toString() == 'AssessmentType.${json['type']}',
      ),
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
    );
  }
}

enum AssessmentType { yesNo, open, choice }

class AssessmentStage {
  final String title;
  final String goal;
  final List<AssessmentQuestion> questions;

  AssessmentStage({
    required this.title,
    required this.goal,
    required this.questions,
  });
}

class AssessmentService {
  static final AssessmentService _instance = AssessmentService._internal();
  factory AssessmentService() => _instance;
  AssessmentService._internal();

  // Base questions in Algerian Arabic
  final List<AssessmentStage> _baseStages = [
    AssessmentStage(
      title: 'المرحلة الأولى: "واش راهو في خاطرك؟" (القلق والتوتر)',
      goal: 'كسر الجليد بأسئلة نفسية عامة.',
      questions: [
        AssessmentQuestion(
          id: 's1_q1',
          text: 'تحس روحك "ستريسي" أغلب الوقت؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q2',
          text: 'مازالك تستمتع بالحوايج اللي كنت تحب ديرهم بكري؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q3',
          text: 'يجيك هذاك الشعور بالخوف، شغل كاينة حاجة عيانة راح تصرى؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q4',
          text: 'تقدر تضحك وتشوف الجانب المليح في الأمور عادي؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q5',
          text: 'كاين أفكار مقلقة راهي تدور في راسك بزاف وما حبستش؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q6',
          text: 'كي تنوض الصباح، تحس روحك ناشط ومريح ولا عيان؟',
          type: AssessmentType.choice,
          options: ['ناشط ومريح', 'عيان'],
        ),
        AssessmentQuestion(
          id: 's1_q7',
          text: 'تجيك هذيك الخلعة ولا خوف مفاجئ بلا سيرة؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q8',
          text: 'تحس بلي تفكيرك ولا حركتك تقالوا شوية على قبل ؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q9',
          text: 'تحس بلي حاب تبكي بلا ما تعرف السبة علاش؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's1_q10',
          text: 'مازالك متهلي في روحك وفي لبستك كيما زمان؟',
          type: AssessmentType.yesNo,
        ),
      ],
    ),
    AssessmentStage(
      title: 'المرحلة الثانية: "مساحتك الخاصة" (بداية الثقة)',
      goal: 'جس نبض الرغبة في التغيير بأسلوب غير اتهامي.',
      questions: [
        AssessmentQuestion(
          id: 's2_q1',
          text: 'بانتلي بلي ما كاين حتى حاجة تستاهل نبدلها في حياتي درك.؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q2',
          text: 'بدأت نحس بلي كاين "عوايد" تقدر تديرلي مشاكل من بعد.؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q3',
          text:
              'راني نحوس بالصح على طريقة تعاوني باش "نقص" ولا "نحبس".هذا السم؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q4',
          text:
              'هاد الأيامات، بدأت ندير خطوات و مع انها صغيرة باش نبدل روتيني.؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q5',
          text: 'ساعات نحس روحي "تالف" وما عرفتش منين نبدأ باش نداوي؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q6',
          text: 'علبالي بلي حياتي راح تكون خير بزااااف بلا هاد "السموم".؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q7',
          text: 'الصراحة، راني خايف نفشل لوكان نسيي نحبس درك.؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q8',
          text: 'محتاج لواحد يسمعني ويوجهني، بلا ما يحكم عليا ولا يلومني.؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q9',
          text:
              'بدأت نسيي نبعد على البلايص والناس اللي يفكروني في "الكونسوماسيون؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's2_q10',
          text:
              'راني واجد نتبع برنامج تاع علاج، المهم تكون "السترة" كاينة 100%.',
          type: AssessmentType.yesNo,
        ),
      ],
    ),
    AssessmentStage(
      title: 'المرحلة الثالثة: "بكل صراحة" (أسئلة الإدمان والخطورة)',
      goal: 'الوصول لعمق المشكلة بعدما اطمأن المستخدم للتطبيق.',
      questions: [
        AssessmentQuestion(
          id: 's3_q1',
          text:
              'كاش مرة استعملت مواد (دوا ولا غيره) بلا ما يكون عندك وصفة طبية؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q2',
          text: 'فات عليك وقت وين استعملت أكثر من مادة في نفس الوقت (خلطت)؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q3',
          text: 'تحس بلي راهو من الصعب عليك "تحبس" وقت ما تحب؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q4',
          text: 'ندمت ولا وجعك قلبك بعد آخر مرة "كونسوميت" فيها؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q5',
          text: 'كاش مرة عايروك داركم ولا أصحابك بسب السلوك تاعك؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q6',
          text:
              'ضيعت قرايتك، خدمتك ولا مسؤولياتك بسب هاد الحاجة اللي تستعملها؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q7',
          text: 'صرالك مشاكل مع "لابوليس" ولا دخلت في قضايا بسب "الكونسو"؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q8',
          text: 'يجيك المونك واعر و توجعك كي تحاول تحبس؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q9',
          text: 'صرالك مشكل صحي (طحت، دخت) بسبة "لادوز" (الجرعة)؟',
          type: AssessmentType.yesNo,
        ),
        AssessmentQuestion(
          id: 's3_q10',
          text:
              'سيت تطلب المساعدة من قبل في "سونتر" (مركز علاج) وما قدرتش تكمل؟',
          type: AssessmentType.yesNo,
        ),
      ],
    ),
    AssessmentStage(
      title: 'المرحلة الرابعة: "نظام الوقاية" (المحفزات)',
      goal: 'تحديد مسببات الخطر بربطها بالواقع.',
      questions: [
        AssessmentQuestion(
          id: 's4_q1',
          text:
              'شكون هما الناس اللي كي تشوفهم تجيك الرغبة باش تعاود "تكونسومي"؟',
          type: AssessmentType.open,
        ),
        AssessmentQuestion(
          id: 's4_q2',
          text:
              'واش هو الوقت في النهار اللي تحس فيه بضيق كبير؟ (الليل، وقت الفراغ، الصباح).',
          type: AssessmentType.open,
        ),
        AssessmentQuestion(
          id: 's4_q3',
          text: 'هل المشاكل تاع الدراهم هي اللي تخليك تهرب لهاد الطريق؟',
          type: AssessmentType.open,
        ),
        AssessmentQuestion(
          id: 's4_q4',
          text: 'احكيلي واش راهو يدور في راسك دركا بكل صراحة.. فرغ قلبك.',
          type: AssessmentType.open,
        ),
        AssessmentQuestion(
          id: 's4_q5',
          text:
              'لوكان تجيك الرغبة دركا باش تتعاطى، واش هي أول حاجة تقدر ديرها باش تمنع روحك؟',
          type: AssessmentType.open,
        ),
      ],
    ),
  ];

  Future<List<AssessmentStage>> getQuestions(
    String country,
    String languageCode,
  ) async {
    // If it's Algeria and Arabic, return base stages (they are already in Algerian Arabic)
    if (languageCode == 'ar' && country == 'Algeria') {
      return _baseStages;
    }

    String targetLanguage = languageCode;
    if (languageCode == 'en') {
      targetLanguage = 'English ($country accent/dialect)';
    } else if (languageCode == 'fr') {
      targetLanguage = 'French ($country accent/dialect)';
    } else if (languageCode == 'ar') {
      targetLanguage = 'Arabic ($country dialect)';
    } else {
      targetLanguage = '$languageCode ($country accent/dialect)';
    }

    return await _adaptQuestionsWithLLM(_baseStages, country, targetLanguage);
  }

  Future<List<AssessmentStage>> _adaptQuestionsWithLLM(
    List<AssessmentStage> stages,
    String country,
    String targetLanguage,
  ) async {
    try {
      final prompt = {
        'model': 'google/gemini-flash-1.5', // Using a fast model
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful translator. Translate the following JSON structure of assessment questions to $targetLanguage. Maintain the exact JSON structure. Only translate the "text", "title", "goal" and "options" fields. Do not change IDs or Types. Return ONLY the JSON.',
          },
          {
            'role': 'user',
            'content': jsonEncode(
              stages
                  .map(
                    (s) => {
                      'title': s.title,
                      'goal': s.goal,
                      'questions': s.questions
                          .map(
                            (q) => {
                              'id': q.id,
                              'text': q.text,
                              'type': q.type.toString().split('.').last,
                              'options': q.options,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            ),
          },
        ],
      };

      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization':
              'Bearer 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',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data['choices'][0]['message']['content'];

        // Clean up markdown if present
        if (content.contains('```')) {
          final start = content.indexOf('```');
          final end = content.lastIndexOf('```');
          if (end > start) {
            content = content.substring(start + 3, end);
            if (content.trim().startsWith('json')) {
              content = content.trim().substring(4);
            }
          }
        }

        // Ensure we only have the JSON array
        final startBracket = content.indexOf('[');
        final endBracket = content.lastIndexOf(']');
        if (startBracket != -1 && endBracket != -1) {
          content = content.substring(startBracket, endBracket + 1);
        }

        final List<dynamic> jsonList = jsonDecode(content);

        return jsonList.map((stageJson) {
          return AssessmentStage(
            title: stageJson['title'],
            goal: stageJson['goal'],
            questions: (stageJson['questions'] as List).map((qJson) {
              return AssessmentQuestion.fromJson(qJson);
            }).toList(),
          );
        }).toList();
      }
    } catch (e) {
      print('Error adapting questions: $e');
    }

    // Fallback to base stages if anything fails
    return _baseStages;
  }
}
