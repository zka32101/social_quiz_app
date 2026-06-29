import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// Quiz data model
// ─────────────────────────────────────────────────────────────

class _QuizItem {
  final String question;
  final List<String> choices;
  final int correctIndex;

  const _QuizItem({
    required this.question,
    required this.choices,
    required this.correctIndex,
  });
}

// ─────────────────────────────────────────────────────────────
// Embedded quiz data for all 6 sections
// ─────────────────────────────────────────────────────────────

const Map<String, List<_QuizItem>> _quizData = {
  'seiji': [
    _QuizItem(
      question: '日本の法律を作る機関は？',
      choices: ['内閣', '国会', '裁判所', '警察'],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '衆議院と参議院をあわせて何という？',
      choices: ['行政府', '司法府', '国会', '内閣'],
      correctIndex: 2,
    ),
    _QuizItem(
      question: '日本の内閣のトップは？',
      choices: ['天皇', '内閣総理大臣', '最高裁判所長官', '衆議院議長'],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '裁判所が担当するのは？',
      choices: [
        '法律を作ること',
        '税金を集めること',
        '法律に基づいて判断すること',
        '選挙をおこなうこと',
      ],
      correctIndex: 2,
    ),
    _QuizItem(
      question: '日本国憲法が定める三権分立とは？',
      choices: [
        '立法・行政・司法が独立',
        '国・都道府県・市区町村が独立',
        '国会・内閣・裁判所が協力',
        '政党が三つに分かれること',
      ],
      correctIndex: 0,
    ),
  ],
  'senkyo': [
    _QuizItem(
      question: '日本で選挙権（投票できる年齢）は？',
      choices: ['18歳以上', '20歳以上', '25歳以上', '15歳以上'],
      correctIndex: 0,
    ),
    _QuizItem(
      question: '民主主義とは？',
      choices: [
        '一人の偉い人が決める',
        '国民が政治に参加する',
        '軍隊が国を守る',
        'お金持ちが決める',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '衆議院議員の任期は？',
      choices: ['4年', '6年', '2年', '8年'],
      correctIndex: 0,
    ),
    _QuizItem(
      question: '選挙で大切なのは？',
      choices: [
        '一番強い人に投票',
        '自分の考えで投票',
        '家族と同じ人に投票',
        '有名人に投票',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '国会議員を選ぶ選挙は？',
      choices: ['地方選挙', '国政選挙', '首長選挙', '市議選挙'],
      correctIndex: 1,
    ),
  ],
  'zeikin': [
    _QuizItem(
      question: '税金は何に使われる？',
      choices: [
        '政治家の給料のみ',
        '道路・学校・病院など公共サービス',
        '会社の利益',
        '外国への援助のみ',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '買い物をしたときにかかる税は？',
      choices: ['所得税', '消費税', '相続税', '固定資産税'],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '消費税の税率は現在何%？',
      choices: ['5%', '8%', '10%', '12%'],
      correctIndex: 2,
    ),
    _QuizItem(
      question: '税金を集める国の機関は？',
      choices: ['国会', '裁判所', '税務署', '警察署'],
      correctIndex: 2,
    ),
    _QuizItem(
      question: '税金が社会に役立つ例は？',
      choices: [
        '個人の貯金になる',
        '公立学校の授業料無料',
        '会社の利益になる',
        '政治家の豪邸を建てる',
      ],
      correctIndex: 1,
    ),
  ],
  'sangyo': [
    _QuizItem(
      question: '日本の主要な輸出品は？',
      choices: [
        '米・野菜・魚',
        '自動車・機械・電子部品',
        '石油・天然ガス',
        '綿・羊毛・木材',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: 'GDPとは？',
      choices: ['国の人口', '国内の経済活動の合計額', '国の面積', '国の軍事力'],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '日本が多く輸入しているものは？',
      choices: ['自動車', '機械製品', '石油・天然ガス・食料', '電子部品'],
      correctIndex: 2,
    ),
    _QuizItem(
      question: '農業・漁業・林業をまとめて何という？',
      choices: ['第一次産業', '第二次産業', '第三次産業', '第四次産業'],
      correctIndex: 0,
    ),
    _QuizItem(
      question: '日本経済の課題は？',
      choices: [
        '人口増加',
        '少子高齢化',
        '農業の過剰生産',
        '輸出が多すぎること',
      ],
      correctIndex: 1,
    ),
  ],
  'boeki': [
    _QuizItem(
      question: '日本の最大の貿易相手国（輸出）は？',
      choices: ['アメリカ', '中国', 'ドイツ', 'インド'],
      correctIndex: 0,
    ),
    _QuizItem(
      question: '輸出が輸入より多い状態を？',
      choices: ['貿易赤字', '貿易黒字', '貿易均衡', '貿易停止'],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '日本が資源を輸入している主な理由は？',
      choices: [
        '国内に資源が多い',
        '国内に資源が少ない',
        '外国の資源が安い',
        '輸入が楽だから',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '国際連合の主な目的は？',
      choices: [
        '世界の軍事力を強める',
        '世界平和と安全を守る',
        '貿易を増やす',
        '宇宙開発',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '貿易に使われる共通語は主に？',
      choices: ['日本語', '中国語', '英語', 'スペイン語'],
      correctIndex: 2,
    ),
  ],
  'kankyo': [
    _QuizItem(
      question: '地球温暖化の主な原因は？',
      choices: [
        '火山の噴火',
        '二酸化炭素などの温室効果ガス',
        '太陽の活動変化',
        '月の引力',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: 'SDGsとは何の略？',
      choices: [
        '持続可能な開発目標',
        '科学技術の発展目標',
        '経済成長目標',
        '軍事削減目標',
      ],
      correctIndex: 0,
    ),
    _QuizItem(
      question: '3Rとは？',
      choices: [
        '読む・書く・計算',
        'リデュース・リユース・リサイクル',
        '走る・泳ぐ・飛ぶ',
        '赤・青・緑',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '日本の公害問題で有名な水俣病の原因は？',
      choices: [
        '大気汚染',
        '工場からの有害物質が海を汚染',
        '放射線',
        '農薬の過剰使用',
      ],
      correctIndex: 1,
    ),
    _QuizItem(
      question: '再生可能エネルギーの例は？',
      choices: [
        '石油・石炭・天然ガス',
        '太陽光・風力・水力',
        '原子力・核融合',
        'ガソリン・軽油',
      ],
      correctIndex: 1,
    ),
  ],
};

// Section display titles for AppBar
const Map<String, String> _sectionTitles = {
  'seiji': '日本の政治のしくみ',
  'senkyo': '選挙と民主主義',
  'zeikin': '税金とくらし',
  'sangyo': '日本の産業と経済',
  'boeki': '貿易と国際関係',
  'kankyo': '環境問題',
};

// ─────────────────────────────────────────────────────────────
// Quiz Screen
// ─────────────────────────────────────────────────────────────

class EconomicsQuizScreen extends ConsumerStatefulWidget {
  final String sectionId;

  const EconomicsQuizScreen({super.key, required this.sectionId});

  @override
  ConsumerState<EconomicsQuizScreen> createState() =>
      _EconomicsQuizScreenState();
}

class _EconomicsQuizScreenState extends ConsumerState<EconomicsQuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _totalCoins = 0;
  int _totalPoints = 0;
  bool _finished = false;

  List<_QuizItem> get _questions =>
      _quizData[widget.sectionId] ?? _quizData['seiji']!;

  String get _sectionTitle =>
      _sectionTitles[widget.sectionId] ?? '経済・政治クイズ';

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _buildResultScreen(context);
    }
    return _buildQuizScreen(context);
  }

  // ─── Quiz UI ───────────────────────────────────────────────

  Widget _buildQuizScreen(BuildContext context) {
    final questions = _questions;
    final quiz = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ─── Green gradient header ─────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _confirmExit(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _sectionTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '問題 ${_currentIndex + 1} / ${questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Points display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalPoints pt',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('🪙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalCoins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Question icon + text
                  const Center(
                    child: Text('❓', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    quiz.question,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Answer choices
                  ...quiz.choices.asMap().entries.map((entry) {
                    return _buildChoiceButton(entry.key, entry.value, quiz);
                  }),

                  // Feedback after answer
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackCard(quiz),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1 ? '次の問題へ' : '結果を見る',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(int index, String choice, _QuizItem quiz) {
    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);
    Color textColor = const Color(0xFF333333);
    Color labelBgColor = AppColors.primary;

    if (_answered) {
      if (index == quiz.correctIndex) {
        bgColor = const Color(AppColors.correctBgValue);
        borderColor = const Color(AppColors.correctValue);
        textColor = const Color(AppColors.correctValue);
        labelBgColor = const Color(AppColors.correctValue);
      } else if (index == _selectedIndex) {
        bgColor = const Color(AppColors.incorrectBgValue);
        borderColor = const Color(AppColors.incorrectValue);
        textColor = const Color(0xFFC0392B);
        labelBgColor = const Color(0xFFC0392B);
      } else {
        bgColor = Colors.white.withOpacity(0.6);
        labelBgColor = const Color(0xFFBBBBBB);
      }
    } else if (index == _selectedIndex) {
      bgColor = const Color(0xFFE8F8F5);
      borderColor = AppColors.primary;
      labelBgColor = AppColors.primaryDarkColor;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: _answered ? null : () => _selectAnswer(index, quiz),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // A / B / C / D label
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  choice,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: (_answered && index == quiz.correctIndex)
                        ? FontWeight.bold
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (_answered && index == quiz.correctIndex)
                const Text(
                  '✓',
                  style: TextStyle(
                    color: Color(AppColors.correctValue),
                    fontSize: 20,
                  ),
                ),
              if (_answered &&
                  index == _selectedIndex &&
                  index != quiz.correctIndex)
                const Text(
                  '✗',
                  style: TextStyle(
                    color: Color(AppColors.incorrectValue),
                    fontSize: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(_QuizItem quiz) {
    final isCorrect = _selectedIndex == quiz.correctIndex;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(AppColors.correctBgValue)
            : const Color(AppColors.incorrectBgValue),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            isCorrect ? '✓ 正解！' : '✗ 不正解',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isCorrect
                  ? const Color(AppColors.correctValue)
                  : const Color(AppColors.incorrectValue),
            ),
          ),
          if (isCorrect) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppColors.correctValue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+5🪙 +10pt',
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
          if (!isCorrect) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '正解: ${quiz.choices[quiz.correctIndex]}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF444444),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Result screen ─────────────────────────────────────────

  Widget _buildResultScreen(BuildContext context) {
    final total = _questions.length;
    final percentage = total > 0 ? (_correctCount / total * 100).round() : 0;
    final emoji = percentage >= 80
        ? '🎉'
        : percentage >= 60
            ? '👍'
            : '📚';

    return Scaffold(
      backgroundColor: const Color(AppColors.bgLight),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Result banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'クイズ終了！',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _sectionTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Score card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$_correctCount / $total 問正解',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ScorePill(
                              label: '獲得コイン',
                              value: '🪙 $_totalCoins',
                            ),
                            _ScorePill(
                              label: '獲得ポイント',
                              value: '⭐ $_totalPoints pt',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentIndex = 0;
                        _selectedIndex = null;
                        _answered = false;
                        _correctCount = 0;
                        _totalCoins = 0;
                        _totalPoints = 0;
                        _finished = false;
                      });
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('もう一度挑戦'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home),
                    label: const Text('ホームへ戻る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logic ─────────────────────────────────────────────────

  void _selectAnswer(int index, _QuizItem quiz) {
    final isCorrect = index == quiz.correctIndex;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
        _totalCoins += 5;
        _totalPoints += 10;
      }
    });
  }

  void _nextQuestion(BuildContext context) {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    // Persist coins and points
    final notifier = ref.read(userProgressProvider.notifier);
    await notifier.addCoins(_totalCoins);
    await notifier.addPoints(_totalPoints);

    if (!mounted) return;
    setState(() => _finished = true);
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('クイズを中断しますか？'),
        content: const Text('進捗はここまでが保存されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('続ける'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.home);
            },
            child: const Text('中断する', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────

class _ScorePill extends StatelessWidget {
  final String label;
  final String value;

  const _ScorePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
