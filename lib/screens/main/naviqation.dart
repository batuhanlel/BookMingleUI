import 'package:book_mingle_ui/screens/main/navigation_screens/chat_screen.dart';
import 'package:book_mingle_ui/screens/main/navigation_screens/home_screen.dart';
import 'package:book_mingle_ui/screens/main/navigation_screens/profile_screen.dart';
import 'package:flutter/material.dart';

class Naviqation extends StatefulWidget {
  const Naviqation({Key? key}) : super(key: key);

  @override
  State<Naviqation> createState() => _NaviqationState();
}

class _NaviqationState extends State<Naviqation> {
  int _selectedIndex = 1;
  static final List<Widget> _destinations = <Widget>[
    const ChatScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _destinations,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "",
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home),
            label: "",
            icon: Icon(Icons.home_outlined)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "",
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
