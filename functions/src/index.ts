import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Triggered when a new story is created
export const onStoryCreated = functions.firestore
  .document("stories/{storyId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    if (!data || !data.hashtagsList || !Array.isArray(data.hashtagsList)) {
      return null;
    }

    const tags: string[] = data.hashtagsList;
    if (tags.length === 0) return null;

    const batch = db.batch();

    tags.forEach((tag) => {
      const cleanTag = tag.toLowerCase().trim();
      if (!cleanTag) return;
      const tagRef = db.collection("hashtags").doc(cleanTag);
      
      batch.set(
        tagRef,
        {
          name: cleanTag,
          postCount: admin.firestore.FieldValue.increment(1),
          lastUsedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true } // Create if doesn't exist, increment if it does
      );
    });

    await batch.commit();
    return null;
  });

// Triggered when a story is deleted
export const onStoryDeleted = functions.firestore
  .document("stories/{storyId}")
  .onDelete(async (snap, context) => {
    const data = snap.data();
    if (!data || !data.hashtagsList || !Array.isArray(data.hashtagsList)) {
      return null;
    }

    const tags: string[] = data.hashtagsList;
    if (tags.length === 0) return null;

    const batch = db.batch();

    tags.forEach((tag) => {
      const cleanTag = tag.toLowerCase().trim();
      if (!cleanTag) return;
      const tagRef = db.collection("hashtags").doc(cleanTag);
      
      // Decrement the count
      batch.set(
        tagRef,
        {
          postCount: admin.firestore.FieldValue.increment(-1),
        },
        { merge: true }
      );
    });

    await batch.commit();
    return null;
  });

// Triggered when a story is updated
export const onStoryUpdated = functions.firestore
  .document("stories/{storyId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    const beforeTags: string[] = (beforeData.hashtagsList || []).map((t: string) => t.toLowerCase().trim()).filter(Boolean);
    const afterTags: string[] = (afterData.hashtagsList || []).map((t: string) => t.toLowerCase().trim()).filter(Boolean);

    // Find tags that were added
    const addedTags = afterTags.filter(tag => !beforeTags.includes(tag));
    // Find tags that were removed
    const removedTags = beforeTags.filter(tag => !afterTags.includes(tag));

    if (addedTags.length === 0 && removedTags.length === 0) {
      return null;
    }

    const batch = db.batch();

    addedTags.forEach((tag) => {
      const tagRef = db.collection("hashtags").doc(tag);
      batch.set(
        tagRef,
        {
          name: tag,
          postCount: admin.firestore.FieldValue.increment(1),
          lastUsedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );
    });

    removedTags.forEach((tag) => {
      const tagRef = db.collection("hashtags").doc(tag);
      batch.set(
        tagRef,
        {
          postCount: admin.firestore.FieldValue.increment(-1),
        },
        { merge: true }
      );
    });

    await batch.commit();
    return null;
  });

// Scheduled Cron Job to trigger nightly PostgreSQL metrics snapshot
export const triggerNightlySnapshot = functions.pubsub
  .schedule("0 1 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    try {
      // Calculate exactly yesterday's date to avoid timezone shift ambiguity
      const yesterday = new Date();
      yesterday.setUTCDate(yesterday.getUTCDate() - 1);
      const targetDate = yesterday.toISOString().split("T")[0]; // format: YYYY-MM-DD

      const backendUrl = "https://healing-milestones-api.onrender.com/api/internal/cron/nightly-snapshot";
      const cronSecret = process.env.CRON_SECRET || "super-secret-cron-key";
      
      console.log(`[cron] Triggering snapshot for target_date=${targetDate}`);

      const response = await fetch(`${backendUrl}?target_date=${targetDate}`, {
        method: "POST",
        headers: {
          "x-cron-secret": cronSecret
        }
      });

      if (!response.ok) {
        throw new Error(`Backend returned status ${response.status}: ${await response.text()}`);
      }

      console.log("[cron] Successfully triggered nightly snapshot.");
    } catch (error) {
      console.error("[cron] Failed to trigger nightly snapshot:", error);
    }
  });
