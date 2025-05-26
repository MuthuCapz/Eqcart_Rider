import 'package:flutter/material.dart';

import '../../utils/colors.dart';



class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title:
        Text('Main Page', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child:
        Text('Main Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
