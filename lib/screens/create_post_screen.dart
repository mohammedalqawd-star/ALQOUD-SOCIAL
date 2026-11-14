import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_backend.dart';
import 'auth_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final caption = TextEditingController();
  final picker = ImagePicker();
  XFile? selected;
  bool uploading = false;
  String? error;

  @override
  void dispose() { caption.dispose(); super.dispose(); }

  Future<void> refreshActivation() async {
    setState(() {});
  }

  Future<void> openSignIn() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    if (mounted) await refreshActivation();
  }

  Future<void> chooseMedia() async {
    final file = await picker.pickMedia(imageQuality: 88);
    if (file != null && mounted) setState(() { selected = file; error = null; });
  }

  Future<void> publish() async {
    if (selected == null) { setState(() => error = 'اختر صورة أو فيديو أولاً.'); return; }
    setState(() { uploading = true; error = null; });
    try {
      await AppBackend.uploadPost(file: selected!, caption: caption.text);
      if (!mounted) return;
      setState(() { selected = null; caption.clear(); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال المحتوى للمراجعة.')));
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Bad state: ', ''));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Widget gateCard({required IconData icon, required String title, required String message, required String button, required VoidCallback action}) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(26),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('ALQOUD SOCIAL', style: TextStyle(color: Color(0xFFC9A227), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 24),
        Icon(icon, color: const Color(0xFFC9A227), size: 58),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.7)),
        const SizedBox(height: 22),
        FilledButton(onPressed: action, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9A227), foregroundColor: const Color(0xFF061B15)), child: Text(button)),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return gateCard(
        icon: Icons.lock_outline_rounded,
        title: 'التصفح متاح للجميع',
        message: 'يمكنك مشاهدة المحتوى دون حساب. لإنشاء منشور، أنشئ حساباً أولاً ثم انتظر تفعيل النشر.',
        button: 'تسجيل الدخول أو إنشاء حساب',
        action: openSignIn,
      );
    }

    return FutureBuilder<bool>(
      future: AppBackend.isAccountActive(forceRefresh: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)));
        }
        if (snapshot.hasError) {
          return gateCard(
            icon: Icons.cloud_off_outlined,
            title: 'تعذر التحقق من حالة الحساب',
            message: 'تحقق من اتصال الإنترنت ثم أعد المحاولة.',
            button: 'إعادة التحقق',
            action: refreshActivation,
          );
        }
        if (snapshot.data != true) {
          return gateCard(
            icon: Icons.verified_user_outlined,
            title: 'حسابك بانتظار التفعيل',
            message: 'تم تسجيل دخولك بنجاح، لكن النشر غير متاح حتى توافق الإدارة على تفعيل حسابك. يمكنك متابعة تصفح المنشورات في هذه الأثناء.',
            button: 'تحقق من حالة التفعيل',
            action: refreshActivation,
          );
        }

        final ext = selected?.name.toLowerCase() ?? '';
        final isVideo = ['.mp4','.mov','.webm','.m4v','.3gp'].any(ext.endsWith);
        return ListView(padding: const EdgeInsets.all(20), children: [
          const SizedBox(height: 12),
          const Text('ALQOUD SOCIAL', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC9A227), fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
          const SizedBox(height: 14),
          const Icon(Icons.add_to_photos_rounded, color: Color(0xFFC9A227), size: 48),
          const SizedBox(height: 12),
          const Text('أنشئ محتواك', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('حسابك مفعّل. يمكنك إرسال صورة أو فيديو للمراجعة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 24),
          InkWell(onTap: uploading ? null : chooseMedia, borderRadius: BorderRadius.circular(22),
            child: Container(height: 220, decoration: BoxDecoration(color: const Color(0xFF102820), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFC9A227).withValues(alpha: .45))),
              child: selected == null
                ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, color: Color(0xFFC9A227), size: 48), SizedBox(height: 10), Text('اضغط لاختيار صورة أو فيديو')])
                : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(isVideo ? Icons.video_file_rounded : Icons.image_rounded, color: const Color(0xFFC9A227), size: 52),
                    const SizedBox(height: 12),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(selected!.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    const SizedBox(height: 6), const Text('اضغط لتغيير الملف', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
            )),
          const SizedBox(height: 18),
          TextField(controller: caption, maxLength: 500, maxLines: 4,
            decoration: InputDecoration(hintText: 'اكتب وصفاً للمحتوى...', filled: true, fillColor: const Color(0xFF102820), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none))),
          if (error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(error!, style: const TextStyle(color: Colors.redAccent))),
          FilledButton.icon(onPressed: uploading ? null : publish,
            icon: uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_rounded),
            label: Text(uploading ? 'جارٍ الرفع...' : 'إرسال للمراجعة'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9A227), foregroundColor: const Color(0xFF061B15), padding: const EdgeInsets.symmetric(vertical: 15))),
          const SizedBox(height: 14),
          const Text('لا يظهر المحتوى للعامة إلا بعد اعتماده من فريق المراجعة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6)),
        ]);
      },
    );
  }
}
