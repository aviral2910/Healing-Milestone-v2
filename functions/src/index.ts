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
