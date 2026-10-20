import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

String formatBirth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.'
    '${d.year}';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthText = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthText]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  // ---- validators: each rule lives beside the field it guards ----------

  String? _validateName(String? v) =>
      (v ?? '').trim().length < 2 ? 'At least 2 characters' : null;

  String? _validateEmail(String? v) {
    final email = (v ?? '').trim();
    final at = email.indexOf('@');
    final hasDotAfterAt = at >= 0 && email.indexOf('.', at) > at;
    return hasDotAfterAt ? null : 'Email looks wrong';
  }

  String? _validatePassword(String? v) =>
      (v ?? '').length < 8 ? 'At least 8 characters' : null;

  String? _validateConfirm(String? v) =>
      v != _password.text ? 'Passwords do not match' : null;

  String? _validateGroup(String? g) => g == null ? 'Choose a group' : null;

  String? _validateBirth(String? _) =>
      _birth == null ? 'Pick your date of birth' : null;

  // ---- actions ------------------------------------------------------------

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked == null) return; // Cancel keeps the old date
    if (!mounted) return;
    setState(() => _birth = picked);
    _birthText.text = formatBirth(picked);
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
  }

  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthText]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  static void _foldKeyboard(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  // ---- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _done ? _summary() : _form(),
    ),
  );

  Widget _summary() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SummaryCard(
        name: _name.text.trim(),
        email: _email.text.trim(),
        group: _group ?? '',
        birthDate: switch (_birth) {
          final b? => formatBirth(b),
          null => '',
        },
      ),
      const SizedBox(height: 16),
      TextButton(onPressed: _startOver, child: const Text('Start over')),
    ],
  );

  Widget _form() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: _foldKeyboard,
          validator: _validateName,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: _foldKeyboard,
          validator: _validateEmail,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
          onTapOutside: _foldKeyboard,
          validator: _validatePassword,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 12),
          child: Text(
            '${_password.text.length} of 8',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirm,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          obscureText: true,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _agreed ? (_) => _signUp() : null,
          onTapOutside: _foldKeyboard,
          validator: _validateConfirm,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _group,
          decoration: const InputDecoration(labelText: 'Group'),
          items: [
            for (final g in groups) DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (g) => setState(() => _group = g),
          validator: _validateGroup,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _birthText,
          readOnly: true,
          onTap: _pickBirth,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            suffixIcon: Icon(Icons.calendar_today),
          ),
          validator: _validateBirth,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: _agreed,
          onChanged: (v) => setState(() => _agreed = v ?? false),
          title: const Text('I agree to the rules'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _agreed ? _signUp : null,
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}
