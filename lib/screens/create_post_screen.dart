import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/app_backend.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع المحتوى وإرساله للمراجعة قبل النشر.')));
    } catch (e) {
      setState(() => error = 'تعذر رفع المحتوى: ' + e.toString());
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = selected?.name.toLowerCase() ?? '';
    final isVideo = ['.mp4','.mov','.webm','.m4v','.3gp'].any(ext.endsWith);
    return ListView(padding: const EdgeInsets.all(20), children: [
      const SizedBox(height: 12),
      const Icon(Icons.add_to_photos_rounded, color: Color(0xFFC9A227), size: 58),
      const SizedBox(height: 14),
      const Text('أنشئ محتواك', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('شارك صورة أو فيديو من جهازك.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
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
        label: Text(uploading ? 'جارٍ الرفع...' : 'رفع وإرسال للمراجعة'),
        style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9A227), foregroundColor: const Color(0xFF061B15), padding: const EdgeInsets.symmetric(vertical: 15))),
      const SizedBox(height: 14),
      const Text('لن يظهر المنشور للعامة مباشرة؛ يُحفظ بحالة قيد المراجعة حتى تُجهّز خدمة مراجعة المحتوى ولوحة الإدارة.',
        textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6)),
    ]);
  }
}
