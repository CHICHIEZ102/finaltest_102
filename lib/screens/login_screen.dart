import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  void _msg(String t) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
}
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthController.signIn(_email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      _msg('เข้าสู่ระบบไม่สำเร็จ: ${e.code}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      await AuthController.seedTestAccounts();
      _msg('สร้างบัญชีทดสอบแล้ว (รหัสผ่าน 123456)');
    } catch (e) {
      _msg('สร้างบัญชีไม่สำเร็จ: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoCarbon - Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const Icon(Icons.eco, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'อีเมล', border: OutlineInputBorder()),
                validator: MultiValidator([
                  RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
                  EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
                ]).call,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'รหัสผ่าน', border: OutlineInputBorder()),
                validator: RequiredValidator(errorText: 'กรุณากรอกรหัสผ่าน').call,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('เข้าสู่ระบบ'),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : _seed,
                child: const Text('สร้างบัญชีทดสอบ (admin / operator)'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
