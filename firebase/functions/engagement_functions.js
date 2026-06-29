/**
 * Engagement Service Cloud Functions
 * 親向けエンゲージメント管理の自動化機能
 *
 * デプロイ方法:
 * cd firebase/functions && firebase deploy --only functions:generateWeeklyChallenges,functions:aggregateSafetyScores
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Firestore インスタンス初期化
const db = admin.firestore();

// ─── (1) Daily Checkin Trigger ──────────────────────────────────────

/**
 * 子どもの学習完了時に親のチェックインを自動記録
 * Trigger: child_progress/{userId}/daily_activities にドキュメント作成時
 */
exports.recordParentCheckinOnChildActivity = functions
  .firestore
  .document('child_progress/{userId}/daily_activities/{activityId}')
  .onCreate(async (snap, context) => {
    const activityData = snap.data();
    const userId = context.params.userId;

    try {
      // 親IDを取得
      const userDoc = await db.collection('users').doc(userId).get();
      const parentId = userDoc.data()?.parentId;

      if (!parentId) {
        console.log(`No parent found for user ${userId}`);
        return;
      }

      // 親のチェックインを記録（本日のみ）
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const engagementRef = db.collection('parent_engagement').doc(parentId);
      const engagementSnap = await engagementRef.get();
      const engagementData = engagementSnap.data() || {};

      const lastCheckinDate = engagementData.lastCheckinDate
        ? new Date(engagementData.lastCheckinDate.toDate())
        : null;
      lastCheckinDate?.setHours(0, 0, 0, 0);

      let currentStreak = engagementData.currentStreak || 0;
      let maxStreak = engagementData.maxStreak || 0;

      // ストリークロジック
      if (!lastCheckinDate) {
        // 初回
        currentStreak = 1;
      } else if (today.getTime() - lastCheckinDate.getTime() === 86400000) {
        // 1日の差分（連続）
        currentStreak += 1;
      } else if (today.getTime() - lastCheckinDate.getTime() > 86400000) {
        // ストリーク途切れ
        currentStreak = 1;
      }
      // else: 同じ日（スキップ）

      maxStreak = Math.max(currentStreak, maxStreak);

      // Firestore 更新
      await engagementRef.set({
        parentId,
        lastCheckinDate: admin.firestore.Timestamp.fromDate(today),
        currentStreak,
        maxStreak,
        totalCheckins: (engagementData.totalCheckins || 0) + 1,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      console.log(
        `Parent ${parentId} checkin recorded: streak=${currentStreak}`
      );
    } catch (error) {
      console.error('Error recording parent checkin:', error);
    }
  });

// ─── (2) Weekly Challenge Generation ────────────────────────────────

/**
 * 毎週月曜午前0時に新しいチャレンジを自動生成
 * Trigger: 毎週月曜日に実行（Cloud Scheduler 経由）
 */
exports.generateWeeklyChallenges = functions
  .pubsub
  .schedule('0 0 ? * MON')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const now = new Date();
      const weekNumber = getWeekOfYear(now);

      // すべての親を取得
      const parentsSnap = await db
        .collection('parent_engagement')
        .get();

      let processedCount = 0;

      for (const parentDoc of parentsSnap.docs) {
        const parentId = parentDoc.id;
        const parentData = parentDoc.data();

        // 親の弱い詐欺パターンを判定
        const weakPattern = determineWeakFraudPattern(parentData);

        // チャレンジテンプレート
        const templates = {
          phishing: {
            title: 'フィッシング詐欺対策チャレンジ',
            description: '疑わしいメールリンクを見つけ出す練習',
            difficulty: 'medium',
            quizzesCount: 5,
            reward: 50,
          },
          fake_news: {
            title: '偽情報検証チャレンジ',
            description: 'SNS上の誤情報を判定する',
            difficulty: 'hard',
            quizzesCount: 5,
            reward: 75,
          },
          social_engineering: {
            title: 'ソーシャルエンジニアリング回避',
            description: '心理操作テクニックを学ぶ',
            difficulty: 'hard',
            quizzesCount: 5,
            reward: 75,
          },
          password_security: {
            title: 'パスワードセキュリティ',
            description: '強力で安全なパスワード作成',
            difficulty: 'easy',
            quizzesCount: 3,
            reward: 30,
          },
          payment_fraud: {
            title: '決済詐欺検出チャレンジ',
            description: '不正な支払いリクエストを識別',
            difficulty: 'medium',
            quizzesCount: 5,
            reward: 50,
          },
        };

        const challenge = templates[weakPattern] || templates.phishing;

        // チャレンジドキュメント作成
        await db
          .collection('parent_engagement')
          .doc(parentId)
          .collection('weekly_challenges')
          .doc(`week_${weekNumber}`)
          .set({
            parentId,
            weekNumber,
            startDate: admin.firestore.Timestamp.fromDate(now),
            endDate: admin.firestore.Timestamp.fromDate(
              new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000)
            ),
            fraudPattern: weakPattern,
            ...challenge,
            completed: false,
            completedAt: null,
            quizzesCompleted: 0,
          });

        processedCount++;
      }

      console.log(
        `Generated ${processedCount} weekly challenges for week ${weekNumber}`
      );
      return { success: true, processedCount };
    } catch (error) {
      console.error('Error generating weekly challenges:', error);
      throw error;
    }
  });

