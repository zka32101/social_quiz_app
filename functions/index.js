const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();

/**
 * 毎週日曜 00:00 JST に週間ランキングをリセット
 * Cloud Scheduler で毎週日曜 00:00 に実行するように設定
 */
exports.resetWeeklyRankingScheduled = functions.pubsub
  .schedule("0 0 * * 0")
  .timeZone("Asia/Tokyo")
  .onRun(async (context) => {
    console.log("Starting weekly ranking reset...");
    try {
      const snapshot = await db
        .collection("leaderboards/weekly/entries")
        .get();

      const batch = db.batch();
      let deletedCount = 0;

      snapshot.forEach((doc) => {
        batch.delete(doc.ref);
        deletedCount++;
      });

      await batch.commit();
      console.log(`Weekly ranking reset completed. Deleted ${deletedCount} entries.`);
      return null;
    } catch (error) {
      console.error("Error resetting weekly ranking:", error);
      throw error;
    }
  });

/**
 * ユーザースコア更新時にランキングメタデータを更新
 * （オプション：検索パフォーマンス最適化用）
 */
exports.updateRankingMetadata = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const newData = change.after.data();
    const oldData = change.before.data();

    // stats が変更された場合のみ処理
    const oldStats = oldData?.stats || {};
    const newStats = newData?.stats || {};

    if (
      JSON.stringify(oldStats) === JSON.stringify(newStats)
    ) {
      return null;
    }

    const displayName = newData.displayName || "名無しさん";
    const profileImageUrl = newData.profileImageUrl || null;

    const entry = {
      userId: userId,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      totalScore: newStats.totalScore || 0,
      totalCorrect: newStats.totalCorrect || 0,
      totalPlayed: newStats.totalPlayed || 0,
      correctRate: newStats.correctRate || 0.0,
      badgeCount: newData.badgeCount || 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    try {
      // グローバル・週間ランキングを更新（set + merge でドキュメント未作成でも作成される）
      await db
        .collection("leaderboards/global/entries")
        .doc(userId)
        .set(entry, {merge: true});

      await db
        .collection("leaderboards/weekly/entries")
        .doc(userId)
        .set(entry, {merge: true});

      console.log(`Updated ranking metadata for user ${userId}`);
      return null;
    } catch (error) {
      console.error(`Error updating ranking metadata for user ${userId}:`, error);
      // 更新失敗は silently fail（クイズ進行に影響しない）
      return null;
    }
  });

/**
 * ユーザー作成時に初期統計を作成
 */
exports.initializeUserStats = functions.auth
  .user()
  .onCreate(async (user) => {
    const userId = user.uid;
    const email = user.email || "";
    const displayName = user.displayName || "ゲスト";

    try {
      await db.collection("users").doc(userId).set(
        {
          userId: userId,
          email: email,
          displayName: displayName,
          profileImageUrl: user.photoURL || null,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          lastPlayedAt: admin.firestore.FieldValue.serverTimestamp(),
          stats: {
            totalScore: 0,
            totalCorrect: 0,
            totalPlayed: 0,
            correctRate: 0.0,
            longestStreak: 0,
            currentStreak: 0,
            badgeCount: 0,
            bonusPointsEarned: 0,
            dailyQuizPlayed: 0,
          },
          badges: [],
          coins: 0,
        },
        { merge: true }
      );

      // ランキングエントリも作成（グローバル・週間の両方）
      const initialEntry = {
        userId: userId,
        displayName: displayName,
        profileImageUrl: user.photoURL || null,
        totalScore: 0,
        totalCorrect: 0,
        totalPlayed: 0,
        correctRate: 0.0,
        badgeCount: 0,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await db
        .collection("leaderboards/global/entries")
        .doc(userId)
        .set(initialEntry);
      await db
        .collection("leaderboards/weekly/entries")
        .doc(userId)
        .set(initialEntry);

      console.log(`Initialized user ${userId}`);
      return null;
    } catch (error) {
      console.error(`Error initializing user ${userId}:`, error);
      throw error;
    }
  });
