import 'dart:async';
import 'package:asrarpages/medicine_page/medicine_list_page.dart';
import 'package:asrarpages/pages/setting.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../medicine_page/listpage.dart';
import '../services/supabase_auth_helper.dart';
import '../theme_controller.dart';
import '../remainder_notepad/notepad_page.dart';
import 'about_page.dart';
import 'contact_us.dart';
import 'profilepage.dart';
import '../remainder_notepad/reminder_page.dart';
import '../farmacia/farmacia_page.dart';
import '../tibbnews/tibbnewspage.dart';

/// Main navigation shell managing the five top-level tabs:
/// Reminder, Notepad, Home Dashboard, TibbNews, and Farmacia.
class HomePage extends StatefulWidget {
  final SupabaseAuthService? authService;
  const HomePage({super.key, this.authService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 2);
  int _currentIndex = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.alarm, size: 28),
      const Icon(Icons.note, size: 28),
      const Icon(Icons.home, size: 28),
      const Icon(Icons.article, size: 28),
      const Icon(Icons.store, size: 28),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: [
          const ReminderPage(),
          const NotepadPage(),
          HomePageInternal(authService: widget.authService),
          const Tibbnewspage(),
          const FarmaciaPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.primary,
        buttonBackgroundColor: Colors.transparent,
        height: 60,
        animationDuration: const Duration(milliseconds: 400),
        items: items,
        index: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Standalone Home Dashboard tab widget with an autonomous lifecycle.
/// Eliminates unmounted State direct instantiations and manages its own controllers.
class HomePageInternal extends StatefulWidget {
  final SupabaseAuthService? authService;
  const HomePageInternal({super.key, this.authService});

  @override
  State<HomePageInternal> createState() => _HomePageInternalState();
}

class _HomePageInternalState extends State<HomePageInternal> {
  final PageController _carouselController = PageController();
  int _currentPage = 0;
  String? userRole;
  Timer? _carouselTimer;

  final List<String> carouselImages = [
    'assets/image/banner1.png',
    'assets/image/banner2.png',
    'assets/image/banner3.png',
    'assets/image/banner4.jpg',
  ];

  late final List<Map<String, dynamic>> gridItems;

  @override
  void initState() {
    super.initState();
    gridItems = [
      {'icon': Icons.medication_liquid, 'name': 'Generic'},
      {'icon': Icons.assignment, 'name': 'Indication'},
      {'icon': Icons.business, 'name': 'Brand Name'},
      {'icon': Icons.medication_outlined, 'name': 'Dosage Form'},
      {'icon': Icons.assignment, 'name': 'Manufacturer'},
      {'icon': Icons.business, 'name': 'Drug Class'},
      {'icon': Icons.contact_page, 'name': 'Contact Us'},
      {'icon': Icons.info, 'name': 'About'},
      {'icon': Icons.settings, 'name': 'Settings'},
    ];
    _loadUserRole();
    _startCarouselAnimation();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRole = prefs.getString('user_role') ?? 'patient';

    // Verify admin claims against authoritative server truth
    if (cachedRole == 'admin') {
      final authService = widget.authService ?? SupabaseAuthService();
      final isAdmin = await authService.verifyAdminPrivileges();
      if (!isAdmin) {
        await prefs.setString('user_role', 'patient');
        if (mounted) setState(() => userRole = 'patient');
        return;
      }
    }

    if (mounted) {
      setState(() {
        userRole = cachedRole;
        if (cachedRole == 'admin') {
          gridItems.addAll([
            {'icon': Icons.people_alt, 'name': 'User Info'},
            {'icon': Icons.medical_services, 'name': 'Medicine Upgrade'},
          ]);
        }
      });
    }
  }

  void _startCarouselAnimation() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_carouselController.hasClients) return;
      final nextPage = (_currentPage + 1) % carouselImages.length;
      _carouselController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assalamu Alaikum",
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            Text(
              userRole == 'admin' ? "Administrator" : "Welcome to Asrar-e-Tibb",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
            ),
            onSelected: (value) {
              if (value == 'theme') {
                themeController.toggleTheme(!isDark);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(
                      isDark ? Icons.wb_sunny : Icons.nights_stay,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 10),
                    Text(isDark ? 'Light Mode' : 'Dark Mode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Banner Carousel
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).cardColor,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _carouselController,
                itemCount: carouselImages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(carouselImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Carousel Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(carouselImages.length, (index) {
              final isCurrent = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 20 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isCurrent
                      ? AppColors.brandGreen
                      : (isDark ? Colors.white24 : AppColors.softSage),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Categories Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                final item = gridItems[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    final itemName = item['name'];
                    if (itemName == 'Generic' ||
                        itemName == 'Indication' ||
                        itemName == 'Manufacturer' ||
                        itemName == 'Drug Class' ||
                        itemName == 'Dosage Form') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ListPage(category: itemName),
                        ),
                      );
                    } else if (itemName == 'Brand Name') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MedicineListPage()),
                      );
                    } else if (itemName == 'Contact Us') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContactUsPage()),
                      );
                    } else if (itemName == 'About') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutPage()),
                      );
                    } else if (itemName == 'Settings') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsPage()),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderSubtle.withValues(alpha: 0.1)
                            : AppColors.borderSubtle,
                        width: 1,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.softSage.withValues(alpha: 0.1)
                                : AppColors.softSage.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'],
                            size: 26,
                            color: isDark
                                ? AppColors.brandFresh
                                : AppColors.brandForest,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
