import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/progress_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/explanation_with_image_widget.dart' as explanation;

// ─────────────────────────────────────────────────────────────
// Quiz data model
// ─────────────────────────────────────────────────────────────

class _QuizItem {
  final String id;
  final String question;
  final List<String> choices;
  final int correctIndex;
  final String explanation;

  const _QuizItem({
    required this.id,
    required this.question,
    required this.choices,
    required this.correctIndex,
    required this.explanation,
  });
}

// ─────────────────────────────────────────────────────────────
// Quiz data for all 6 sections
// ─────────────────────────────────────────────────────────────

const Map<String, List<_QuizItem>> _quizData = {
  'un': [
    _QuizItem(
      id: 'intl_un_1',
      question: '国際連合（国連）が設立された年は？',
      choices: ['1945年', '1956年', '1920年', '2000年'],
      correctIndex: 0,
      explanation: '国際連合（国連）は、第二次世界大戦後の1945年に、世界の平和を守るために設立されました。',
    ),
    _QuizItem(
      id: 'intl_un_2',
      question: '国連の本部がある都市は？',
      choices: ['ワシントンD.C.', 'ジュネーブ', 'ニューヨーク', 'パリ'],
      correctIndex: 2,
      explanation: '国連の本部はアメリカのニューヨークに置かれています。',
    ),
    _QuizItem(
      id: 'intl_un_3',
      question: '安全保障理事会の常任理事国はいくつ？',
      choices: ['3か国', '5か国', '7か国', '10か国'],
      correctIndex: 1,
      explanation: '安全保障理事会の常任理事国はアメリカ・イギリス・フランス・ロシア・中国の5か国です。',
    ),
    _QuizItem(
      id: 'intl_un_4',
      question: '日本が国連に加盟した年は？',
      choices: ['1945年', '1956年', '1970年', '1980年'],
      correctIndex: 1,
      explanation: '日本は1956年に国際連合に加盟しました。',
    ),
    _QuizItem(
      id: 'intl_un_5',
      question: '国連の目的は？',
      choices: [
        '世界の軍事力を強める',
        '世界平和と国際協力',
        '貿易の拡大のみ',
        '宇宙開発',
      ],
      correctIndex: 1,
      explanation: '国連は世界の平和と安全を守り、国と国との協力を進めることを目的としています。',
    ),
  ],
  'sdgs': [
    _QuizItem(
      id: 'intl_sdgs_1',
      question: 'SDGsが採択された年は？',
      choices: ['2000年', '2010年', '2015年', '2020年'],
      correctIndex: 2,
      explanation: 'SDGsは2015年の国連サミットで採択されました。',
    ),
    _QuizItem(
      id: 'intl_sdgs_2',
      question: 'SDGsの目標の数は？',
      choices: ['10', '15', '17', '20'],
      correctIndex: 2,
      explanation: 'SDGsは17の目標（ゴール）と169のターゲットから構成されています。',
    ),
    _QuizItem(
      id: 'intl_sdgs_3',
      question: 'SDGsの達成目標年は？',
      choices: ['2025年', '2030年', '2040年', '2050年'],
      correctIndex: 1,
      explanation: 'SDGsは2030年までの達成を目指して定められた国際目標です。',
    ),
    _QuizItem(
      id: 'intl_sdgs_4',
      question: 'SDGsとは何の略？',
      choices: [
        '持続可能な開発目標',
        '科学技術開発目標',
        '国連安全保障決議',
        '貿易拡大目標',
      ],
      correctIndex: 0,
      explanation: 'SDGsは「Sustainable Development Goals」の略で、日本語では「持続可能な開発目標」といいます。',
    ),
    _QuizItem(
      id: 'intl_sdgs_5',
      question: 'SDGsに含まれない目標は？',
      choices: [
        '貧困をなくそう',
        '気候変動に対策を',
        '核兵器の開発推進',
        'ジェンダー平等',
      ],
      correctIndex: 2,
      explanation: 'SDGsは貧困や環境問題の解決などを目指す目標であり、核兵器の開発推進のような目標は含まれていません。',
    ),
  ],
  'contribution': [
    _QuizItem(
      id: 'intl_contribution_1',
      question: 'ODAとは？',
      choices: [
        '政府開発援助',
        '国連平和維持活動',
        '自由貿易協定',
        '核不拡散条約',
      ],
      correctIndex: 0,
      explanation: 'ODA（Official Development Assistance）は、先進国が発展途上国の発展を支援するための「政府開発援助」です。',
    ),
    _QuizItem(
      id: 'intl_contribution_2',
      question: 'PKOとは？',
      choices: [
        '政府開発援助',
        '国連平和維持活動',
        '国際通貨基金',
        '世界貿易機関',
      ],
      correctIndex: 1,
      explanation: 'PKO（Peacekeeping Operations）は、紛争地域の平和と安定を保つための「国連平和維持活動」です。',
    ),
    _QuizItem(
      id: 'intl_contribution_3',
      question: 'UNICEFが主に支援しているのは？',
      choices: ['高齢者', '企業', '子どもたち', '軍隊'],
      correctIndex: 2,
      explanation: 'UNICEF（ユニセフ）は、世界中の子どもたちの命と権利を守るための活動をしている国連機関です。',
    ),
    _QuizItem(
      id: 'intl_contribution_4',
      question: '日本が国際貢献しているのはなぜ？',
      choices: [
        '軍事力を高めるため',
        '世界平和と発展に貢献するため',
        '輸出を増やすため',
        '資源を確保するため',
      ],
      correctIndex: 1,
      explanation: '日本は国際社会の一員として、世界の平和と発展に貢献するためODAなどの国際貢献を行っています。',
    ),
    _QuizItem(
      id: 'intl_contribution_5',
      question: 'フェアトレードとは？',
      choices: [
        '安く輸入することに重点を置いた貿易',
        '発展途上国の生産者が正当な対価を得る貿易',
        '無関税の自由貿易',
        '政府が管理する貿易',
      ],
      correctIndex: 1,
      explanation: 'フェアトレードとは、発展途上国の生産者が公正（フェア）な対価を得られるようにする貿易の仕組みです。',
    ),
  ],
  'world_issues': [
    _QuizItem(
      id: 'intl_world_issues_1',
      question: '世界で極度の貧困に苦しむ人はおよそ何億人？',
      choices: ['約1億人', '約5億人', '約8億人', '約20億人'],
      correctIndex: 2,
      explanation: '世界には1日1.9ドル未満で生活する「極度の貧困」状態にある人が約8億人いるといわれています。',
    ),
    _QuizItem(
      id: 'intl_world_issues_2',
      question: '難民とは？',
      choices: [
        '外国に仕事に行く人',
        '戦争や迫害で故郷を追われた人',
        '外国留学している人',
        '海外旅行者',
      ],
      correctIndex: 1,
      explanation: '難民とは、戦争や迫害などにより自分の国を追われ、他の国に逃れざるを得なくなった人々のことです。',
    ),
    _QuizItem(
      id: 'intl_world_issues_3',
      question: '気候変動が世界の問題になっている主な理由は？',
      choices: [
        '地震が増えているから',
         '温室効果ガスの増加で異常気象や海面上昇が起きているから',
        '人口が増えすぎているから',
        '森林が増えすぎているから',
      ],
      correctIndex: 1,
      explanation: '温室効果ガスの増加によって気温が上昇し、異常気象や海面上昇などの気候変動が引き起こされています。',
    ),
    _QuizItem(
      id: 'intl_world_issues_4',
      question: '世界の飢餓で苦しむ人はおよそ何億人？',
      choices: ['約1億人', '約3億人', '約7億人', '約15億人'],
      correctIndex: 2,
      explanation: '世界では十分な食料を得られず飢餓に苦しむ人が約7億人いるといわれています。',
    ),
    _QuizItem(
      id: 'intl_world_issues_5',
      question: '経済格差が拡大すると何が問題？',
      choices: [
        '貿易が増える',
        '教育や医療を受けられない人が増える',
        '経済全体が成長する',
        '環境が改善される',
      ],
      correctIndex: 1,
      explanation: '経済格差が拡大すると、十分な教育や医療を受けられない人が増え、社会の不安定化につながります。',
    ),
  ],
  'culture': [
    _QuizItem(
      id: 'intl_culture_1',
      question: '世界にはおよそ何種類の言語がある？',
      choices: ['約100', '約1,000', '約7,000', '約50,000'],
      correctIndex: 2,
      explanation: '世界には現在、約7,000種類もの言語があるといわれています。',
    ),
    _QuizItem(
      id: 'intl_culture_2',
      question: '国際共通語として最も広く使われる言語は？',
      choices: ['フランス語', '中国語', '英語', 'スペイン語'],
      correctIndex: 2,
      explanation: '国際的な場面で最も広く使われる共通語は英語です。',
    ),
    _QuizItem(
      id: 'intl_culture_3',
      question: '異文化理解とは？',
      choices: [
        '自国の文化だけを守ること',
        '違う文化を理解・尊重すること',
        '外国の文化を真似すること',
        '文化の違いを無視すること',
      ],
      correctIndex: 1,
      explanation: '異文化理解とは、自分と異なる文化や考え方を持つ人々を理解し、尊重することです。',
    ),
    _QuizItem(
      id: 'intl_culture_4',
      question: '多文化共生（たぶんかきょうせい）とは？',
      choices: [
        '一つの文化に統一すること',
        '異なる文化を持つ人が共に暮らす社会',
        '外国人を受け入れないこと',
        '文化を輸出すること',
      ],
      correctIndex: 1,
      explanation: '多文化共生とは、異なる文化や習慣を持つ人々が、互いを尊重しながら共に暮らす社会のことです。',
    ),
    _QuizItem(
      id: 'intl_culture_5',
      question: '日本のあいさつといえば？',
      choices: ['握手（あくしゅ）', 'おじぎ', '頬にキス', 'ハグ'],
      correctIndex: 1,
      explanation: '日本では、あいさつのときに頭を下げる「おじぎ」をする文化があります。',
    ),
  ],
  'global_citizen': [
    _QuizItem(
      id: 'intl_global_citizen_1',
      question: '地球市民（ちきゅうしみん）とは？',
      choices: [
        '地球に最初に住んだ人',
        '国や民族を超えて地球全体のことを考え行動できる人',
        '宇宙に行ったことのある人',
        '外国語が話せる人',
      ],
      correctIndex: 1,
      explanation: '地球市民とは、国や民族の違いを超えて、地球全体の問題を自分ごととして考え行動できる人のことです。',
    ),
    _QuizItem(
      id: 'intl_global_citizen_2',
      question: 'フェアトレード商品を選ぶ意味は？',
      choices: [
        '安く買えるから',
        '発展途上国の生産者の生活を支援できるから',
        '品質が悪いから',
        '輸入が増えるから',
      ],
      correctIndex: 1,
      explanation: 'フェアトレード商品を選ぶことで、発展途上国の生産者の生活を支え、公正な貿易を応援できます。',
    ),
    _QuizItem(
      id: 'intl_global_citizen_3',
      question: '身近な環境への取り組みとして正しいのは？',
      choices: [
        'ゴミを川に捨てる',
        '節電・ゴミの分別・マイバッグを使う',
        '車を増やす',
        '食べ残しを増やす',
      ],
      correctIndex: 1,
      explanation: '節電やゴミの分別、マイバッグの使用など、身近なところから環境を守る行動ができます。',
    ),
    _QuizItem(
      id: 'intl_global_citizen_4',
      question: 'SNSを使う地球市民として大切なことは？',
      choices: [
        '事実か確認せず情報を拡散する',
        '差別・偏見を広めない、情報を確認する',
        '外国の批判だけをする',
        '自分の情報を何でも公開する',
      ],
      correctIndex: 1,
      explanation: 'SNSでは、差別や偏見を広めず、情報が正しいかどうかを確認してから発信・共有することが大切です。',
    ),
    _QuizItem(
      id: 'intl_global_citizen_5',
      question: '地球市民としてできることは？',
      choices: [
        '外国のことを考えない',
        '環境配慮・異文化理解・ボランティア活動',
        '自分の国の利益だけを追求する',
        '外国語を学ばない',
      ],
      correctIndex: 1,
      explanation: '環境への配慮や異文化理解、ボランティア活動など、身近なことから地球市民としての行動を始められます。',
    ),
  ],
};