// ─── (3) Safety Score Aggregation ──────────────────────────────────

/**
 * 毎日午前1時にセーフティスコアを集計・更新
 * Trigger: 毎日午前1時（Cloud Scheduler 経由）
 */
exports.aggregateSafetyScores = functions
  .pubsub
  .schedule('0 1 * * *')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const parentsSnap = await db
        .collection('parent_engagement')
        .get();

      let processedCount = 0;

      for (const parentDoc of parentsSnap.docs) {
        const parentId = parentDoc.id;
        const parentData = parentDoc.data();

        // セーフティスコア計算
        const aiTruthScore = parentData.aiTruthScore || 0;
        const crimeQuizScore = parentData.crimeQuizScore || 0;
        const safetyRiskScore = await calculateSafetyRisk(parentId);

        // 加重平均: AI 30% + クイズ 40% + リスク評価 30%
        const totalSafetyScore =
          (aiTruthScore * 0.30) +
          (crimeQuizScore * 0.40) +
          (safetyRiskScore * 0.30);

        // 更新
        await parentDoc.ref.update({
          aiTruthScore,
          crimeQuizScore,
          safetyRiskScore,
          totalSafetyScore,
          safetyScoreUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        processedCount++;
      }

      console.log(`Aggregated safety scores for ${processedCount} parents`);
      return { success: true, processedCount };
    } catch (error) {
      console.error('Error aggregating safety scores:', error);
      throw error;
    }
  });

// ─── (4) Milestone Detection & Badge Award ─────────────────────────

/**
 * 毎日午前2時にマイルストーンを検出し、バッジを授与
 * Trigger: 毎日午前2時（Cloud Scheduler 経由）
 */
