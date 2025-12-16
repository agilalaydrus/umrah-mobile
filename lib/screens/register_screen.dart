import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  String _selectedRole = 'JAMAAH'; // Default Role
  bool _isLoading = false;

  void _handleRegister() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Call the Service
    String? error = await _authService.register(
      _nameCtrl.text,
      _phoneCtrl.text,
      _passCtrl.text,
      _selectedRole
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created! Please Login."), backgroundColor: Colors.green)
      );
      Navigator.pop(context); // Go back to Login Screen
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Account")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 10),
              
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'JAMAAH', child: Text("Jamaah")),
                  DropdownMenuItem(value: 'MUTAWWIF', child: Text("Mutawwif (Guide)")),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleRegister,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      child: const Text("REGISTER NOW"),
                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }
}