import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/task_models.dart';
import 'state/app_state.dart';
import 'core/di/providers.dart';

const Color kPrimaryGreen = Color(0xFF1B5E20);
const Color kWarningYellow = Color(0xFFFFD600);
const Color kBaseGrey = Color(0xFFF5F5F5);
const Color kMidGrey = Color(0xFF9E9E9E);

final AppState _appState = AppState(initialTasks: createMockTasks());

void main() {
  runApp(const ProviderScope(child: MiicaApp()));
}

class MiicaApp extends StatelessWidget {
  const MiicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryGreen),
          scaffoldBackgroundColor: kBaseGrey,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}

extension AppStateExtension on BuildContext {
  AppState get appState => AppStateScope.of(this);
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;
  late final AnimationController _syncController;

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
    _userController.dispose();
    _pinController.dispose();
    _syncController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final appState = context.appState;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _userController.text.trim();
    final password = _pinController.text.trim();
    final repository = ref.read(authRepositoryProvider);

    setState(() => _isLoading = true);
    try {
      final ok = await repository.login(username: email, pin: password);
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales inválidas')),
        );
        return;
      }
      appState.setLoggedUser(email);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        _SlidePageRoute(
          builder: (_) => const TaskListScreen(),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de autenticación')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openConnectionSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ConnectionSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final theme = Theme.of(context);
    final isLoading = _isLoading;

    final lastSync = appState.lastSync;
    final syncText = lastSync != null
        ? 'Última sincronización: '
            '${lastSync.day.toString().padLeft(2, '0')}/'
            '${lastSync.month.toString().padLeft(2, '0')}/'
            '${lastSync.year} – '
            '${lastSync.hour.toString().padLeft(2, '0')}:'
            '${lastSync.minute.toString().padLeft(2, '0')}'
        : 'Última sincronización: —';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewInsets = MediaQuery.of(context).viewInsets.bottom;
            const horizontalPadding = 24.0;
            const topPadding = 32.0;
            final bottomPadding = 32.0 + viewInsets;
            final verticalPadding = topPadding + bottomPadding;
            final availableWidth = math.max(
              0.0,
              constraints.maxWidth - (horizontalPadding * 2),
            );
            final maxWidth = constraints.maxWidth >= 520 ? 480.0 : availableWidth;
            final minHeight = math.max(0.0, constraints.maxHeight - verticalPadding);

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
                          _Logo(color: kPrimaryGreen),
                          const SizedBox(height: 32),
                          Text(
                            'Sistema de Cuadrillas – Arbolado GCBA',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF1E2939),
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          if (!appState.isOnline)
                            const _OfflineAlertBanner(),
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
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'PIN o Contraseña',
                              hintText: 'Ingresá tu PIN de acceso',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePin = !_obscurePin);
                                },
                              ),
                            ),
                            obscureText: _obscurePin,
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
                              onPressed: isLoading ? null : _onSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: isLoading
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
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                                      color: appState.isOnline ? kPrimaryGreen : Colors.grey,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  syncText,
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
                                side: const BorderSide(color: kMidGrey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _SyncInfo(),
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
}

