import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/app_backend.dart';

class LiveFeedScreen extends StatelessWidget {
  const LiveFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AppBackend.publishedPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Padding(padding: EdgeInsets.all(24),
            child: Text('تعذر تحميل المحتوى. تحقق من إعدادات Firebase وقواعد قاعدة البيانات.', textAlign: TextAlign.center)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.video_library_outlined, color: Color(0xFFC9A227), size: 56),
              SizedBox(height: 14),
              Text('لا توجد منشورات منشورة بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('بعد مراجعة المنشورات واعتمادها ستظهر هنا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
            ])));
        }
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: docs.length,
          itemBuilder: (context, index) => _PostPage(postId: docs[index].id, data: docs[index].data()),
        );
      },
    );
  }
}

class _PostPage extends StatelessWidget {
  const _PostPage({required this.postId, required this.data});
  final String postId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final url = data['mediaUrl'] as String? ?? '';
    final type = data['mediaType'] as String? ?? 'image';
    final caption = data['caption'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      decoration: BoxDecoration(color: const Color(0xFF102820), borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        if (type == 'video') _NetworkVideo(url: url)
        else Image.network(url, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFFC9A227), size: 52)),
          loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)))),
        Positioned(
          left: 12, bottom: 22,
          child: Column(children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: AppBackend.likesFor(postId),
              builder: (context, snap) {
                final uid = AppBackend.auth.currentUser?.uid;
                final docs = snap.data?.docs ?? [];
                final isLiked = uid != null && docs.any((d) => d.id == uid);
                return _Action(icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.redAccent : Colors.white,
                  label: docs.length.toString(),
                  onTap: () async {
                    try { await AppBackend.toggleLike(postId); }
                    catch (_) { _toast(context, 'تعذر تسجيل الإعجاب.'); }
                  });
              },
            ),
            const SizedBox(height: 18),
            _Action(icon: Icons.mode_comment_outlined, color: Colors.white, label: 'تعليق',
              onTap: () => _showComments(context, postId)),
            const SizedBox(height: 18),
            _Action(icon: Icons.bookmark_border_rounded, color: Colors.white, label: 'حفظ',
              onTap: () async {
                try {
                  await AppBackend.toggleSaved(postId);
                  _toast(context, 'تم تحديث المحفوظات.');
                } catch (_) { _toast(context, 'تعذر حفظ المنشور.'); }
              }),
            const SizedBox(height: 18),
            _Action(icon: Icons.flag_outlined, color: Colors.white, label: 'إبلاغ',
              onTap: () => _report(context, postId)),
          ]),
        ),
        Positioned(
          right: 16, left: 88, bottom: 22,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: .52), borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(caption.isEmpty ? 'محتوى من مجتمع القعود' : caption,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
            ),
          ),
        ),
      ]),
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _report(BuildContext context, String postId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن المنشور'),
        content: const Text('اختر سبب الإبلاغ ليتم إرساله للمراجعة.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'محتوى غير مناسب'), child: const Text('محتوى غير مناسب')),
          TextButton(onPressed: () => Navigator.pop(context, 'مضايقة أو إساءة'), child: const Text('إساءة أو مضايقة')),
          TextButton(onPressed: () => Navigator.pop(context, 'انتهاك حقوق'), child: const Text('انتهاك حقوق')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        ],
      ),
    );
    if (reason == null) return;
    try {
      await AppBackend.reportPost(postId, reason);
      if (context.mounted) _toast(context, 'تم إرسال البلاغ للمراجعة.');
    } catch (_) {
      if (context.mounted) _toast(context, 'تعذر إرسال البلاغ.');
    }
  }

  static void _showComments(BuildContext context, String postId) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF102820),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(height: 430, child: Column(children: [
          const SizedBox(height: 16),
          const Text('التعليقات المعتمدة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: AppBackend.approvedComments(postId),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text('تعذر تحميل التعليقات.'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final comments = snapshot.data!.docs;
              if (comments.isEmpty) return const Center(child: Text('لا توجد تعليقات معتمدة بعد.'));
              return ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final item = comments[index].data();
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                    title: Text(item['text'] as String? ?? ''),
                    subtitle: const Text('عضو في القعود'),
                  );
                },
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: TextField(controller: controller, maxLength: 500,
                decoration: const InputDecoration(hintText: 'اكتب تعليقاً محترماً...', counterText: ''))),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFFC9A227)),
                onPressed: () async {
                  try {
                    await AppBackend.addComment(postId, controller.text);
                    controller.clear();
                    if (sheetContext.mounted) _toast(sheetContext, 'أُرسل التعليق للمراجعة.');
                  } catch (_) {
                    if (sheetContext.mounted) _toast(sheetContext, 'تعذر إرسال التعليق.');
                  }
                },
              ),
            ]),
          ),
        ])),
      ),
    ).whenComplete(controller.dispose);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.color, required this.label, required this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: Column(children: [
      Icon(icon, color: color, size: 29),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _NetworkVideo extends StatefulWidget {
  const _NetworkVideo({required this.url});
  final String url;
  @override
  State<_NetworkVideo> createState() => _NetworkVideoState();
}

class _NetworkVideoState extends State<_NetworkVideo> {
  VideoPlayerController? controller;
  String? error;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      controller = c;
      await c.initialize();
      await c.setLooping(true);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر تشغيل هذا الفيديو.');
    }
  }

  @override
  void dispose() { controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (error != null) return Center(child: Text(error!));
    if (c == null || !c.value.isInitialized) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)));
    return GestureDetector(
      onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
      child: Stack(alignment: Alignment.center, children: [
        Center(child: AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c))),
        if (!c.value.isPlaying)
          Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
            padding: const EdgeInsets.all(14), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42)),
        Positioned(left: 12, right: 12, bottom: 88,
          child: VideoProgressIndicator(c, allowScrubbing: true,
            colors: const VideoProgressColors(playedColor: Color(0xFFC9A227)))),
      ]),
    );
  }
}
