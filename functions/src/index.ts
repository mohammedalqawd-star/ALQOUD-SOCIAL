import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

initializeApp();
const db = getFirestore();

function requireModerator(request: {
  auth?: { uid: string; token: Record<string, unknown> } | null;
}): string {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول.");
  }
  if (request.auth.token.admin !== true && request.auth.token.moderator !== true) {
    throw new HttpsError("permission-denied", "هذه العملية مخصصة لفريق المراجعة.");
  }
  return request.auth.uid;
}

export const reviewPost = onCall({ region: "us-central1" }, async (request) => {
  const moderatorUid = requireModerator(request);
  const postId = request.data?.postId;
  const decision = request.data?.decision;

  if (typeof postId !== "string" || postId.length === 0 ||
      !["approve", "reject"].includes(decision)) {
    throw new HttpsError("invalid-argument", "بيانات مراجعة المنشور غير صحيحة.");
  }

  const ref = db.collection("posts").doc(postId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "المنشور غير موجود.");
  if (snap.data()?.status !== "pending_review") {
    throw new HttpsError("failed-precondition", "المنشور ليس قيد المراجعة.");
  }

  await ref.update({
    status: decision === "approve" ? "published" : "rejected",
    reviewedAt: FieldValue.serverTimestamp(),
    reviewedBy: moderatorUid
  });
  await db.collection("moderation_audit").add({
    moderatorUid,
    contentType: "post",
    contentId: postId,
    decision,
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
    reviewedAt: FieldValue.serverTimestamp(),
    reviewedBy: moderatorUid
  });
  await db.collection("moderation_audit").add({
    moderatorUid,
    contentType: "comment",
    contentPath: commentPath,
    decision,
    createdAt: FieldValue.serverTimestamp()
  });
  return { success: true };
});
