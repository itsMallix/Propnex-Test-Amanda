import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/core/constants/app_strings.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/core/utils/extensions.dart';
import 'package:propnex_take_home_test/core/utils/validators.dart';
import 'package:propnex_take_home_test/features/auth/presentation/providers/auth_providers.dart';
import 'package:propnex_take_home_test/features/main/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtr = TextEditingController();
  final _passwordCtr = TextEditingController();
  bool _obscurePass = true;

  static const _demoUsername = 'emilys';
  static const _demoPassword = 'emilyspass';

  @override
  void initState() {
    super.initState();
    _usernameCtr.text = _demoUsername;
    _passwordCtr.text = _demoPassword;
  }

  @override
  void dispose() {
    _usernameCtr.dispose();
    _passwordCtr.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();
    final success = await provider.login(
      username: _usernameCtr.text.trim(),
      password: _passwordCtr.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      _showErrorSnackbar(provider.errorMessage);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 40),
                  _LoginForm(
                    formKey: _formKey,
                    usernameCtr: _usernameCtr,
                    passwordCtr: _passwordCtr,
                    obscurePass: _obscurePass,
                    onTogglePass: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  const SizedBox(height: 24),
                  _SubmitButton(onPressed: _submit),
                  const SizedBox(height: 16),
                  _DemoHint(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.storefront_rounded,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.loginTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.loginSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtr;
  final TextEditingController passwordCtr;
  final bool obscurePass;
  final VoidCallback onTogglePass;

  const _LoginForm({
    required this.formKey,
    required this.usernameCtr,
    required this.passwordCtr,
    required this.obscurePass,
    required this.onTogglePass,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usernameCtr,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'e.g. emilys',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
            validator: Validators.username,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: passwordCtr,
            obscureText: obscurePass,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePass,
              ),
            ),
            validator: Validators.password,
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, provider, _) {
        final isLoading = provider.isLoading;
        return FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppTheme.whiteSpaceColor,
                  ),
                )
              : const Text(
                  AppStrings.loginButton,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }
}

class _DemoHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo: username "emilys" / password "emilyspass"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
