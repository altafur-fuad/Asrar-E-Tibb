import 'package:asrarpages/tibbnews/menue_page.dart';
import 'package:asrarpages/tibbnews/news_feed_page.dart';
import 'package:asrarpages/tibbnews/notification_page.dart';
import 'package:asrarpages/tibbnews/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Tibbnewspage extends StatefulWidget {
  const Tibbnewspage({super.key});

  @override
  State<Tibbnewspage> createState() => _MainPageState();
}

class _MainPageState extends State<Tibbnewspage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  final ScrollController _scrollController = ScrollController();
  double tabBarOffset = 0; // 0 = visible, -56 = hidden
  final double barHeight = 56;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        // Scroll Up → TabBar slide up
        if (tabBarOffset == 0) {
          setState(() => tabBarOffset = -barHeight);
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        // Scroll Down → TabBar slide down
        if (tabBarOffset == -barHeight) {
          setState(() => tabBarOffset = 0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable pages
          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, _) {
              return [
                SliverAppBar(
                  title: const Text("Tibb News"),
                  pinned: true,
                  floating: false,
                  snap: false,
                ),
              ];
            },
            body: TabBarView(
              controller: _tab,
              children: [
                NewsFeedPage(),
                ProfilePage(),
                NotificationPage(),
                MenuPage(),
              ],
            ),
          ),

          // Animated sliding TabBar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: kToolbarHeight + tabBarOffset,
            left: 0,
            right: 0,
            child: Container(
              height: barHeight,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Material(
                elevation: 3,
                child: TabBar(
                  controller: _tab,
                  tabs: const [
                    Tab(icon: Icon(Icons.home)),
                    Tab(icon: Icon(Icons.person)),
                    Tab(icon: Icon(Icons.notifications)),
                    Tab(icon: Icon(Icons.menu)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
