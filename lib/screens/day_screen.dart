import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inner_shadow_container/inner_shadow_container.dart';

class DayScreen extends StatefulWidget {
  final DateTime date;

  const DayScreen({required this.date});

  @override
  _DayScreenState createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final q1Controller = TextEditingController();
  final q2Controller = TextEditingController();
  final q3Controller = TextEditingController();
  final q4Controller = TextEditingController();

  int selectedMood = 0;
  String _iconSet = 'set1';

  @override
  void initState() {
    super.initState();
    _loadSelectedSet();
    _loadEntry();
  }

  void _loadSelectedSet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _iconSet = prefs.getString('iconSet') ?? 'set1';
    });
  }

  void _loadEntry() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docId = DateFormat('yyyy-MM-dd').format(widget.date);
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(docId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        q1Controller.text = data['q1'] ?? '';
        q2Controller.text = data['q2'] ?? '';
        q3Controller.text = data['q3'] ?? '';
        q4Controller.text = data['q4'] ?? '';
        selectedMood = data['mood'] ?? 0;
      });
    }
  }

  void _saveEntry() async {
    if (selectedMood == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a mood before saving!')),
      );
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final docId = DateFormat('yyyy-MM-dd').format(widget.date);

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(docId)
        .set({
      'date': widget.date,
      'q1': q1Controller.text,
      'q2': q2Controller.text,
      'q3': q3Controller.text,
      'q4': q4Controller.text,
      'mood': selectedMood,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMMd().format(widget.date);

    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EDF0),
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 40),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                color: Color(0xFF7BC1FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Pick your mood for the day:",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final moodValue = index + 1;
                final isSelected = selectedMood == moodValue;
                final moodIcon = Image.asset(
                  'assets/$_iconSet/mood$moodValue.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                );

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMood = moodValue;
                    });
                  },
                  child: isSelected
                      ? InnerShadowContainer(
                          height: 50,
                          width: 50,
                          backgroundColor: const Color(0xFFE9EDF0),
                          borderRadius: 10,
                          blur: 3,
                          offset: const Offset(2, 2),
                          shadowColor: Colors.grey,
                          isShadowTopLeft: true,
                          child: InnerShadowContainer(
                            height: 50,
                            width: 50,
                            backgroundColor: Colors.transparent,
                            borderRadius: 10,
                            blur: 3,
                            offset: const Offset(4, 4),
                            shadowColor: Colors.white,
                            isShadowBottomRight: true,
                            child: Center(child: moodIcon),
                          ),
                        )
                      : Container(
                          height: 50,
                          width: 50,
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
                          child: moodIcon,
                        ),
                );
              }),
            ),
            const SizedBox(height: 20),
            _buildQuestion("What is the best thing that happened today?", q1Controller),
            _buildQuestion("Describe your day in 3 words!", q2Controller),
            _buildQuestion("What are you looking forward to tomorrow?", q3Controller),
            _buildQuestion("Final thoughts.", q4Controller),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDF0),
                borderRadius: BorderRadius.circular(20),
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
              child: ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7BC1FF),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF7BC1FF),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EDF0),
            borderRadius: BorderRadius.circular(20),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration.collapsed(
                hintText: "Write here...",
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
