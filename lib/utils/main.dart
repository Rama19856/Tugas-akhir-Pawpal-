import 'package:flutter/material.dart';
import 'package:pawpal/chat/conversation_screen.dart';
import 'package:pawpal/starting/interface_screen.dart';
import 'package:pawpal/auth/register_screen.dart';
import 'package:pawpal/home/homepage_screen.dart';
import 'package:pawpal/marketplace/marketplace_screen.dart';
import 'package:pawpal/chat/chat_screen.dart';
import 'package:pawpal/profile/account_screen.dart';
import 'package:pawpal/profile/favorite_screen.dart'; // Import FavoriteScreen
import 'package:pawpal/auth/login_screen.dart'; // Pastikan ini diimpor
import 'package:pawpal/auth/forgotpassword_screen.dart'; // Import ForgotPasswordScreen
import 'package:pawpal/starting/info_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet App',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', 
      routes: {
      '/': (context) => InterfaceScreen(),
        '/info': (context) => InfoScreen(),
        '/Sign In': (context) => LoginScreen(),
        '/Sign Up': (context) => RegisterScreen(),
        '/homepage': (context) => HomePageScreen(),
        '/marketplace': (context) => MarketplaceScreen(),
        '/chat': (context) => ChatScreen(),
        '/account': (context) => AccountScreen(favoritePosts: []), // Berikan daftar kosong sebagai nilai default
        '/favorites': (context) => FavoritesScreen(favoritePosts: []), // Tambahkan rute untuk FavoriteScreen
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}