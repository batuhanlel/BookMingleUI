import 'package:book_mingle_ui/screens/main/chat_screen.dart';
import 'package:book_mingle_ui/screens/main/home_screen.dart';
import 'package:book_mingle_ui/screens/main/profile_screen.dart';
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
      body: _destinations.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "",
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