class _Logo extends StatelessWidget {
  const _Logo({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: color,
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

class _OfflineAlertBanner extends StatelessWidget {
  const _OfflineAlertBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWarningYellow,
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

class _SyncInfo extends StatelessWidget {
  const _SyncInfo();

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final lastSync = appState.lastSync;
    final pending = appState.pendingSync;
    final statusText = appState.isOnline ? 'Conectado' : 'Sin conexión';
    final statusColor = appState.isOnline ? kPrimaryGreen : const Color(0xFFB45309);

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
              appState.isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 18,
              color: statusColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$statusText • Última sincronización ${lastSync != null ? TimeOfDay.fromDateTime(lastSync).format(context) : '—'}',
                style: TextStyle(
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6A7282),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('r2 software © 2025', style: tertiary),
        const SizedBox(height: 12),
        Text(
          'Política de privacidad',
          style: tertiary?.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  TaskStatus? _statusFilter;
  String? _communeFilter;
  late final VoidCallback _searchListener;

  @override
  void initState() {
    super.initState();
    _searchListener = () => setState(() {});
    _searchController.addListener(_searchListener);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_searchListener)
      ..dispose();
    super.dispose();
  }

  void _toggleStatus(TaskStatus status) {
    setState(() {
      _statusFilter = _statusFilter == status ? null : status;
    });
  }

  Future<void> _openProfile() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProfileSheet(),
    );
  }

  void _openConnectionSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ConnectionSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final tasks = appState.tasks;
    final search = _searchController.text.trim().toLowerCase();

    final communes = {
      for (final task in tasks) task.commune,
    }.toList()
      ..sort();

    final filtered = tasks.where((task) {
      final matchesStatus = _statusFilter == null || task.status == _statusFilter;
      final matchesQuery = search.isEmpty || task.matchesQuery(search);
      final matchesCommune = _communeFilter == null || task.commune == _communeFilter;
      return matchesStatus && matchesQuery && matchesCommune;
    }).toList();

    return Scaffold(
      floatingActionButton: appState.simulationAuthorized
          ? FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Función ad-hoc en desarrollo.')),
                );
              },
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Pedido ad-hoc'),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = math.min(680.0, constraints.maxWidth - 32);
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: math.max(360.0, maxWidth)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!appState.isOnline) const _OfflineBanner(),
                      const SizedBox(height: 16),
                      _TaskListTopBar(
                        onConnectionTap: _openConnectionSettings,
                        onProfileTap: _openProfile,
                      ),
                      const SizedBox(height: 16),
                      _TaskFilters(
                        controller: _searchController,
                        statusFilter: _statusFilter,
                        onStatusSelected: _toggleStatus,
                        showing: filtered.length,
                        total: tasks.length,
                        communes: communes,
                        communeFilter: _communeFilter,
                        onCommuneSelected: (value) => setState(() => _communeFilter = value),
                      ),
                      const SizedBox(height: 24),
                      if (filtered.isEmpty)
                        const _EmptyState()
                      else
                        Column(
                          children: [
                            for (final task in filtered) ...[
                              _TaskCard(
                                task: task,
                                onPrimaryTap: () => _handlePrimaryAction(task),
                                onDetailsTap: () => _openTaskDetail(task),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handlePrimaryAction(Task task) {
    final appState = context.appState;
    switch (task.status) {
      case TaskStatus.pending:
        final updated = Task(
          status: TaskStatus.inProgress,
          priority: task.priority,
          commune: task.commune,
          address: task.address,
          reference: task.reference,
          species: task.species,
          tags: task.tags,
          alerts: task.alerts,
          primaryAction: const TaskAction(
            label: 'Continuar',
            style: TaskActionStyle.primary,
          ),
          secondaryAction: task.secondaryAction,
          detail: task.detail,
        );
        appState.updateTask(task, updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarea en ejecución: ${task.address}')),
        );
        break;
      case TaskStatus.inProgress:
        _openTaskDetail(task);
        break;
      case TaskStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La tarea ya está completada.')),
        );
        break;
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    await Navigator.of(context).push(
      _SlidePageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
    setState(() {});
  }
}

class _TaskListTopBar extends StatelessWidget {
  const _TaskListTopBar({
    required this.onConnectionTap,
    required this.onProfileTap,
  });

  final VoidCallback onConnectionTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tareas',
                  style: textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF1E2939),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  appState.loggedUser != null ? 'Bienvenido, ${appState.loggedUser}' : '',
                  style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7282)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onConnectionTap,
            icon: Icon(
              appState.isOnline ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              size: 18,
              color: const Color(0xFF4A5565),
            ),
            label: Text(
              appState.isOnline ? 'Modo en línea' : 'Modo sin conexión',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5565),
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: Color(0xFFFFD600)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: appState.isOnline ? Colors.white : const Color(0xFFFFF9C4),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: kPrimaryGreen,
            child: IconButton(
              onPressed: onProfileTap,
              icon: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters({
    required this.controller,
    required this.statusFilter,
    required this.onStatusSelected,
    required this.showing,
    required this.total,
    required this.communes,
    required this.communeFilter,
    required this.onCommuneSelected,
  });

  final TextEditingController controller;
  final TaskStatus? statusFilter;
  final ValueChanged<TaskStatus> onStatusSelected;
  final int showing;
  final int total;
  final List<String> communes;
  final String? communeFilter;
  final ValueChanged<String?> onCommuneSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Buscar por calle, chapa o referencia…',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Estado',
            style: textTheme.labelLarge?.copyWith(
              color: const Color(0xFF6A7282),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in TaskStatus.values)
                _StatusFilterChip(
                  status: status,
                  selected: statusFilter == status,
                  onSelected: () => onStatusSelected(status),
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: communeFilter,
            decoration: InputDecoration(
              labelText: 'Filtrar por comuna',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Todas las comunas'),
              ),
              for (final commune in communes)
                DropdownMenuItem<String?>(
                  value: commune,
                  child: Text(commune),
                ),
            ],
            onChanged: onCommuneSelected,
          ),
          const SizedBox(height: 16),
          Text(
            'Mostrando $showing de $total tareas',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.status,
    required this.selected,
    required this.onSelected,
  });

  final TaskStatus status;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final style = status.chipStyle;
    return FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      label: Text(status.label),
      labelStyle: TextStyle(
        color: selected ? style.foreground : const Color(0xFF4A5565),
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: selected ? style.background : const Color(0xFFF5F5F5),
      selectedColor: style.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? style.border : const Color(0xFFD1D5DC),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onPrimaryTap,
    required this.onDetailsTap,
  });

  final Task task;
  final VoidCallback onPrimaryTap;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(16);

    final primaryLabel = task.status == TaskStatus.pending
        ? 'Iniciar'
        : task.status == TaskStatus.inProgress
            ? 'Continuar'
            : 'Completado';

    final primaryStyle = task.status == TaskStatus.completed
        ? TaskActionStyle.success
        : TaskActionStyle.primary;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: borderRadius,
          border: Border.all(color: const Color(0xFFE5E5E5)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              offset: Offset(0, 1),
              blurRadius: 3,
              spreadRadius: -1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(status: task.status),
                    if (task.priority != null) _PriorityChip(priority: task.priority!),
                  ],
                ),
                const Spacer(),
                Text(
                  task.commune,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6A7282),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.address,
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF1E2939),
                letterSpacing: -0.2,
              ),
            ),
            if (task.reference.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18, color: Color(0xFF4A5565)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.reference,
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4A5565),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Especie:',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A5565),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  task.species,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1E2939),
                  ),
                ),
              ],
            ),
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in task.tags) _TaskTagChip(tag: tag),
                ],
              ),
            ],
            if (task.alerts.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: [
                  for (final alert in task.alerts) ...[
                    _TaskAlertBanner(alert: alert),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TaskActionButton(
                    action: TaskAction(
                      label: primaryLabel,
                      style: primaryStyle,
                    ),
                    onPressed: onPrimaryTap,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TaskActionButton(
                    action: const TaskAction(
                      label: 'Ver detalle',
                      style: TaskActionStyle.outline,
                      icon: Icons.chevron_right,
                    ),
                    onPressed: onDetailsTap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final style = status.chipStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.border),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final style = priority.chipStyle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.border),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TaskTagChip extends StatelessWidget {
  const _TaskTagChip({required this.tag});

  final TaskTag tag;

  @override
  Widget build(BuildContext context) {
    final style = tag.variant.style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.border),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          color: style.foreground,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TaskAlertBanner extends StatelessWidget {
  const _TaskAlertBanner({required this.alert});

  final TaskAlert alert;

  @override
  Widget build(BuildContext context) {
    final style = alert.variant.style;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: style.border),
      ),
      child: Row(
        children: [
          Icon(style.icon, size: 16, color: style.foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert.message,
              style: TextStyle(
                color: style.foreground,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskActionButton extends StatelessWidget {
  const _TaskActionButton({required this.action, required this.onPressed});

  final TaskAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (action.style) {
      case TaskActionStyle.primary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _ActionLabel(action: action),
        );
      case TaskActionStyle.success:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF008236),
            side: const BorderSide(color: Color(0xFF00A63D), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _ActionLabel(action: action),
        );
      case TaskActionStyle.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0A0A0A),
            side: const BorderSide(color: Color(0xFFD1D5DC), width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _ActionLabel(action: action),
        );
    }
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.action});

  final TaskAction action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          action.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        if (action.icon != null) ...[
          const SizedBox(width: 8),
          Icon(action.icon, size: 18),
        ],
      ],
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;
  late TaskDetail _detail;
  late TaskWorkDetail _work;
  late TaskPhotoRequirements _photos;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _detail = widget.task.detail;
    _work = _detail.work;
    _photos = _detail.photos;
  }

  void _updateWork(TaskWorkDetail work) {
    setState(() {
      _work = work;
      _detail = _detail.copyWith(work: work);
    });
  }

  void _updatePhotos(TaskPhotoRequirements photos) {
    setState(() {
      _photos = photos;
      _detail = _detail.copyWith(photos: photos);
    });
  }

  bool get _isReadyToComplete {
    final pruningOk = _work.pruningTypeField.value != null;
    final modelOk = _work.modelKeyField.value != null;
    final photosOk =
        _photos.slots.where((slot) => slot.required).every((slot) => slot.captured);
    return pruningOk && modelOk && photosOk;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveWithoutSend() {
    final updatedTask = Task(
      status: _task.status,
      priority: _task.priority,
      commune: _task.commune,
      address: _task.address,
      reference: _task.reference,
      species: _task.species,
      tags: _task.tags,
      alerts: _task.alerts,
      primaryAction: _task.primaryAction,
      secondaryAction: _task.secondaryAction,
      detail: _detail,
    );
    context.appState.updateTask(_task, updatedTask);
    _task = updatedTask;
    _showSnack('Guardado localmente.');
  }

  Future<void> _saveAndSend() async {
    final pruningFilled = _work.pruningTypeField.value != null;
    final modelFilled = _work.modelKeyField.value != null;
    final photosOk =
        _photos.slots.where((slot) => slot.required).every((slot) => slot.captured);

    if (!pruningFilled || !modelFilled || !photosOk) {
      _updateWork(
        _work.copyWith(
          pruningTypeField: _work.pruningTypeField.copyWith(
            hasError: !pruningFilled,
          ),
          modelKeyField: _work.modelKeyField.copyWith(
            hasError: !modelFilled,
          ),
        ),
      );
      _updatePhotos(
        _photos.copyWith(
          showError: !photosOk,
          errorMessage: 'Debes cargar las tres fotos',
        ),
      );
      _showSnack('Completá los campos obligatorios.');
      return;
    }

    final isOnline = context.appState.isOnline;
    if (!isOnline) {
      context.appState.addPendingSync();
    } else {
      context.appState.updateLastSync(DateTime.now());
    }

    final updatedTask = Task(
      status: TaskStatus.completed,
      priority: _task.priority,
      commune: _task.commune,
      address: _task.address,
      reference: _task.reference,
      species: _task.species,
      tags: _task.tags,
      alerts: _task.alerts.where((alert) => alert.variant != TaskAlertVariant.warning).toList(),
      primaryAction: const TaskAction(
        label: 'Completado',
        style: TaskActionStyle.success,
        icon: Icons.check_circle_outline,
      ),
      secondaryAction: _task.secondaryAction,
      detail: _detail.copyWith(isConnected: isOnline),
    );
    context.appState.updateTask(_task, updatedTask);
    _task = updatedTask;

    if (!mounted) return;
    _showSnack(isOnline
        ? 'Tarea enviada correctamente.'
        : 'Guardado localmente. Se enviará al reconectarse.');

    final signatureCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SignatureScreen(taskAddress: _task.address),
        fullscreenDialog: true,
      ),
    );
    if (signatureCompleted == true && mounted) {
      _showSnack('Firma guardada para ${_task.address}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _TaskDetailAppBar(task: _task),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = math.min(720.0, constraints.maxWidth - 32);
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(360.0, maxWidth),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TaskDetailTreeCard(detail: _detail),
                      const SizedBox(height: 16),
                      TaskDetailWorkCard(
                        work: _work,
                        onWorkChanged: _updateWork,
                      ),
                      const SizedBox(height: 16),
                      TaskDetailPhotoCard(
                        photos: _photos,
                        onPhotosChanged: _updatePhotos,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: TaskDetailBottomBar(
        isConnected: context.appState.isOnline,
        onSend: _saveAndSend,
        onSaveOnly: _saveWithoutSend,
        isReadyToComplete: _isReadyToComplete,
      ),
    );
  }
}

class _TaskDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TaskDetailAppBar({required this.task});

  final Task task;

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    final statusStyle = task.status.chipStyle;
    return AppBar(
      backgroundColor: kPrimaryGreen,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Detalle de Tarea',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusStyle.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusStyle.border),
              ),
              child: Text(
                task.status.label,
                style: TextStyle(
                  color: statusStyle.foreground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Historial no disponible en la maqueta.')),
          ),
          icon: const Icon(Icons.file_open_outlined, color: Colors.white),
          tooltip: 'Ver historial',
        ),
        IconButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opciones avanzadas en desarrollo.')),
          ),
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: 'Más opciones',
        ),
      ],
    );
  }
}

