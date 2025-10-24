// © r2 software. All rights reserved.
// File: lib/features/auth/presentation/pages/login_page.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Login screen UI recreated to match legacy MIICA visuals with new auth flow.
// Author: AI-generated with r2 software guidelines

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/core/di/providers.dart';
import 'package:miica_mobile/features/auth/presentation/controllers/login_controller.dart';

const Color _kPrimaryGreen = Color(0xFF1B5E20);
const Color _kWarningYellow = Color(0xFFFFD600);
const Color _kMidGrey = Color(0xFF9E9E9E);

/// Presents the Omnia login with the legacy MIICA UI but powered by Riverpod/GoRouter.
/// Responsibilities: render identical visuals, wire form submission to LoginController.
/// Limits: stores only UI state (connection simulation), no token handling.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  late final AnimationController _syncController;

  bool _obscureSecret = true;

  @override
  void initState() {
    super.initState();
    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _syncController.dispose();
    _userController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final appState = ref.watch(appStateProvider);

    ref.listen<AsyncValue<void>>(loginControllerProvider, (previous, next) {
      if (next.hasError && next.error is String) {
        final message = next.error! as String;
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      }

      if (previous?.isLoading == true && next is AsyncData<void>) {
        if (!mounted) return;
        final username = _userController.text.trim();
        ref.read(appStateProvider.notifier).setLoggedUser(username);
        context.go('/tareas');
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = MediaQuery.of(context).viewInsets.bottom;
            const horizontalPadding = 24.0;
            const topPadding = 32.0;
            final bottomPadding = 32.0 + viewInsets;
            final availableWidth = math.max(
              0.0,
              constraints.maxWidth - (horizontalPadding * 2),
            );
            final maxWidth = constraints.maxWidth >= 520 ? 480.0 : availableWidth;
            final minHeight = math.max(
              0.0,
              constraints.maxHeight - (topPadding + bottomPadding),
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    minHeight: minHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Logo(),
                          const SizedBox(height: 32),
                          Text(
                            'Sistema de Cuadrillas – Arbolado GCBA',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF1E2939),
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          if (!appState.isOnline) const _OfflineAlertBanner(),
                          if (!appState.isOnline) const SizedBox(height: 24),
                          TextFormField(
                            controller: _userController,
                            decoration: InputDecoration(
                              labelText: 'Usuario o Legajo',
                              hintText: 'Ingresá tu usuario o legajo',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Campo obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _secretController,
                            decoration: InputDecoration(
                              labelText: 'PIN o Contraseña',
                              hintText: 'Ingresá tu PIN de acceso',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureSecret ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscureSecret = !_obscureSecret);
                                },
                              ),
                            ),
                            obscureText: _obscureSecret,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Campo obligatorio';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: loginState.isLoading ? null : () => _submit(loginState),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kPrimaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: loginState.isLoading
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Cargando...'),
                                      ],
                                    )
                                  : const Text(
                                      'Ingresar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _syncController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _syncController.value * math.pi * 2,
                                    child: Icon(
                                      Icons.sync,
                                      color: appState.isOnline ? _kPrimaryGreen : Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _buildSyncText(appState.lastSync),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF4A5565),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _openConnectionSettings,
                              icon: const Icon(Icons.settings_outlined, color: Color(0xFF4A5565)),
                              label: const Text('Ver configuración de conexión'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4A5565),
                                side: const BorderSide(color: _kMidGrey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _SyncInfo(
                            isOnline: appState.isOnline,
                            pending: appState.pendingSync,
                            lastSync: appState.lastSync,
                          ),
                          const Spacer(),
                          const _Footer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(AsyncValue<void> state) {
    if (state.isLoading) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    final username = _userController.text.trim();
    final secret = _secretController.text;
    ref.read(loginControllerProvider.notifier).submit(
          username: username,
          secret: secret,
        );
  }

  void _openConnectionSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ConnectionSettingsSheet(),
    );
  }

  String _buildSyncText(DateTime? lastSync) {
    final sync = lastSync;
    if (sync == null) {
      return 'Última sincronización: —';
    }
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    final date =
        '${twoDigits(sync.day)}/${twoDigits(sync.month)}/${sync.year} – ${twoDigits(sync.hour)}:${twoDigits(sync.minute)}';
    return 'Última sincronización: $date';
  }
}

/// MIICA wordmark inside a rounded green square.
/// Responsibilities: mirror original branding block.
/// Limits: static text, no interactions.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _kPrimaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 4),
            blurRadius: 6,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 10),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'MIICA',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

/// Alert banner shown when the device is offline.
/// Responsibilities: replicate yellow offline warning from legacy UI.
/// Limits: static content; visibility handled by parent widget.
class _OfflineAlertBanner extends StatelessWidget {
  const _OfflineAlertBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kWarningYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.wifi_off, color: Color(0xFF1E2939)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sin conexión – Modo Offline activado',
              style: TextStyle(
                color: Color(0xFF1E2939),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays connectivity status, pending sync count, and last sync timestamp.
/// Responsibilities: mirror original footer information block.
/// Limits: relies on parent-provided values; no state.
class _SyncInfo extends StatelessWidget {
  const _SyncInfo({
    required this.isOnline,
    required this.pending,
    required this.lastSync,
  });

  final bool isOnline;
  final int pending;
  final DateTime? lastSync;

  @override
  Widget build(BuildContext context) {
    final statusText = isOnline ? 'Conectado' : 'Sin conexión';
    final statusColor = isOnline ? _kPrimaryGreen : const Color(0xFFB45309);
    final syncLabel =
        lastSync != null ? TimeOfDay.fromDateTime(lastSync!).format(context) : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pending > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9C4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$pending tareas pendientes de sincronizar',
              style: const TextStyle(
                color: Color(0xFF6A4F00),
              ),
            ),
          ),
        if (pending > 0) const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 18,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$statusText • Última sincronización $syncLabel',
                style: TextStyle(color: statusColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Displays MIICA footer metadata.
/// Responsibilities: replicate legacy footer lines.
/// Limits: static content.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6A7282),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('r2 software © 2025', style: style),
        const SizedBox(height: 12),
        Text(
          'Política de privacidad',
          style: style?.copyWith(decoration: TextDecoration.underline),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Bottom sheet that simulates connection settings from the legacy UI.
/// Responsibilities: toggle global connectivity flags and update sync counters.
/// Limits: operates on mock [AppState]; no backend integration.
class _ConnectionSettingsSheet extends ConsumerWidget {
  const _ConnectionSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.settings_ethernet, color: _kPrimaryGreen),
              const SizedBox(width: 12),
              Text(
                'Configuración de conexión',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Modo en línea'),
            subtitle: const Text('Desactivalo para simular trabajo sin conexión.'),
            value: appState.isOnline,
            onChanged: (value) {
              if (value != appState.isOnline) {
                ref.read(appStateProvider.notifier).toggleConnection();
              }
            },
          ),
          ListTile(
            title: const Text('Marcar sincronización'),
            subtitle: const Text('Actualiza la fecha y limpia pendientes.'),
            trailing: const Icon(Icons.sync),
            onTap: () {
              ref.read(appStateProvider.notifier).updateLastSync(DateTime.now());
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Agregar tarea pendiente'),
            subtitle: const Text('Simula trabajos guardados sin enviar.'),
            trailing: const Icon(Icons.cloud_upload_outlined),
            onTap: () {
              ref.read(appStateProvider.notifier).addPendingSync();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
