import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sevices/supabase_services.dart';
import 'create_schedule_page.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  String? _userId;
  String? _userName = "Loading...";
  String? _avatar;

  Stream<List<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    final u = Supabase.instance.client.auth.currentUser;
    _userId = u?.id;

    if (_userId != null) {
      await _loadProfile();
      _stream = SupabaseService.schedulesStream(_userId!);
      setState(() {});
    }
  }

  Future<void> _loadProfile() async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select('name, avatar_url')
        .eq('id', _userId!)
        .maybeSingle();

    setState(() {
      _userName = res?['name'] ?? "User";
      _avatar = res?['avatar_url'];
    });
  }

  Future<void> _onAddSchedule() async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateSchedulePage()),
    );

    if (res != null && _userId != null) {
      await SupabaseService.createSchedule(
        userId: _userId!,
        title: res['name'] ?? '',
        dose: res['dose'] ?? '',
        timeOfDay: res['time'] ?? '',
      );
    }
  }

  Future<void> _delete(String id) async {
    if (_userId == null) return;
    await SupabaseService.deleteSchedule(id, _userId!);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF0C4B63);

    final bg = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bg,

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          backgroundColor: primary,
          onPressed: _onAddSchedule,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(primary, isDark),
            _buildCalendar(primary, isDark),
            const SizedBox(height: 5),
            _buildSchedules(primary),
          ],
        ),
      ),
    );
  }

  /// 🔵 HEADER WITH CURVE + USERNAME + AVATAR
  Widget _buildHeader(Color primary, bool isDark) {
    return Stack(
      children: [
        ClipPath(
          clipper: _CurveClipper(),
          child: Container(height: 230, width: double.infinity, color: primary),
        ),

        Positioned(
          left: 18,
          top: 60,
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: _avatar != null
                    ? NetworkImage(_avatar!)
                    : const AssetImage('assets/image/pic.png') as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Stay healthy today 💊",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          right: 20,
          top: 60,
          child: Image.asset(
            'assets/image/heart.png',
            height: 95,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// 📅 HORIZONTAL CALENDAR STRIP
  Widget _buildCalendar(Color primary, bool isDark) {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 15,
        itemBuilder: (_, i) {
          final date = DateTime.now().add(Duration(days: i));
          final bool today =
              date.day == DateTime.now().day &&
              date.month == DateTime.now().month;

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: today
                  ? primary
                  : (isDark ? Colors.grey[850] : Colors.grey[300]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ["S", "M", "T", "W", "T", "F", "S"][date.weekday % 7],
                  style: TextStyle(
                    color: today
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: today
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🟦 SCHEDULE LIST (STREAM)
  Widget _buildSchedules(Color primary) {
    if (_userId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("Login required", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final list = snap.data ?? [];

        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Center(
              child: Text(
                "No schedules yet.\nTap Start to create one.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: list.map((s) {
            final id = s['id'].toString();

            return Dismissible(
              key: Key(id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Icon(Icons.delete, color: Colors.white, size: 32),
              ),
              onDismissed: (_) => _delete(id),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medication_liquid, color: primary, size: 32),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['title'] ?? '',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 132, 163, 182),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              s['dose'] ?? '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      s['time_of_day'] ?? "",
                      style: TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// CURVE SHAPE
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path();
    p.lineTo(0, s.height - 60);
    p.quadraticBezierTo(s.width / 2, s.height, s.width, s.height - 60);
    p.lineTo(s.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
