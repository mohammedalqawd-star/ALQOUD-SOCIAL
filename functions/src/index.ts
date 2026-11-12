import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

function requireModerator(request: { auth?: { uid: string; token: Record<string, unknown> } | null }): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول.");
  }
  if (request.auth.token.admin !== true && request.auth.token.moderator !== true) {
    throw new HttpsError("permission-denied", "هذه العملية مخصصة لفريق المراجعة.");
  }
  return request.auth.uid;
}

async function updateReviewStatus(
  collection: "posts" | "comments",
  id: string,
  status: "published" | "rejected" | "approved"
): Promise<void> {
  if (!id || id.length > 180) {
    throw new HttpsError("invalid-argument", "معرّف المحتوى غير صالح.");
  }

  const ref = collection === "posts"
    ? db.collection("posts").doc(id)
    : db.collectionGroup("comments").where("__name__", "==", id).limit(1);

  if (collection === "posts") {
    const snap = await (ref as ReturnType<typeof db.collection>).get();
    if (!snap.exists) throw new HttpsError("not-found", "المنشور غير موجود.");
    if (snap.data()?.status !== "pending_review") {
      throw new HttpsError("failed-precondition", "المنشور ليس قيد المراجعة.");
    }
    await snap.ref.update({
      status,
      reviewedAt: FieldValue.serverTimestamp()
    });
    return;
  }

  const matches = await (ref as ReturnType<typeof db.collectionGroup>).get();
  if (matches.empty) throw new HttpsError("not-found", "التعليق غير موجود.");
  const comment = matches.docs[0];
  if (comment.data().status !== "pending_review") {
    throw new HttpsError("failed-precondition", "التعليق ليس قيد المراجعة.");
  }
  await comment.ref.update({
    status,
    reviewedAt: FieldValue.serverTimestamp()
  });
}

export const reviewPost = onCall({ region: "us-central1" }, async (request) => {
  const moderatorUid = requireModerator(request);
  const postId = request.data?.postId;
  const decision = request.data?.decision;
  if (typeof postId !== "string" || !["approve", "reject"].includes(decision)) {
    throw new HttpsError("invalid-argument", "بيانات مراجعة المنشور غير صحيحة.");
  }
  await updateReviewStatus("posts", postId, decision === "approve" ? "published" : "rejected");
  await db.collection("moderation_audit").add({
    moderatorUid, contentType: "post", contentId: postId, decision,
    createdAt: FieldValue.serverTimestamp()
  });
  return { success: true };
});

export const reviewComment = onCall({ region: "us-central1" }, async (request) => {
  const moderatorUid = requireModerator(request);
  const commentPath = request.data?.commentPath;
  const decision = request.data?.decision;
  if (typeof commentPath !== "string" ||
      !/^posts\/[^/]+\/comments\/[^/]+$/.test(commentPath) ||
      !["approve", "reject"].includes(decision)) {
    throw new HttpsError("invalid-argument", "بيانات مراجعة التعليق غير صحيحة.");
  }
  const ref = db.doc(commentPath);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "التعليق غير موجود.");
  if (snap.data()?.status !== "pending_review") {
    throw new HttpsError("failed-precondition", "التعليق ليس قيد المراجعة.");
  }
  await ref.update({
    status: decision === "approve" ? "approved" : "rejected",
    reviewedAt: FieldValue.serverTimestamp()
  });
  await db.collection("moderation_audit").add({
    moderatorUid, contentType: "comment", contentPath: commentPath, decision,
    createdAt: FieldValue.serverTimestamp()
  });
  return { success: true };
});
