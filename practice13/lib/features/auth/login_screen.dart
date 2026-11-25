import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_model.dart';
import 'wrong_password_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final email = (v ?? '').trim();
    final at = email.indexOf('@');
    final hasDotAfterAt = at >= 0 && email.indexOf('.', at) > at;
    return hasDotAfterAt ? null : 'Email looks wrong';
  }

  String? _validatePassword(String? v) =>
      (v ?? '').length < 8 ? 'At least 8 characters' : null;

  Future<void> _login() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthModel>().login(_email.text.trim(), _password.text);
      // signedIn flips, App shows the users list, nothing to do here
    } on WrongPasswordException {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Wrong password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: _validatePassword,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _login,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