exports.detectAndAwardMilestones = functions
  .pubsub
  .schedule('0 2 * * *')
  .timeZone('Asia/Tokyo')
  .onRun(async (context) => {
    try {
      const parentsSnap = await db
        .collection('parent_engagement')
        .get();

      let processedCount = 0;
      let totalBadgesAwarded = 0;

      for (const parentDoc of parentsSnap.docs) {
        const parentId = parentDoc.id;
        const parentData = parentDoc.data();
        const existingBadges = parentData.badges || [];

        const newBadges = [];

        // ストリークバッジ
        const currentStreak = parentData.currentStreak || 0;
        if (currentStreak >= 7 && !existingBadges.includes('streak_7days')) {
          newBadges.push('streak_7days');
        }
        if (
          currentStreak >= 14 &&
          !existingBadges.includes('streak_14days')
        ) {
          newBadges.push('streak_14days');
        }
        if (
          currentStreak >= 30 &&
          !existingBadges.includes('streak_30days')
        ) {
          newBadges.push('streak_30days');
        }

        // セーフティバッジ
        const safetyScore = parentData.totalSafetyScore || 0;
        if (safetyScore >= 85 && !existingBadges.includes('safety_master')) {
          newBadges.push('safety_master');
        }
        if (safetyScore >= 70 && !existingBadges.includes('safety_expert')) {
          newBadges.push('safety_expert');
        }

        // エンゲージメントバッジ
        const totalCheckins = parentData.totalCheckins || 0;
        if (totalCheckins >= 10 && !existingBadges.includes('engaged_10')) {
          newBadges.push('engaged_10');
        }
        if (totalCheckins >= 30 && !existingBadges.includes('engaged_30')) {
          newBadges.push('engaged_30');
        }
        if (totalCheckins >= 100 && !existingBadges.includes('engaged_100')) {
          newBadges.push('engaged_100');
        }

        // チャレンジ完了バッジ
        const challengesSnap = await db
          .collection('parent_engagement')
          .doc(parentId)
          .collection('weekly_challenges')
          .where('completed', '==', true)
          .get();

        const completedCount = challengesSnap.size;
        if (
          completedCount >= 5 &&
          !existingBadges.includes('challenge_master_5')
        ) {
          newBadges.push('challenge_master_5');
        }

        // バッジ授与
        if (newBadges.length > 0) {
          const updatedBadges = [...new Set([...existingBadges, ...newBadges])];
          await parentDoc.ref.update({
            badges: updatedBadges,
            badgesUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          totalBadgesAwarded += newBadges.length;
        }

        processedCount++;
      }

      console.log(
        `Detected milestones: ${processedCount} parents, ${totalBadgesAwarded} badges awarded`
      );
      return { success: true, processedCount, totalBadgesAwarded };
    } catch (error) {
      console.error('Error detecting milestones:', error);
      throw error;
    }
  });

// ─── Helper Functions ────────────────────────────────────────────────

/**
 * 親の弱い詐欺パターンを判定
 */
function determineWeakFraudPattern(parentData) {
  const patterns = {
    phishing: parentData.phishingFailureCount || 0,
    fake_news: parentData.fakeNewsFailureCount || 0,
    social_engineering: parentData.socialEngineeringFailureCount || 0,
    password_security: parentData.passwordSecurityFailureCount || 0,
    payment_fraud: parentData.paymentFraudFailureCount || 0,
  };

  // 最も失敗回数が多いパターンを返す
  const weakest = Object.entries(patterns).reduce((a, b) =>
    a[1] > b[1] ? a : b
  );

  return weakest[0];
}

/**
 * セーフティリスク評価（過去90日間）
 */
async function calculateSafetyRisk(parentId) {
  try {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const logsSnap = await db
      .collection('parent_engagement')
      .doc(parentId)
      .collection('activity_logs')
      .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(ninetyDaysAgo))
      .get();

    if (logsSnap.empty) return 100; // アクティビティなし = 安全

    let suspiciousCount = 0;
    for (const doc of logsSnap.docs) {
      const data = doc.data();
      if (data.actionType === 'suspicious' || data.riskLevel === 'high') {
        suspiciousCount++;
      }
    }

    // リスクスコア = 100 - (疑わしい行動数 / 総行動数 * 100)
    const riskPercentage = (suspiciousCount / logsSnap.size) * 100;
    return Math.max(0, Math.min(100, 100 - riskPercentage));
  } catch (error) {
    console.error('Error calculating safety risk:', error);
    return 50; // エラー時はニュートラル
  }
}

/**
 * ISO 8601 週番号を取得
 */
function getWeekOfYear(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  const dayNum = d.getUTCDay() || 7;
  d.setUTCDate(d.getUTCDate() + 4 - dayNum);
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
  return Math.ceil(((d - yearStart) / 86400000 + 1) / 7);
}

/**
 * Callable Function: チャレンジ進捗更新
 */
exports.updateChallengeProgress = functions
  .https
  .onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { parentId, weekNumber, completedQuizzes } = data;

    try {
      const docRef = db
        .collection('parent_engagement')
        .doc(parentId)
        .collection('weekly_challenges')
        .doc(`week_${weekNumber}`);

      const docSnap = await docRef.get();
      if (!docSnap.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Challenge not found'
        );
      }

      const totalQuizzes = docSnap.data().quizzesCount || 5;

      await docRef.update({
        quizzesCompleted: completedQuizzes,
        completed: completedQuizzes >= totalQuizzes,
        completedAt:
          completedQuizzes >= totalQuizzes
            ? admin.firestore.FieldValue.serverTimestamp()
            : null,
      });

      return {
        success: true,
        completed: completedQuizzes >= totalQuizzes,
      };
    } catch (error) {
      console.error('Error updating challenge progress:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });

/**
 * Callable Function: アクティビティログ記録
 */
exports.logParentActivity = functions
  .https
  .onCall(async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        'User must be authenticated'
      );
    }

    const { parentId, actionType, details, riskLevel } = data;

    try {
      await db
        .collection('parent_engagement')
        .doc(parentId)
        .collection('activity_logs')
        .add({
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          actionType,
          riskLevel: riskLevel || 'low',
          details,
        });

      return { success: true };
    } catch (error) {
      console.error('Error logging activity:', error);
      throw new functions.https.HttpsError('internal', error.message);
    }
  });
