import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorName = null;
  String? _errorEmail = null;
  String? _errorPassword = null;
  bool _obscurePassword = true;
  bool _isAgreedToTerms = false;

  Future<void> _register() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() {
      _errorName = null;
      _errorEmail = null;
      _errorPassword = null;
    });

    bool hasError = false;
    if (name.isEmpty) {
      setState(() { _errorName = 'Input Your Name'; });
      hasError = true;
    }
    if (email.isEmpty) {
      setState(() { _errorEmail = 'Input Your Email'; });
      hasError = true;
    }
    if (password.isEmpty || password.length < 6) {
      setState(() { _errorPassword = 'Password must be at least 6 characters.'; });
      hasError = true;
    }
    if (!_isAgreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap setujui syarat & ketentuan terlebih dahulu.')),
      );
      hasError = true;
    }

    if (hasError) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        // Simpan nama pengguna ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);
        print("[RegisterScreen] Registration successful. User name saved: $name");

        Navigator.pushReplacementNamed(context, '/Sign In'); // Redirect ke halaman login
      } else {
        setState(() {
          _errorEmail = responseData['message']; // Pesan error dari server, misal 'Email already registered'
        });
        print("[RegisterScreen] Registration failed: ${responseData['message']}");
      }
    } catch (e) {
      setState(() {
        _errorEmail = 'Terjadi kesalahan. Pastikan server berjalan dan koneksi internet stabil.';
      });
      print("[RegisterScreen] Error during registration request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png'),
            SizedBox(height: 20),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Register now and enjoy the best experience',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _errorName,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
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
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _errorPassword,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
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
              onPressed: _isAgreedToTerms ? _register : null,
              child: Text('Sign Up', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/Sign In'); 
              },
              child: Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}