import 'package:flutter/material.dart';
import 'package:pawpal/conversation_screen.dart';
import 'package:pawpal/interface_screen.dart';
import 'package:pawpal/register_screen.dart';
import 'package:pawpal/homepage_screen.dart';
import 'package:pawpal/marketplace_screen.dart';
import 'package:pawpal/chat_screen.dart';
import 'package:pawpal/account_screen.dart';
import 'package:pawpal/favorite_screen.dart'; // Import FavoriteScreen
import 'package:pawpal/login_screen.dart'; // Pastikan ini diimpor
import 'package:pawpal/forgotpassword_screen.dart'; // Import ForgotPasswordScreen
import 'package:pawpal/info_screen.dart';

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