// lib/screens/register_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Registration screen for new farmers.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _usernameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _locationCtrl     = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _password2Ctrl    = TextEditingController();
  bool _isLoading         = false;
  bool _showPassword      = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await AuthService.register(
      username:    _usernameCtrl.text.trim(),
      email:       _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      location:    _locationCtrl.text.trim(),
      password:    _passwordCtrl.text,
      password2:   _password2Ctrl.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _errorMessage = result['error'].toString());
    }
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {bool isPassword = false,
      TextInputType keyboardType = TextInputType.text,
      String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2C3E50))),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: isPassword && !_showPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword))
                : null,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return '$label is required';
            if (label == 'Confirm Password' && v != _passwordCtrl.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF1A5276),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFADBD8),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Color(0xFF922B21))),
                ),
                const SizedBox(height: 16),
              ],

              _buildField('Username', _usernameCtrl, hint: 'e.g. john_farmer'),
              _buildField('Email', _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'your@email.com'),
              _buildField('Phone Number', _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hint: '0712345678'),
              _buildField('Location', _locationCtrl,
                  hint: 'e.g. Morogoro, Arusha'),
              _buildField('Password', _passwordCtrl, isPassword: true),
              _buildField('Confirm Password', _password2Ctrl,
                  isPassword: true),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E8449),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}