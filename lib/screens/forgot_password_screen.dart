import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  int _step = 1; // Controls which UI to show
  bool _isLoading = false;
  String _debugMsg = ""; // To show the OTP on screen

  // ACTION: Request OTP
  void _requestOTP() async {
    setState(() => _isLoading = true);
    try {
      String msg = await _authService.forgotPassword(_phoneCtrl.text);
      setState(() {
        _step = 2; // Move to next step
        _debugMsg = msg; 
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  // ACTION: Submit Reset
  void _submitReset() async {
    setState(() => _isLoading = true);
    String? error = await _authService.resetPassword(_phoneCtrl.text, _otpCtrl.text, _newPassCtrl.text);
    setState(() => _isLoading = false);

    if (error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password Changed! Please Login."), backgroundColor: Colors.green));
      Navigator.pop(context); // Go back to login
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- UI FOR STEP 1 ---
            if (_step == 1) ...[
              const Text("Enter your phone number to receive an OTP."),
              const SizedBox(height: 20),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _requestOTP, 
                child: const Text("SEND OTP")
              )
            ],
            
            // --- UI FOR STEP 2 ---
            if (_step == 2) ...[
              // Yellow box to simulate SMS arrival
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                color: Colors.amber[100],
                child: Text("SMS SIMULATION:\n$_debugMsg", style: const TextStyle(fontWeight: FontWeight.bold)), 
              ),
              const SizedBox(height: 20),
              
              TextField(controller: _otpCtrl, decoration: const InputDecoration(labelText: "Enter OTP Code", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(controller: _newPassCtrl, decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReset, 
                child: const Text("CHANGE PASSWORD")
              )
            ]
          ],
        ),
      ),
    );
  }
}