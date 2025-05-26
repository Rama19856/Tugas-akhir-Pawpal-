import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

import 'package:pawpal/auth/forgotpassword_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorEmail = null;
  String? _errorPassword = null;
  bool _isPasswordVisible = false;
  bool _isAgreedToTerms = false;

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() {
      _errorEmail = null;
      _errorPassword = null;
    });

    if (!_isAgreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap setujui syarat & ketentuan untuk melanjutkan.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        // Simpan nama pengguna dari respon server jika ada
        // Asumsi server mengembalikan 'name' atau 'userName' saat login berhasil
        final prefs = await SharedPreferences.getInstance();
        final userName = responseData['name'] ?? responseData['userName'] ?? 'Pengguna'; // Sesuaikan dengan key dari server Anda
        await prefs.setString('name', userName);
        print("[LoginScreen] Login successful. User name saved: $userName");

        // Anda juga bisa menyimpan token atau status login lainnya jika diperlukan
        // await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacementNamed(context, '/homepage'); // Gunakan pushReplacementNamed agar tidak bisa back ke login
      } else {
        setState(() {
          _errorEmail = responseData['message']; // Atau sesuaikan dengan error dari server
        });
        print("[LoginScreen] Login failed: ${responseData['message']}");
      }
    } catch (e) {
      setState(() {
        _errorEmail = 'Terjadi kesalahan. Pastikan server berjalan dan koneksi internet stabil.';
      });
      print("[LoginScreen] Error during login request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png'),
            SizedBox(height: 20),
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Please log in to resume access to your account.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 50),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _errorEmail,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _errorPassword,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isAgreedToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _isAgreedToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Saya menerima syarat & ketentuan yang berlaku di aplikasi',
                    style: TextStyle(
                      color: _isAgreedToTerms ? Colors.black : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAgreedToTerms ? _login : null,
              child: Text('Sign In', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Sign Up'); 
              },
              child: Text('Don\'t have an account? Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}