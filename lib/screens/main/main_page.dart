import 'package:flutter/material.dart';
import '../../custom_bottom_navbar.dart';
import '../../utils/colors.dart';
import 'home_page/home_page.dart';
import 'more_page/more_page.dart';
// Add this import

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeOrdersPage(),
    Center(child: Text('Earnings Page', style: TextStyle(color: Colors.white))),
    Center(
      child: Text('My Shifts Page', style: TextStyle(color: Colors.white)),
    ),
    Center(
      child: Text('Notifications Page', style: TextStyle(color: Colors.white)),
    ),
    const MorePage(), // ← Replace 'More' placeholder with actual MorePage
  ];

  final List<String> _titles = [
    "Home",
    "Earnings",
    "My Shifts",
    "Notifications",
    "More",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          title: Text(
            _titles[_selectedIndex],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.secondaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          leading:
              _selectedIndex == 0
                  ? null
                  : IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
