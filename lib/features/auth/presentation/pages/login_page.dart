// © r2 software. All rights reserved.
// File: lib/features/auth/presentation/pages/login_page.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Login screen UI wired to Riverpod controller.
// Author: AI-generated with r2 software guidelines

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/features/auth/presentation/controllers/login_controller.dart';

/// Presents Omnia login form (email/password) and handles submission feedback.
/// Responsibilities: gather credentials, trigger controller, display state.
/// Limits: does not perform HTTP calls or token persistence directly.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureSecret = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);

    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      if (next.hasError && next.error is String) {
        final message = next.error! as String;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }

      if (previous?.isLoading == true && next is AsyncData<void>) {
        if (!mounted) return;
        context.go('/tareas');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'usuario@miica.com',
                          ),
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresá tu email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            hintText: 'Ingresá tu clave',
                            suffixIcon: IconButton(
                              icon: Icon(_obscureSecret ? Icons.visibility_off : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureSecret = !_obscureSecret;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureSecret,
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresá tu clave';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _onSubmit(loginState),
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: loginState.isLoading ? null : () => _onSubmit(loginState),
                          child: loginState.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Ingresar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit(AsyncValue<void> loginState) {
    if (loginState.isLoading) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final username = _emailController.text.trim();
    final secret = _passwordController.text;
    ref.read(loginControllerProvider.notifier).submit(
          username: username,
          secret: secret,
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
        Text(
          'Bienvenido a MIICA',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresá con tu email corporativo y clave de Omnia.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
