import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'google_signin_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryColor.withOpacity(0.8),
                  AppColors.secondaryColor.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // Background circles decoration
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGreen.withOpacity(0.1),
              ),
            ),
          ),

          Positioned(
            bottom: -size.width * 0.4,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lightGreen.withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.1),
                    SizedBox(height: 15),
                    // Header text
                    Text(
                      "Welcome\nBack Rider!",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      "Sign in to continue your delivery journey",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    SizedBox(height: 20),
                    // Delivery image
                    Center(
                      child: Image.asset(
                        'assets/images/fast_delivery.png',
                        height: size.height * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),
                    SizedBox(height: 28),
                    // Google sign in button
                    const GoogleSignInButton(),

                    SizedBox(height: 16),
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
