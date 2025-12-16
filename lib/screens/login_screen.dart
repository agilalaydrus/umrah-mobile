import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart'; 
import 'forgot_password_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Call API
    String? error = await _authService.login(
      _phoneCtrl.text, 
      _passCtrl.text
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green)
      );
      // Navigate to Dashboard here later
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red)
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Umrah Connect")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mosque, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Phone Number", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone)
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(
                labelText: "Password", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
            ),
            const SizedBox(height: 25),
            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
      child: const Text("Register")
    ),
    const Text("|"),
    TextButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
      child: const Text("Forgot Password?")
    ),
  ],
),
          ],
        ),
      ),
    );
  }
}