class TaskDetailCard extends StatelessWidget {
  const TaskDetailCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1D5DC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0x191B5E20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPrimaryGreen, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF364153),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class TaskDetailTreeCard extends StatelessWidget {
  const TaskDetailTreeCard({required this.detail});

  final TaskDetail detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return TaskDetailCard(
      title: 'Datos del Árbol',
      icon: Icons.park_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskDetailField(
            label: 'Ubicación',
            value: detail.location,
            valueStyle: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF1E2939),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TaskDetailField(label: 'N° de Chapa', value: detail.plate),
          const SizedBox(height: 16),
          TaskDetailField(label: 'Referencia', value: detail.reference),
          const SizedBox(height: 16),
          TaskDetailField(label: 'Especie', value: detail.speciesFullName),
          const SizedBox(height: 16),
          TaskDetailField(label: 'Comuna', value: detail.commune),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TaskDetailInfoTile(
                  title: 'Diámetro (DM)',
                  value: detail.diameter,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TaskDetailInfoTile(
                  title: 'Altura (H)',
                  value: detail.height,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vista de mapa en desarrollo.')),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: const Color(0xFFF3F3F5),
              side: const BorderSide(color: Color(0xFFD1D5DC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.map_outlined, color: Color(0xFF364153)),
            label: Text(
              'Ver ubicación en mapa',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF364153),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailWorkCard extends StatelessWidget {
  const TaskDetailWorkCard({
    required this.work,
    required this.onWorkChanged,
  });

  final TaskWorkDetail work;
  final ValueChanged<TaskWorkDetail> onWorkChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    void updateDropdown(TaskDropdownField field, String? value, {required bool isPruning}) {
      final updatedField = field.copyWith(
        value: value,
        hasError: field.required && value == null,
      );
      onWorkChanged(
        work.copyWith(
          pruningTypeField: isPruning ? updatedField : work.pruningTypeField,
          removalTypeField: isPruning ? work.removalTypeField : updatedField,
        ),
      );
    }

    return TaskDetailCard(
      title: 'Datos del Trabajo',
      icon: Icons.home_repair_service_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            work.activity,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF364153),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Corte de tránsito',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF364153),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: work.requiresTrafficCut,
                onChanged: (value) => onWorkChanged(work.copyWith(requiresTrafficCut: value)),
                activeColor: kPrimaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TaskDetailDropdownField(
            field: work.pruningTypeField,
            options: const [
              'Poda de mantenimiento',
              'Poda correctiva',
              'Poda reductiva P401',
            ],
            onChanged: (value) => updateDropdown(work.pruningTypeField, value, isPruning: true),
          ),
          const SizedBox(height: 20),
          TaskDetailDropdownField(
            field: work.removalTypeField,
            options: const [
              'Retiro parcial',
              'Retiro total',
              'Retiro sin residuos',
            ],
            onChanged: (value) => updateDropdown(work.removalTypeField, value, isPruning: false),
          ),
          const SizedBox(height: 20),
          for (final step in work.steps) ...[
            TaskChecklistTile(
              item: step,
              onChanged: (value) {
                final updatedSteps = work.steps
                    .map((e) => e.label == step.label ? e.copyWith(completed: value) : e)
                    .toList();
                onWorkChanged(work.copyWith(steps: updatedSteps));
              },
            ),
            const SizedBox(height: 12),
          ],
          TaskDetailDropdownField(
            field: work.modelKeyField,
            options: const [
              'AR-PP01',
              'AR-PR201',
              'AR-COMPL',
              'AR-RP02',
            ],
            onChanged: (value) {
              onWorkChanged(
                work.copyWith(
                  modelKeyField: work.modelKeyField.copyWith(
                    value: value,
                    hasError: work.modelKeyField.required && value == null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          TaskDetailTextArea(
            placeholder: work.observationsPlaceholder,
            current: work.observationsLength,
            limit: work.observationsLimit,
            initialValue: work.observationsValue,
            onChanged: (value) => onWorkChanged(
              work.copyWith(
                observationsLength: value.length,
                observationsValue: value,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailPhotoCard extends StatelessWidget {
  const TaskDetailPhotoCard({
    required this.photos,
    required this.onPhotosChanged,
  });

  final TaskPhotoRequirements photos;
  final ValueChanged<TaskPhotoRequirements> onPhotosChanged;

  void _capture(TaskPhotoSlot slot, BuildContext context, bool fromCamera) {
    final updatedSlots = photos.slots
        .map(
          (e) => e.label == slot.label
              ? e.copyWith(
                  captured: true,
                )
              : e,
        )
        .toList();
    onPhotosChanged(
      photos.copyWith(
        slots: updatedSlots,
        showError: false,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto ${fromCamera ? 'capturada' : 'seleccionada'}: ${slot.label}')),
    );
  }

  void _remove(TaskPhotoSlot slot) {
    final updatedSlots = photos.slots
        .map(
          (e) => e.label == slot.label
              ? e.copyWith(
                  captured: false,
                  thumbnail: null,
                )
              : e,
        )
        .toList();
    onPhotosChanged(
      photos.copyWith(
        slots: updatedSlots,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TaskDetailCard(
      title: 'Evidencia fotográfica',
      icon: Icons.photo_camera_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            photos.reminder,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6A7282),
            ),
          ),
          const SizedBox(height: 16),
          if (photos.showError)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE7000A), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFF9E0711), size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      photos.errorMessage,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9E0711),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (photos.showError) const SizedBox(height: 16),
          for (final slot in photos.slots) ...[
            TaskPhotoSlotRow(
              slot: slot,
              onCamera: () => _capture(slot, context, true),
              onGallery: () => _capture(slot, context, false),
              onRemove: slot.captured ? () => _remove(slot) : null,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class TaskDetailField extends StatelessWidget {
  const TaskDetailField({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6A7282)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ??
              textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF1E2939),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class TaskDetailInfoTile extends StatelessWidget {
  const TaskDetailInfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E2939),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailDropdownField extends StatelessWidget {
  const TaskDetailDropdownField({
    required this.field,
    required this.options,
    required this.onChanged,
  });

  final TaskDropdownField field;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(12);
    final borderColor = field.hasError ? const Color(0xFFFFA1A2) : const Color(0xFFD1D5DC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.label,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF364153),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (field.required)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(color: Color(0xFFE7000A)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: field.value,
          decoration: InputDecoration(
            hintText: field.placeholder,
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: field.hasError ? 2 : 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: borderColor, width: field.hasError ? 2 : 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        if (field.hasError)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Campo obligatorio',
              style: TextStyle(
                color: Color(0xFFE7000A),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

class TaskChecklistTile extends StatelessWidget {
  const TaskChecklistTile({
    required this.item,
    required this.onChanged,
  });

  final TaskChecklistItem item;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: item.completed,
          onChanged: (value) => onChanged(value ?? false),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: Color(0xFFD1D5DC)),
          activeColor: kPrimaryGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF364153),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class TaskDetailTextArea extends StatelessWidget {
  const TaskDetailTextArea({
    required this.placeholder,
    required this.limit,
    required this.current,
    required this.onChanged,
    this.initialValue,
  });

  final String placeholder;
  final int limit;
  final int current;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: initialValue,
          maxLines: 4,
          maxLength: limit,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$current/$limit',
            style: const TextStyle(
              color: Color(0xFF6A7282),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class TaskPhotoSlotRow extends StatelessWidget {
  const TaskPhotoSlotRow({
    required this.slot,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
  });

  final TaskPhotoSlot slot;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              slot.label,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF364153),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (slot.required)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '*',
                  style: TextStyle(color: Color(0xFFE7000A)),
                ),
              ),
            if (slot.captured && onRemove != null)
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Eliminar'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGallery,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryGreen,
                  side: const BorderSide(color: kPrimaryGreen, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: slot.captured ? const Color(0xFFE8F5E9) : const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: slot.captured ? kPrimaryGreen : const Color(0xFFD1D5DC)),
          ),
          child: Center(
            child: slot.captured
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_outline, color: kPrimaryGreen, size: 32),
                      SizedBox(height: 8),
                      Text('Foto cargada'),
                    ],
                  )
                : const Text('Sin imagen'),
          ),
        ),
      ],
    );
  }
}

class TaskDetailBottomBar extends StatelessWidget {
  const TaskDetailBottomBar({
    required this.isConnected,
    required this.onSend,
    required this.onSaveOnly,
    required this.isReadyToComplete,
  });

  final bool isConnected;
  final VoidCallback onSend;
  final VoidCallback onSaveOnly;
  final bool isReadyToComplete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusText = isConnected
        ? 'Conectado – Los datos se enviarán inmediatamente'
        : 'Sin conexión – Se sincronizará al reconectarse';
    final statusColor = isConnected ? kPrimaryGreen : const Color(0xFFB45309);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isReadyToComplete ? onSend : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text(
                  'Guardar y Enviar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: onSaveOnly,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF364153),
                  side: const BorderSide(color: Color(0xFF9E9E9E)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Guardar sin enviar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isConnected ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: textTheme.bodySmall?.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({required this.taskAddress, super.key});

  final String taskAddress;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final List<Offset?> _points = [];

  void _clear() {
    setState(() => _points.clear());
  }

  void _save() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firma del inspector'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Solicitá la firma sobre la pantalla. Se guardará localmente para sincronizar luego.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanUpdate: (details) {
                setState(() => _points.add(details.localPosition));
              },
              onPanEnd: (_) {
                setState(() => _points.add(null));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD1D5DC)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _SignaturePainter(_points),
                  child: Container(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Limpiar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Guardar firma'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimaryGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      if (p1 != null && p2 != null) {
        canvas.drawLine(p1, p2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => oldDelegate.points != points;
}

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
    final textTheme = Theme.of(context).textTheme;

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
          Text(
            'Perfil de cuadrilla',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _ProfileRow(
            label: 'Capataz',
            value: appState.loggedUser ?? '—',
          ),
          _ProfileRow(
            label: 'Cuadrilla asignada',
            value: 'GCBA Norte – equipo 3',
          ),
          _ProfileRow(
            label: 'Comuna',
            value: 'Comunas 1, 3 y 4',
          ),
          _ProfileRow(
            label: 'Sincronización pendiente',
            value: '${appState.pendingSync} tareas',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Simulación GCBA autorizado'),
            subtitle: const Text('Habilita pedidos ad-hoc para pruebas.'),
            value: appState.simulationAuthorized,
            onChanged: (_) {
              appState.toggleSimulationAuthorized();
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                appState.setLoggedUser(null);
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Cerrar sesión'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6A7282)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ConnectionSettingsSheet extends StatelessWidget {
  const ConnectionSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.appState;
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
              const Icon(Icons.settings_ethernet, color: kPrimaryGreen),
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
            onChanged: (_) => appState.toggleConnection(),
          ),
          ListTile(
            title: const Text('Marcar sincronización'),
            subtitle: const Text('Actualiza la fecha y limpia pendientes.'),
            trailing: const Icon(Icons.sync),
            onTap: () {
              appState.updateLastSync(DateTime.now());
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Agregar tarea pendiente'),
            subtitle: const Text('Simula trabajos guardados sin enviar.'),
            trailing: const Icon(Icons.cloud_upload_outlined),
            onTap: () => appState.addPendingSync(),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWarningYellow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, 1),
            blurRadius: 3,
            spreadRadius: -1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF1E2939),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.wifi_off,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sin conexión. Podés trabajar normalmente. Los datos se enviarán al reconectarse.',
              style: TextStyle(
                color: Color(0xFF1E2939),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_turned_in_outlined, size: 48, color: Color(0xFF6A7282)),
          const SizedBox(height: 12),
          Text(
            'No hay tareas para mostrar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF1E2939),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajustá los filtros o sincronizá para ver nuevas asignaciones.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6A7282),
                ),
          ),
        ],
      ),
    );
  }
}

class _SlidePageRoute<T> extends MaterialPageRoute<T> {
  _SlidePageRoute({required WidgetBuilder builder})
      : super(builder: builder, fullscreenDialog: false);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.name == Navigator.defaultRouteName) {
      return child;
    }
    const begin = Offset(1, 0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

List<Task> createMockTasks() {
  return [
    Task(
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      commune: 'Comuna 1',
      address: 'Av. de Mayo 123 — Chapa 123',
      reference: 'Frente a la plaza',
      species: 'Roble',
      tags: const [
        TaskTag('DAP: 45 cm'),
        TaskTag('H: 12 m'),
        TaskTag('Tipo 2'),
        TaskTag('AR-PP01', variant: TaskTagVariant.accent),
      ],
      alerts: const [
        TaskAlert(
          variant: TaskAlertVariant.warning,
          message: 'Faltan fotos (Antes, Durante, Después)',
        ),
      ],
      primaryAction: const TaskAction(
        label: 'Iniciar',
        style: TaskActionStyle.primary,
      ),
      secondaryAction: const TaskAction(
        label: 'Ver detalle',
        style: TaskActionStyle.outline,
        icon: Icons.chevron_right,
      ),
      detail: TaskDetail(
        location: 'Av. Corrientes 1234',
        plate: 'AR-2845',
        reference: 'Esquina con Av. Callao, frente a farmacia',
        speciesFullName: 'Fresno americano (Fraxinus pennsylvanica)',
        commune: 'Comuna 3',
        diameter: '32 cm',
        height: '12 m',
        isConnected: true,
        work: TaskWorkDetail(
          activity: 'Corte raíz en vereda',
          requiresTrafficCut: true,
          pruningTypeField: const TaskDropdownField(
            label: 'Tipo de Poda',
            placeholder: 'Seleccionar tipo de poda',
            required: true,
            hasError: true,
          ),
          removalTypeField: const TaskDropdownField(
            label: 'Tipo de Retiro',
            placeholder: 'Seleccionar tipo de retiro',
            required: false,
          ),
          steps: const [
            TaskChecklistItem(label: 'Poda reductiva P401', completed: false),
            TaskChecklistItem(label: 'Troceo', completed: true),
          ],
          modelKeyField: const TaskDropdownField(
            label: 'Clave modelo',
            placeholder: 'Seleccionar clave modelo',
            required: true,
            hasError: true,
          ),
          observationsPlaceholder: 'Observaciones adicionales (máx. 200 caracteres)',
          observationsLimit: 200,
          observationsLength: 0,
        ),
        photos: TaskPhotoRequirements(
          reminder: 'Las tres fotos son obligatorias',
          showError: true,
          errorMessage: 'Debes cargar las tres fotos',
          slots: const [
            TaskPhotoSlot(label: '📷 Antes', required: true, captured: false),
            TaskPhotoSlot(label: '📷 Durante', required: true, captured: false),
            TaskPhotoSlot(label: '📷 Después', required: true, captured: false),
          ],
        ),
      ),
    ),
    Task(
      status: TaskStatus.inProgress,
      priority: null,
      commune: 'Comuna 4',
      address: 'Balbastro 1571 — Chapa 1571',
      reference: 'Frente al colegio',
      species: 'Plátano',
      tags: const [
        TaskTag('Tipo 2'),
        TaskTag('AR-PP01', variant: TaskTagVariant.accent),
      ],
      alerts: const [
        TaskAlert(
          variant: TaskAlertVariant.info,
          message: 'Pendiente de sincronizar',
        ),
      ],
      primaryAction: const TaskAction(
        label: 'Continuar',
        style: TaskActionStyle.primary,
      ),
      secondaryAction: const TaskAction(
        label: 'Ver detalle',
        style: TaskActionStyle.outline,
        icon: Icons.chevron_right,
      ),
      detail: TaskDetail(
        location: 'Balbastro 1571',
        plate: 'AR-PP01',
        reference: 'Frente al colegio',
        speciesFullName: 'Plátano (Platanus acerifolia)',
        commune: 'Comuna 4',
        diameter: '28 cm',
        height: '11 m',
        isConnected: false,
        work: TaskWorkDetail(
          activity: 'Limpieza de copa',
          requiresTrafficCut: false,
          pruningTypeField: const TaskDropdownField(
            label: 'Tipo de Poda',
            placeholder: 'Seleccionar tipo de poda',
            required: true,
            value: 'Poda de mantenimiento',
          ),
          removalTypeField: const TaskDropdownField(
            label: 'Tipo de Retiro',
            placeholder: 'Seleccionar tipo de retiro',
            required: false,
            value: 'Retiro parcial',
          ),
          steps: const [
            TaskChecklistItem(label: 'Despeje de luminaria', completed: true),
            TaskChecklistItem(label: 'Retiro de ramas bajas', completed: false),
          ],
          modelKeyField: const TaskDropdownField(
            label: 'Clave modelo',
            placeholder: 'Seleccionar clave modelo',
            required: true,
            value: 'AR-PR201',
          ),
          observationsPlaceholder: 'Observaciones adicionales (máx. 200 caracteres)',
          observationsLimit: 200,
          observationsLength: 48,
          observationsValue: 'Llevar cuidado con el cableado cercano.',
        ),
        photos: TaskPhotoRequirements(
          reminder: 'Las tres fotos son obligatorias',
          showError: false,
          errorMessage: '',
          slots: const [
            TaskPhotoSlot(label: '📷 Antes', required: true, captured: true),
            TaskPhotoSlot(label: '📷 Durante', required: true, captured: true),
            TaskPhotoSlot(label: '📷 Después', required: true, captured: false),
          ],
        ),
      ),
    ),
    Task(
      status: TaskStatus.completed,
      priority: null,
      commune: 'Comuna 5',
      address: 'Rivadavia 4567 — Chapa 4567',
      reference: 'Esquina con Medrano',
      species: 'Jacarandá',
      tags: const [
        TaskTag('DAP: 38 cm'),
        TaskTag('H: 10 m'),
        TaskTag('Tipo 1'),
        TaskTag('AR-PP02', variant: TaskTagVariant.accent),
      ],
      alerts: const [],
      primaryAction: const TaskAction(
        label: 'Completado',
        style: TaskActionStyle.success,
        icon: Icons.check_circle_outline,
      ),
      secondaryAction: const TaskAction(
        label: 'Ver detalle',
        style: TaskActionStyle.outline,
        icon: Icons.chevron_right,
      ),
      detail: TaskDetail(
        location: 'Rivadavia 4567',
        plate: 'AR-PP02',
        reference: 'Esquina con Medrano',
        speciesFullName: 'Jacarandá (Jacaranda mimosifolia)',
        commune: 'Comuna 5',
        diameter: '38 cm',
        height: '10 m',
        isConnected: true,
        work: TaskWorkDetail(
          activity: 'Remoción de ramas secas',
          requiresTrafficCut: false,
          pruningTypeField: const TaskDropdownField(
            label: 'Tipo de Poda',
            placeholder: 'Seleccionar tipo de poda',
            required: true,
            value: 'Poda correctiva',
          ),
          removalTypeField: const TaskDropdownField(
            label: 'Tipo de Retiro',
            placeholder: 'Seleccionar tipo de retiro',
            required: false,
            value: 'Retiro total',
          ),
          steps: const [
            TaskChecklistItem(label: 'Retiro de restos', completed: true),
            TaskChecklistItem(label: 'Control final', completed: true),
          ],
          modelKeyField: const TaskDropdownField(
            label: 'Clave modelo',
            placeholder: 'Seleccionar clave modelo',
            required: true,
            value: 'AR-COMPL',
          ),
          observationsPlaceholder: 'Observaciones adicionales (máx. 200 caracteres)',
          observationsLimit: 200,
          observationsLength: 120,
          observationsValue: 'Trabajo verificado con inspector municipal.',
        ),
        photos: TaskPhotoRequirements(
          reminder: 'Las tres fotos son obligatorias',
          showError: false,
          errorMessage: '',
          slots: const [
            TaskPhotoSlot(label: '📷 Antes', required: true, captured: true),
            TaskPhotoSlot(label: '📷 Durante', required: true, captured: true),
            TaskPhotoSlot(label: '📷 Después', required: true, captured: true),
          ],
        ),
      ),
    ),
  ];
}
