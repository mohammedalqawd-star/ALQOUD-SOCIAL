import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlQoudSocialApp());
}

class AlQoudSocialApp extends StatelessWidget {
  const AlQoudSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF0B3D2E);
    const gold = Color(0xFFC9A227);
    const background = Color(0xFF071B15);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALQOUD – القعود',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.dark,
          primary: emerald,
          secondary: gold,
          surface: const Color(0xFF102820),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _pages = <Widget>[
    FeedPage(),
    ExplorePage(),
    CreatePage(),
    MessagesPage(),
    ProfilePage(),
  ];

  static const _titles = <String>[
    'القعود',
    'استكشف',
    'إنشاء',
    'الرسائل',
    'حسابي',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_selectedIndex],
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.play_circle_outline_rounded),
              selectedIcon: Icon(Icons.play_circle_fill_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'استكشف',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded),
              selectedIcon: Icon(Icons.add_circle_rounded),
              label: 'إضافة',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'الرسائل',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.smart_display_rounded,
      title: 'عالم القعود يبدأ هنا',
      description:
          'ستظهر هنا مقاطع الفيديو والمنشورات بعد تجهيز نظام الحسابات ورفع المحتوى.',
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.travel_explore_rounded,
      title: 'اكتشف محتوى جديداً',
      description: 'سيضم هذا القسم البحث والوسوم والمحتوى الرائج.',
    );
  }
}

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.add_a_photo_outlined,
      title: 'أنشئ محتواك',
      description: 'سيتم هنا تجهيز اختيار الفيديو ومعاينته ورفعه.',
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.forum_outlined,
      title: 'مساحة التواصل',
      description: 'سيتم بناء الرسائل والخصوصية وإعدادات الأمان في مرحلة مستقلة.',
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.account_circle_outlined,
      title: 'ملفك الشخصي',
      description: 'سيظهر هنا الملف الشخصي والمنشورات والمتابعون والإعدادات.',
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF0B3D2E),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFC9A227), width: 1.2),
              ),
              child: Icon(icon, size: 42, color: const Color(0xFFE8D9A0)),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                height: 1.7,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
