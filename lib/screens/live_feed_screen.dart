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
        if (snapshot.hasError) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('تعذر تحميل المحتوى. تحقق من إعدادات Firebase وقواعد قاعدة البيانات.', textAlign: TextAlign.center)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)));
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.video_library_outlined, color: Color(0xFFC9A227), size: 56), SizedBox(height: 14),
          Text('لا توجد منشورات منشورة بعد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8), Text('عندما تتم مراجعة المحتوى واعتماده سيظهر هنا.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60)),
        ])));
        return PageView.builder(scrollDirection: Axis.vertical, itemCount: docs.length, itemBuilder: (context, index) => _PostPage(data: docs[index].data()));
      },
    );
  }
}

class _PostPage extends StatelessWidget {
  const _PostPage({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final url = data['mediaUrl'] as String? ?? '';
    final type = data['mediaType'] as String? ?? 'image';
    final caption = data['caption'] as String? ?? '';
    return Container(margin: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      decoration: BoxDecoration(color: const Color(0xFF102820), borderRadius: BorderRadius.circular(24)), clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        if (type == 'video') _NetworkVideo(url: url)
        else Image.network(url, fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFFC9A227), size: 52)),
          loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)))),
        Positioned(left: 16, right: 16, bottom: 22, child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: .52), borderRadius: BorderRadius.circular(16)),
          child: Padding(padding: const EdgeInsets.all(14), child: Text(caption.isEmpty ? 'محتوى من مجتمع القعود' : caption, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5))),
        )),
      ]),
    );
  }
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
    } catch (_) { if (mounted) setState(() => error = 'تعذر تشغيل هذا الفيديو.'); }
  }

  @override
  void dispose() { controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (error != null) return Center(child: Text(error!));
    if (c == null || !c.value.isInitialized) return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A227)));
    return GestureDetector(onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()),
      child: Stack(alignment: Alignment.center, children: [
        Center(child: AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c))),
        if (!c.value.isPlaying) Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), padding: const EdgeInsets.all(14), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42)),
        Positioned(left: 12, right: 12, bottom: 88, child: VideoProgressIndicator(c, allowScrubbing: true, colors: const VideoProgressColors(playedColor: Color(0xFFC9A227)))),
      ]),
    );
  }
}
