import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/live_feed_screen.dart';
import 'services/app_backend.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase is not configured: $error');
  }
  runApp(AlQoudSocialApp(firebaseReady: firebaseReady));
}

const Color emerald = Color(0xFF0B3D2E);
const Color deepGreen = Color(0xFF061B15);
const Color gold = Color(0xFFC9A227);
const Color ivory = Color(0xFFF5EFE0);

class AlQoudSocialApp extends StatelessWidget {
  const AlQoudSocialApp({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALQOUD – القعود',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.dark,
          primary: emerald,
          secondary: gold,
          surface: const Color(0xFF102820),
        ),
        fontFamily: 'Roboto',
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: FirebaseGate(firebaseReady: firebaseReady),
      ),
    );
  }
}


class FirebaseGate extends StatelessWidget {
  const FirebaseGate({super.key, required this.firebaseReady});
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    if (!firebaseReady) return const FirebaseSetupScreen();
    return StreamBuilder<User?>(
      stream: AppBackend.authChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: gold)));
        }
        if (snapshot.hasData) return const AppShell();
        return const AuthScreen();
      },
    );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, color: gold, size: 58),
                const SizedBox(height: 18),
                const Text('بقي ربط خدمات التطبيق', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                const Text(
                  'أضف إعدادات Firebase الخاصة بمشروعك أولاً. أنشئ مشروع Firebase، ثم فعّل Authentication بالبريد الإلكتروني وCloud Firestore وStorage، وبعدها نفّذ flutterfire configure.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, height: 1.7),
                ),
                const SizedBox(height: 18),
                const Text('لا ترفع ملفات المفاتيح أو الأسرار إلى مستودع عام.', textAlign: TextAlign.center, style: TextStyle(color: gold, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final pages = const [
    LiveFeedScreen(),
    ExploreScreen(),
    CreatePostScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  final titles = const ['القعود', 'اكتشف', 'إنشاء محتوى', 'التواصل', 'ملفي'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deepGreen,
        titleSpacing: 18,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [gold, Color(0xFFE8D9A0)]),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Center(
                child: Text('ق', style: TextStyle(color: deepGreen, fontSize: 23, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 10),
            Text(titles[index], style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .2)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () => _showNotice(context),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0A211A),
        indicatorColor: gold.withValues(alpha: .18),
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'اكتشف'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'انشر'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'التواصل'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }

  void _showNotice(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF102820),
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active_outlined, color: gold, size: 34),
              SizedBox(height: 12),
              Text('مركز الإشعارات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('ستظهر هنا تنبيهات المتابعة والتعليقات والتحديثات بعد ربط خدمة الإشعارات.'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoPost {
  final String creator;
  final String handle;
  final String caption;
  final String tag;
  final IconData art;
  final List<Color> colors;
  final String likes;
  const DemoPost(this.creator, this.handle, this.caption, this.tag, this.art, this.colors, this.likes);
}

const demoPosts = [
  DemoPost('يوميات مبدع', '@creator_one', 'كل فكرة عظيمة تبدأ بخطوة صغيرة. شارك إبداعك اليوم!', '#إلهام', Icons.landscape_rounded, [Color(0xFF123D32), Color(0xFFB17B35)], '12.8K'),
  DemoPost('عالم المعرفة', '@knowledge', 'معلومة جديدة تضيفها اليوم قد تغيّر طريقة تفكيرك غداً.', '#معلومة', Icons.auto_awesome_rounded, [Color(0xFF18324C), Color(0xFF246D69)], '8.4K'),
  DemoPost('مساحة المرح', '@fun_space', 'ابتسم، فالأفكار الجميلة تحب العقول المرحة.', '#مرح', Icons.celebration_rounded, [Color(0xFF542C50), Color(0xFFB66B42)], '6.1K'),
];

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int postIndex = 0;
  String feedType = 'لك';
  final Set<int> liked = {};
  final Set<int> saved = {};
  final Set<int> followed = {};

  @override
  Widget build(BuildContext context) {
    final post = demoPosts[postIndex];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Row(
            children: [
              _feedTab('لك'),
              const SizedBox(width: 18),
              _feedTab('المتابَعون'),
              const Spacer(),
              const Icon(Icons.tune_rounded, color: gold, size: 20),
              const SizedBox(width: 5),
              const Text('تخصيص', style: TextStyle(fontSize: 12, color: ivory)),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < 0) {
                setState(() => postIndex = (postIndex + 1) % demoPosts.length);
              } else if ((details.primaryVelocity ?? 0) > 0) {
                setState(() => postIndex = (postIndex - 1 + demoPosts.length) % demoPosts.length);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: post.colors,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 80,
                    left: -25,
                    child: Icon(post.art, size: 270, color: Colors.white.withValues(alpha: .10)),
                  ),
                  Positioned(
                    top: 28,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .22), borderRadius: BorderRadius.circular(30)),
                      child: const Text('معاينة تجريبية', style: TextStyle(fontSize: 11, color: ivory)),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(post.art, size: 76, color: ivory.withValues(alpha: .92)),
                        const SizedBox(height: 16),
                        Text(post.tag, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: ivory)),
                        const SizedBox(height: 8),
                        const Text('مساحة للإبداع والمشاركة', style: TextStyle(color: ivory, fontSize: 13)),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 24,
                    child: Column(
                      children: [
                        _actionButton(Icons.favorite, liked.contains(postIndex) ? Colors.redAccent : Colors.white, liked.contains(postIndex) ? 'أعجبك' : post.likes, () {
                          setState(() => liked.contains(postIndex) ? liked.remove(postIndex) : liked.add(postIndex));
                        }),
                        const SizedBox(height: 18),
                        _actionButton(Icons.mode_comment_outlined, Colors.white, 'تعليق', _comments),
                        const SizedBox(height: 18),
                        _actionButton(Icons.bookmark, saved.contains(postIndex) ? gold : Colors.white, 'حفظ', () {
                          setState(() => saved.contains(postIndex) ? saved.remove(postIndex) : saved.add(postIndex));
                        }),
                        const SizedBox(height: 18),
                        _actionButton(Icons.share_outlined, Colors.white, 'مشاركة', () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ميزة المشاركة ستُربط عند تجهيز روابط المنشورات.')));
                        }),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 18,
                    left: 88,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(backgroundColor: gold, child: Text(post.creator.substring(0, 1), style: const TextStyle(color: deepGreen, fontWeight: FontWeight.bold))),
                            const SizedBox(width: 9),
                            Expanded(child: Text(post.creator + '  ' + post.handle, style: const TextStyle(fontWeight: FontWeight.bold, color: ivory))),
                            OutlinedButton(
                              onPressed: () => setState(() => followed.contains(postIndex) ? followed.remove(postIndex) : followed.add(postIndex)),
                              style: OutlinedButton.styleFrom(foregroundColor: ivory, side: const BorderSide(color: gold)),
                              child: Text(followed.contains(postIndex) ? 'تتابعه' : 'متابعة'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(post.caption, style: const TextStyle(color: ivory, height: 1.5, fontSize: 14)),
                        const SizedBox(height: 9),
                        const Row(children: [Icon(Icons.music_note, color: gold, size: 16), SizedBox(width: 5), Text('الصوت الأصلي · ALQOUD', style: TextStyle(color: ivory, fontSize: 11))]),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () => setState(() => postIndex = (postIndex + 1) % demoPosts.length),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _feedTab(String value) {
    final selected = feedType == value;
    return GestureDetector(
      onTap: () => setState(() => feedType = value),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: selected ? ivory : Colors.white54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          if (selected) Container(width: 22, height: 3, decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(5))),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, String label, VoidCallback action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _comments() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF102820),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SizedBox(
          height: 360,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text('التعليقات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const Expanded(child: Center(child: Text('لا توجد تعليقات بعد في هذه المعاينة.'))),
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقاً محترماً...',
                    suffixIcon: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.send_rounded, color: gold)),
                    filled: true,
                    fillColor: deepGreen,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final controller = TextEditingController();
  final topics = const ['تعليم', 'تقنية', 'كوميديا', 'رياضة', 'طبخ', 'سفر', 'تصوير', 'ثقافة', 'ألعاب', 'مواهب', 'قصص', 'فن'];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = topics.where((e) => e.contains(controller.text.trim())).toList();
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'ابحث عن موضوع أو صانع محتوى',
            prefixIcon: const Icon(Icons.search, color: gold),
            filled: true,
            fillColor: const Color(0xFF102820),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        const Text('استكشف حسب اهتماماتك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.3, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [emerald, Color.lerp(emerald, gold, (i % 4 + 1) / 8)!]),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Center(child: Text('#' + filtered[i], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ivory))),
          ),
        ),
        const SizedBox(height: 24),
        const Text('اقتراحات لك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const _InfoTile(icon: Icons.auto_awesome, title: 'محتوى ملهم', subtitle: 'أفكار ومهارات وتجارب مفيدة'),
        const _InfoTile(icon: Icons.school_outlined, title: 'تعلم شيئاً جديداً', subtitle: 'معارف قصيرة ومبسطة'),
        const _InfoTile(icon: Icons.palette_outlined, title: 'أبرز المواهب', subtitle: 'اكتشف إبداعات المجتمع'),
      ],
    );
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Text('التواصل الآمن', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Text('سيتم تفعيل التواصل بعد إعداد الحسابات والخصوصية وأدوات الحماية.', style: TextStyle(color: Colors.white60, height: 1.5)),
        SizedBox(height: 18),
        _InfoTile(icon: Icons.lock_outline, title: 'الخصوصية أولاً', subtitle: 'إعدادات من يستطيع التواصل معك'),
        _InfoTile(icon: Icons.shield_outlined, title: 'الحظر والإبلاغ', subtitle: 'أدوات واضحة للتحكم في تجربتك'),
        _InfoTile(icon: Icons.verified_user_outlined, title: 'حماية المجتمع', subtitle: 'مراجعة البلاغات ومكافحة الإساءة'),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [emerald, Color(0xFF174C3B)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withValues(alpha: .55)),
          ),
          child: const Column(
            children: [
              CircleAvatar(radius: 38, backgroundColor: gold, child: Icon(Icons.person, size: 42, color: deepGreen)),
              SizedBox(height: 12),
              Text('ضيف القعود', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('@new_member', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(value: '0', label: 'منشورات'),
                  _Stat(value: '0', label: 'متابعون'),
                  _Stat(value: '0', label: 'يتابع'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _InfoTile(icon: Icons.edit_outlined, title: 'تعديل الملف الشخصي', subtitle: 'الاسم والصورة والنبذة'),
        const _InfoTile(icon: Icons.bookmarks_outlined, title: 'المحفوظات', subtitle: 'المنشورات التي حفظتها'),
        const _InfoTile(icon: Icons.insights_outlined, title: 'مركز المبدعين', subtitle: 'إحصاءات وأداء المحتوى'),
        _InfoTile(icon: Icons.settings_outlined, title: 'الإعدادات والخصوصية', subtitle: 'الحساب والأمان والتحكم', onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }),
        const _InfoTile(icon: Icons.help_outline, title: 'المساعدة والدعم', subtitle: 'الأسئلة الشائعة والإبلاغ عن مشكلة'),
        _InfoTile(icon: Icons.logout_rounded, title: 'تسجيل الخروج', subtitle: 'الخروج من حسابك على هذا الجهاز', onTap: () async {
          await AppBackend.signOut();
        }),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool privateMode = true;
  bool safeComments = true;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات والخصوصية')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('الخصوصية والأمان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(value: privateMode, activeThumbColor: gold, title: const Text('حساب خاص افتراضياً'), subtitle: const Text('يتطلب قبول طلبات المتابعة'), onChanged: (v) => setState(() => privateMode = v)),
          SwitchListTile(value: safeComments, activeThumbColor: gold, title: const Text('تصفية التعليقات'), subtitle: const Text('إعداد تجريبي لتقليل التعليقات غير اللائقة'), onChanged: (v) => setState(() => safeComments = v)),
          SwitchListTile(value: notifications, activeThumbColor: gold, title: const Text('الإشعارات'), onChanged: (v) => setState(() => notifications = v)),
          const Divider(height: 30),
          const _InfoTile(icon: Icons.block, title: 'الحسابات المحظورة', subtitle: 'إدارة الحسابات التي لا تريد التفاعل معها'),
          const _InfoTile(icon: Icons.flag_outlined, title: 'معايير المجتمع', subtitle: 'المحتوى المسموح وآلية الإبلاغ'),
          const _InfoTile(icon: Icons.download_outlined, title: 'تنزيل بياناتك', subtitle: 'ستتاح بعد ربط الحساب'),
          const SizedBox(height: 12),
          const Text('هذه الإعدادات تعمل داخل المعاينة فقط حتى ربط الحساب والخادم.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _InfoTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF102820),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: gold),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left, color: Colors.white54),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: ivory)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}
