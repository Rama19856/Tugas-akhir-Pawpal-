import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _codeControllers = List.generate(4, (index) => TextEditingController());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _message = '';
  bool _isCodeSent = false;
  bool _isCodeVerified = false;
  int _resendCooldown = 60;
  late Timer _timer;
  bool _isSendingCode = false;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_resendCooldown == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _resendCooldown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (_isSendingCode) return;

    setState(() {
      _isSendingCode = true;
    });

    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = 'Email cannot be empty.';
        _isSendingCode = false;
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/send-verification-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      setState(() {
        _isCodeSent = true;
        _message = 'Verification code sent to your email.';
        _resendCooldown = 60;
        startTimer();
      });
    } else {
      setState(() {
        _message = responseData['message'];
      });
    }

    setState(() {
      _isSendingCode = false;
    });
  }

  Future<void> _verifyCode() async {
    final email = _emailController.text.trim();
    final code = _codeControllers.map((controller) => controller.text).join();

    if (code.isEmpty) {
      setState(() {
        _message = 'Please enter the verification code.';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      setState(() {
        _isCodeVerified = true;
        _message = 'Code verified successfully. Now create a new password.';
      });
    } else {
      setState(() {
        _message = responseData['message'];
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _message = 'Please fill both password fields.';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _message = 'Password must be at least 6 characters.';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _message = 'New password and confirm password do not match.';
      });
      return;
    }

    final response = await http.post(
      Uri.parse('http://localhost:3000/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordResetSuccessScreen(),
        ),
      );
    } else {
      setState(() {
        _message = responseData['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isCodeSent && !_isCodeVerified) ...[
                Text(
                  'Enter your email to reset your password.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isSendingCode ? null : _sendVerificationCode,
                  child: Text('Send Code'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.red,
                  ),
                ),
              ],

              if (_isCodeSent && !_isCodeVerified) ...[
                Text(
                  'Enter the verification code sent to your email.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _codeControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 3) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text('Verify Code'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _resendCooldown > 0
                      ? 'Resend code in $_resendCooldown seconds'
                      : 'Didn\'t receive the code? Resend',
                  style: TextStyle(
                    color: _resendCooldown > 0 ? Colors.grey : Colors.blue,
                  ),
                ),
                if (_resendCooldown == 0)
                  TextButton(
                    onPressed: _sendVerificationCode,
                    child: Text('Resend Code'),
                  ),
              ],

              if (_isCodeVerified) ...[
                Text(
                  'Create a new password.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetPassword,
                  child: Text('Reset Password'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.red,
                  ),
                ),
              ],

              SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordResetSuccessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Password reset successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/Sign In');
              },
              child: Text('Login Now'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}