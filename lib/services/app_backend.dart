import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AppBackend {
  AppBackend._();
  static final auth = FirebaseAuth.instance;
  static final db = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;
  static Stream<User?> authChanges() => auth.authStateChanges();

  static Future<void> register({required String displayName, required String email, required String password}) async {
    final credential = await auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await credential.user!.updateDisplayName(displayName.trim());
    await db.collection('users').doc(credential.user!.uid).set({
      'displayName': displayName.trim(), 'photoUrl': null, 'bio': '',
      'privacy': 'private', 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> signIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  static Future<void> signOut() => auth.signOut();

  static Stream<QuerySnapshot<Map<String, dynamic>>> publishedPosts() => db
      .collection('posts')
      .where('status', isEqualTo: 'published')
      .orderBy('createdAt', descending: true)
      .limit(40)
      .snapshots();

  static Future<void> uploadPost({required XFile file, required String caption}) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول أولاً.');
    final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'bin';
    const videoExtensions = {'mp4', 'mov', 'm4v', 'webm', '3gp'};
    final isVideo = videoExtensions.contains(extension);
    final contentType = _contentType(extension, isVideo);
    final path = 'users/' + user.uid + '/media/' + DateTime.now().microsecondsSinceEpoch.toString() + '.' + extension;
    final ref = storage.ref().child(path);
    final snapshot = await ref.putFile(File(file.path), SettableMetadata(
      contentType: contentType,
      customMetadata: {'ownerUid': user.uid},
    ));
    final mediaUrl = await snapshot.ref.getDownloadURL();
    await db.collection('posts').add({
      'authorId': user.uid, 'caption': caption.trim(), 'mediaUrl': mediaUrl,
      'mediaType': isVideo ? 'video' : 'image',
      'createdAt': FieldValue.serverTimestamp(), 'visibility': 'public',
      'status': 'pending_review',
    });
  }

  static String _contentType(String extension, bool isVideo) {
    const videos = {'mp4':'video/mp4','mov':'video/quicktime','m4v':'video/x-m4v','webm':'video/webm','3gp':'video/3gpp'};
    const images = {'jpg':'image/jpeg','jpeg':'image/jpeg','png':'image/png','webp':'image/webp','gif':'image/gif','heic':'image/heic'};
    return isVideo ? (videos[extension] ?? 'video/mp4') : (images[extension] ?? 'image/jpeg');
  }
}
