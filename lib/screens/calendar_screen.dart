import 'package:flutter/material.dart';
import 'package:inner_shadow_container/inner_shadow_container.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'day_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, int> _moodMap = {};
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _iconSet = 'set1';

  @override
  void initState() {
    super.initState();
    _loadSelectedSet();
    _loadEntries();
  }

  void _loadSelectedSet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _iconSet = prefs.getString('iconSet') ?? 'set1';
    });
  }

  void _loadEntries() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('entries')
        .get();

    final moodMap = <String, int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateStr = doc.id;
      final mood = data['mood'];
      if (mood != null) {
        moodMap[dateStr] = mood;
      }
    }

    setState(() {
      _moodMap = moodMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EDF0),
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          'assets/logo.png',
          height: 40,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.store),
            color: Color(0xFF7BC1FF),
            onPressed: () {
              Navigator.pushNamed(context, '/store').then((_) {
                _loadSelectedSet();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            color: Color(0xFF7BC1FF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFE9EDF0),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
          },
          availableGestures: AvailableGestures.horizontalSwipe,

          headerStyle: HeaderStyle(
          titleTextStyle: TextStyle(
            color: Color(0xFF7BC1FF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          formatButtonVisible: false,
          titleCentered: true,
        ),

        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF7BC1FF),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: Color(0xFF7BC1FF),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
        ),

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
            final dateStr = DateFormat('yyyy-MM-dd').format(day);
            final mood = _moodMap[dateStr];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mood != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(-2, -2),
                          color: Colors.white,
                        ),
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(2, 2),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/$_iconSet/mood$mood.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  InnerShadowContainer(
                    height: 40,
                    width: 40,
                    backgroundColor: const Color(0xFFE9EDF0),
                    borderRadius: 10,
                    blur: 3,
                    offset: Offset(2, 2),
                    shadowColor: Colors.grey, 
                    isShadowTopLeft: true,
                    child: InnerShadowContainer(
                      height: 40,
                      width: 40,
                      backgroundColor: Colors.transparent,
                      borderRadius: 10,
                      blur: 3,
                      offset: Offset(4, 4),
                      shadowColor: Colors.white,
                      isShadowBottomRight: true,
                    ),
                  ),

                const SizedBox(height: 0.5),
                Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 123, 193, 255),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
          
          todayBuilder: (context, day, focusedDay) {
            final dateStr = DateFormat('yyyy-MM-dd').format(day);
            final mood = _moodMap[dateStr];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mood != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(-2, -2),
                          color: Colors.white,
                        ),
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(2, 2),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/$_iconSet/mood$mood.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  InnerShadowContainer(
                    height: 40,
                    width: 40,
                    backgroundColor: const Color(0xFFE9EDF0),
                    borderRadius: 10,
                    blur: 3,
                    offset: Offset(2, 2),
                    shadowColor: Colors.grey,
                    isShadowTopLeft: true,
                    child: InnerShadowContainer(
                      height: 40,
                      width: 40,
                      backgroundColor: Colors.transparent,
                      borderRadius: 10,
                      blur: 3,
                      offset: Offset(4, 4),
                      shadowColor: Colors.white,
                      isShadowBottomRight: true,
                    ),
                  ),

                const SizedBox(height: 0.5),
                Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 123, 193, 255),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },

          selectedBuilder: (context, day, focusedDay) {
            final dateStr = DateFormat('yyyy-MM-dd').format(day);
            final mood = _moodMap[dateStr];

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (mood != null)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EDF0),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(-2, -2),
                          color: Colors.white,
                        ),
                        BoxShadow(
                          blurRadius: 3.0,
                          offset: Offset(2, 2),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/$_iconSet/mood$mood.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  )
                else
                  InnerShadowContainer(
                    height: 40,
                    width: 40,
                    backgroundColor: const Color(0xFFE9EDF0),
                    borderRadius: 10,
                    blur: 3,
                    offset: Offset(2, 2),
                    shadowColor: Colors.grey,
                    isShadowTopLeft: true,
                    child: InnerShadowContainer(
                      height: 40,
                      width: 40,
                      backgroundColor: Colors.transparent,
                      borderRadius: 10,
                      blur: 3,
                      offset: Offset(4, 4),
                      shadowColor: Colors.white,
                      isShadowBottomRight: true,
                    ),
                  ),

                const SizedBox(height: 0.5),
                Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 123, 193, 255),
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),


          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DayScreen(date: selectedDay),
              ),
            ).then((_) => _loadEntries());
          },
        ), 
      ),
    );
  }
}
