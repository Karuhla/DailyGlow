import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inner_shadow_container/inner_shadow_container.dart';

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String selectedSet = 'set1';

  final Map<String, String> moodSetNames = {
    'set1': 'Day Cycle',
    'set2': 'Beach Vacation',
    'set3': 'Fruit Picnic',
    'set4': 'Time for a Treat',
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedSet();
  }

  void _loadSelectedSet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedSet = prefs.getString('iconSet') ?? 'set1';
    });
  }

  void _saveSelectedSet(String set) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('iconSet', set);
    setState(() {
      selectedSet = set;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected ${moodSetNames[set] ?? set}!')),
    );
  }

  Widget _buildSetPreview(String setName) {
    final bool isSelected = selectedSet == setName;
    final String displayName = moodSetNames[setName] ?? setName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 123, 193, 255),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final moodValue = index + 1;
              return Container(
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
                  'assets/$setName/mood$moodValue.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.center,
            child: isSelected
                ? InnerShadowContainer(
                    height: 40,
                    width: 100,
                    backgroundColor: const Color(0xFFE9EDF0),
                    borderRadius: 12,
                    blur: 3,
                    offset: const Offset(2, 2),
                    shadowColor: Colors.grey,
                    isShadowTopLeft: true,
                    child: InnerShadowContainer(
                      height: 40,
                      width: 100,
                      backgroundColor: Colors.transparent,
                      borderRadius: 12,
                      blur: 3,
                      offset: const Offset(4, 4),
                      shadowColor: Colors.white,
                      isShadowBottomRight: true,
                      child: const Center(
                        child: Text(
                          'Using',
                          style: TextStyle(
                            color: Color.fromARGB(255, 123, 193, 255),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => _saveSelectedSet(setName),
                    child: Container(
                      height: 40,
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      child: const Center(
                        child: Text(
                          'Use',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EDF0),
        elevation: 0,
        centerTitle: true,
        title: Image.asset('assets/logo.png', height: 40),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pick your mood icon theme:",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ...['set1', 'set2', 'set3', 'set4'].map(_buildSetPreview).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