const Map<String, String> _sectionTitles = {
  'un': '国際連合（UN）',
  'sdgs': 'SDGs（持続可能な開発目標）',
  'contribution': '日本の国際貢献',
  'world_issues': '世界の問題',
  'culture': '異文化理解',
  'global_citizen': '地球市民として',
};

// ─────────────────────────────────────────────────────────────
// Quiz Screen
// ─────────────────────────────────────────────────────────────

class InternationalQuizScreen extends ConsumerStatefulWidget {
  final String sectionId;

  const InternationalQuizScreen({super.key, required this.sectionId});

  @override
  ConsumerState<InternationalQuizScreen> createState() =>
      _InternationalQuizScreenState();
}

class _InternationalQuizScreenState
    extends ConsumerState<InternationalQuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  int _correctCount = 0;
  int _totalCoins = 0;
  int _totalPoints = 0;
  bool _finished = false;

  List<_QuizItem> get _questions =>
      _quizData[widget.sectionId] ?? _quizData['un']!;

  String get _sectionTitle =>
      _sectionTitles[widget.sectionId] ?? '国際クイズ';

  static const Color _themeColor = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResultScreen(context);
    return _buildQuizScreen(context);
  }

  Widget _buildQuizScreen(BuildContext context) {
    final questions = _questions;
    final quiz = questions[_currentIndex];
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
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
                        IconButton(
                          onPressed: () => _confirmExit(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                              minWidth: 40, minHeight: 40),
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
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
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
                  const Center(
                    child: Text('🌐', style: TextStyle(fontSize: 48)),
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
                  ...quiz.choices.asMap().entries.map(
                    (entry) => _buildChoiceButton(entry.key, entry.value, quiz),
                  ),
                  if (_answered) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackCard(quiz),
                  ],
                ],
              ),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => _nextQuestion(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: _themeColor,
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
    Color labelBgColor = _themeColor;

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
        bgColor = Colors.white.withValues(alpha: 0.6);
        labelBgColor = const Color(0xFFBBBBBB);
      }
    } else if (index == _selectedIndex) {
      bgColor = const Color(0xFFE3F2FD);
      borderColor = _themeColor;
      labelBgColor = const Color(0xFF0D47A1);
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
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          if (quiz.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            explanation.ExplanationWithImage(
              explanation: quiz.explanation,
              imageKeyword: '経済',
              imageHeight: 180,
              padding: const EdgeInsets.all(0),
            ),
          ],
        ],
      ),
    );
  }

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 64)),
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
                            color: _themeColor,
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home),
                    label: const Text('ホームへ戻る'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor,
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

    if (!isCorrect) {
      ref.read(userProgressProvider.notifier).addWrongAnswer(quiz.id);
    }
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
          style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
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
