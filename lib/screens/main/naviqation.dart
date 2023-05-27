import 'package:book_mingle_ui/screens/main/navigation_screens/home_screen.dart';
import 'package:book_mingle_ui/screens/main/navigation_screens/profile_screen.dart';
import 'package:flutter/material.dart';

import 'navigation_screens/chat_list_screen.dart';

class Naviqation extends StatefulWidget {
  const Naviqation({Key? key}) : super(key: key);

  @override
  State<Naviqation> createState() => _NaviqationState();
}

class _NaviqationState extends State<Naviqation> {
  int _selectedIndex = 1;
  final _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = <Widget>[
    const ChatListScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
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
            icon: Icon(Icons.home_outlined),
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
