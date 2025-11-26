import 'package:asrarpages/medicine_page/medicine_list_page.dart';
import 'package:asrarpages/pages/setting.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../medicine_page/listpage.dart';
import '../theme_controller.dart';
import '../remainder_notepad/notepad_page.dart';
import 'about_page.dart';
import 'contact_us.dart';
import 'profilepage.dart';
import '../remainder_notepad/reminder_page.dart';
import '../farmacia/farmacia_page.dart';
import '../tibbnews/tibbnewspage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 2);
  final PageController _carouselController = PageController();
  int _currentPage = 0;
  int _currentIndex = 2;
  String? userRole;

  final List<String> carouselImages = [
    'assets/image/banner1.png',
    'assets/image/banner2.png',
    'assets/image/banner3.png',
    'assets/image/banner4.jpg',
  ];

  List<Map<String, dynamic>> gridItems = [
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

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _startCarouselAnimation();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role') ?? 'user';
    setState(() {
      userRole = role;
      // 🟩 Add admin-only items dynamically
      if (role == 'admin') {
        gridItems.addAll([
          {'icon': Icons.people_alt, 'name': 'User Info'},
          {'icon': Icons.medical_services, 'name': 'Medicine Upgrade'},
        ]);
      }
    });
  }

  void _startCarouselAnimation() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        int nextPage = (_currentPage + 1) % carouselImages.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeInOut,
        );
        _startCarouselAnimation();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselController.dispose();
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

  // 🔹 Main Home UI
  Widget _buildHomePage(BuildContext context) {
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
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              userRole == 'admin' ? "Hello Admin 😎" : "Hello  broo",
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
          // Carousel
          Container(
            height: 240,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: PageView.builder(
              controller: _carouselController,
              itemCount: carouselImages.length,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(carouselImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(carouselImages.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // 🟩 Grid with admin check
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                final item = gridItems[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
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
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          size: 36,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
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

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.alarm, size: 30),
      const Icon(Icons.note, size: 30),
      const Icon(Icons.home, size: 30),
      const Icon(Icons.article, size: 30),
      const Icon(Icons.store, size: 30),
    ];

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: const [
          ReminderPage(),
          NotepadPage(),
          HomePageInternal(),
          Tibbnewspage(),
          FarmaciaPage(),
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

class HomePageInternal extends StatelessWidget {
  const HomePageInternal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return _HomePageState()._buildHomePage(context);
      },
    );
  }
}
