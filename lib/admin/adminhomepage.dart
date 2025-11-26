import 'package:asrarpages/admin/adminprofile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '../theme_controller.dart';
import '../remainder_notepad/notepad_page.dart';
import '../remainder_notepad/reminder_page.dart';
import '../tibbnews/tibbnewspage.dart';
import '../farmacia/farmacia_page.dart';
import '../medicine_page/listpage.dart';
import '../medicine_page/medicine_list_page.dart';
import '../admin/admin_panel_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final PageController _pageController = PageController(initialPage: 2);
  final PageController _carouselController = PageController();
  int _currentPage = 0;
  int _currentIndex = 2;

  final List<String> carouselImages = [
    'assets/image/banner1.png',
    'assets/image/banner2.png',
    'assets/image/banner3.png',
    'assets/image/banner4.jpg',
  ];

  // 🟩 Admin grid items (same UI + extra 2 options)
  final List<Map<String, dynamic>> gridItems = [
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
    _startCarouselAnimation();
  }

  void _startCarouselAnimation() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        int nextPage = (_currentPage + 1) % carouselImages.length;
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
        _startCarouselAnimation();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back", style: TextStyle(fontSize: 14)),
            Text(
              "Hello Admin 😎",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'theme') {
                themeController.toggleTheme(!isDark);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminProfilePage()),
                );
              } else if (value == 'admin_panel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminPanelPage()),
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
              const PopupMenuItem(
                value: 'admin_panel',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings),
                    SizedBox(width: 10),
                    Text('Admin Panel'),
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
                        const SizedBox(height: 2),
                        Text(
                          item['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 70),
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
        children: [
          const ReminderPage(),
          const NotepadPage(),
          _buildHomePage(context),
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
