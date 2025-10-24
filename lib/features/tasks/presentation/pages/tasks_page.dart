// © r2 software. All rights reserved.
// File: lib/features/tasks/presentation/pages/tasks_page.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Task list screen matching legacy MIICA visuals with Riverpod.
// Author: AI-generated with r2 software guidelines

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/core/di/providers.dart';
import 'package:miica_mobile/models/task_models.dart';

const Color _kPrimaryGreen = Color(0xFF1B5E20);
const Color _kWarningYellow = Color(0xFFFFD600);

/// Legacy MIICA task list ported to the new architecture.
/// Responsibilities: render filters, task cards, detail sheets, and profile sheet.
/// Limits: operates on in-memory [AppState] mock data.
class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
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

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final tasks = appState.tasks;
    final search = _searchController.text.trim().toLowerCase();

    final List<String> communes =
        (tasks.map((task) => task.commune).toSet().toList()..sort());

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
              backgroundColor: _kPrimaryGreen,
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
                      if (!appState.isOnline) const SizedBox(height: 16),
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
      builder: (_) => const _ConnectionSettingsSheet(),
    );
  }

  void _handlePrimaryAction(Task task) {
    final notifier = ref.read(appStateProvider.notifier);
    switch (task.status) {
      case TaskStatus.pending:
        notifier.updateTask(
          task,
          Task(
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
          ),
        );
        break;
      case TaskStatus.inProgress:
        notifier.updateTask(
          task,
          Task(
            status: TaskStatus.completed,
            priority: task.priority,
            commune: task.commune,
            address: task.address,
            reference: task.reference,
            species: task.species,
            tags: task.tags,
            alerts: task.alerts,
            primaryAction: const TaskAction(
              label: 'Completado',
              style: TaskActionStyle.success,
              icon: Icons.check_circle_outline,
            ),
            secondaryAction: task.secondaryAction,
            detail: task.detail,
          ),
        );
        break;
      case TaskStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La tarea ya está completada.')),
        );
        break;
    }
  }

  Future<void> _openTaskDetail(Task task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskDetailSheet(task: task),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kWarningYellow,
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
        children: const [
          _CircleStatusIcon(),
          SizedBox(width: 12),
          Expanded(
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

class _CircleStatusIcon extends StatelessWidget {
  const _CircleStatusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _TaskListTopBar extends ConsumerWidget {
  const _TaskListTopBar({
    required this.onConnectionTap,
    required this.onProfileTap,
  });

  final VoidCallback onConnectionTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
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
              side: const BorderSide(color: _kWarningYellow),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: appState.isOnline ? Colors.white : const Color(0xFFFFF9C4),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: _kPrimaryGreen,
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
          _TaskCountDisplay(showing: showing, total: total),
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
    return ChoiceChip(
      label: Text(status.label),
      selected: selected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : style.foreground,
        fontWeight: FontWeight.w600,
      ),
      selectedColor: _kPrimaryGreen,
      backgroundColor: style.background,
      shape: StadiumBorder(side: BorderSide(color: style.border)),
    );
  }
}

class _TaskCountDisplay extends StatelessWidget {
  const _TaskCountDisplay({required this.showing, required this.total});

  final int showing;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Mostrando $showing de $total tareas asignadas',
        style: const TextStyle(color: Color(0xFF3730A3)),
      ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskCardHeader(task: task),
          const SizedBox(height: 12),
          _TaskChipsRow(task: task),
          const SizedBox(height: 12),
          _TaskAlerts(alerts: task.alerts),
          const SizedBox(height: 12),
          _TaskActions(
            primary: task.primaryAction,
            secondary: task.secondaryAction,
            onPrimaryTap: onPrimaryTap,
            onDetailsTap: onDetailsTap,
          ),
        ],
      ),
    );
  }
}

class _TaskCardHeader extends StatelessWidget {
  const _TaskCardHeader({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final statusStyle = task.status.chipStyle;
    final priorityStyle = task.priority?.chipStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusStyle.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusStyle.border),
              ),
              child: Text(
                task.status.label,
                style: TextStyle(
                  color: statusStyle.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (priorityStyle != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityStyle.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityStyle.border),
                ),
                child: Text(
                  task.priority!.label,
                  style: TextStyle(
                    color: priorityStyle.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6A7282)),
                const SizedBox(width: 4),
                Text(
                  task.commune,
                  style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6A7282)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          task.address,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1E2939),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          task.reference,
          style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6A7282)),
        ),
        const SizedBox(height: 4),
        Text(
          task.species,
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TaskChipsRow extends StatelessWidget {
  const _TaskChipsRow({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in task.tags)
          _TaskTagChip(
            label: tag.label,
            style: tag.variant.style,
          ),
      ],
    );
  }
}

class _TaskTagChip extends StatelessWidget {
  const _TaskTagChip({required this.label, required this.style});

  final String label;
  final ChipStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TaskAlerts extends StatelessWidget {
  const _TaskAlerts({required this.alerts});

  final List<TaskAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final alert in alerts) ...[
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: alert.variant.style.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: alert.variant.style.border),
            ),
            child: Row(
              children: [
                Icon(alert.variant.style.icon, color: alert.variant.style.foreground),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert.message,
                    style: TextStyle(
                      color: alert.variant.style.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TaskActions extends StatelessWidget {
  const _TaskActions({
    required this.primary,
    required this.secondary,
    required this.onPrimaryTap,
    required this.onDetailsTap,
  });

  final TaskAction primary;
  final TaskAction secondary;
  final VoidCallback onPrimaryTap;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPrimaryTap,
            icon: primary.icon != null
                ? Icon(primary.icon, color: Colors.white)
                : const SizedBox.shrink(),
            label: Text(primary.label),
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor(primary.style),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDetailsTap,
            icon: Icon(secondary.icon ?? Icons.chevron_right),
            label: Text(secondary.label),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _buttonColor(TaskActionStyle style) {
    switch (style) {
      case TaskActionStyle.primary:
        return _kPrimaryGreen;
      case TaskActionStyle.outline:
        return _kPrimaryGreen;
      case TaskActionStyle.success:
        return const Color(0xFF047857);
    }
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

class TaskDetailSheet extends ConsumerWidget {
  const TaskDetailSheet({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final appState = ref.watch(appStateProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
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
              'Detalle de Tarea',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Datos del Árbol',
              children: [
                _DetailRow(label: 'Ubicación', value: task.detail.location),
                _DetailRow(label: 'Chapa', value: task.detail.plate),
                _DetailRow(label: 'Referencia', value: task.detail.reference),
                _DetailRow(label: 'Especie', value: task.detail.speciesFullName),
                _DetailRow(label: 'Comuna', value: task.detail.commune),
                _DetailRow(label: 'Diámetro', value: task.detail.diameter),
                _DetailRow(label: 'Altura', value: task.detail.height),
                _DetailRow(
                  label: 'Conectividad',
                  value: task.detail.isConnected ? 'Conectado' : 'Sin conexión',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Trabajo a realizar',
              children: [
                _DetailRow(label: 'Actividad', value: task.detail.work.activity),
                _DetailRow(
                  label: 'Corte de tránsito',
                  value: task.detail.work.requiresTrafficCut ? 'Sí' : 'No',
                ),
                _DetailRow(
                  label: task.detail.work.pruningTypeField.label,
                  value: task.detail.work.pruningTypeField.value ??
                      task.detail.work.pruningTypeField.placeholder,
                ),
                _DetailRow(
                  label: task.detail.work.removalTypeField.label,
                  value: task.detail.work.removalTypeField.value ??
                      task.detail.work.removalTypeField.placeholder,
                ),
                _DetailRow(
                  label: task.detail.work.modelKeyField.label,
                  value: task.detail.work.modelKeyField.value ??
                      task.detail.work.modelKeyField.placeholder,
                ),
                _DetailRow(
                  label: 'Pasos',
                  value: task.detail.work.steps
                      .map((s) => '${s.completed ? '✔️' : '◻️'} ${s.label}')
                      .join('\n'),
                  multiline: true,
                ),
                _DetailRow(
                  label: 'Observaciones',
                  value: task.detail.work.observationsValue ??
                      task.detail.work.observationsPlaceholder,
                  multiline: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: task.detail.photos.reminder,
              children: [
                _PhotoGrid(requirements: task.detail.photos),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Sincronización',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: 'Estado conexión',
              value: appState.isOnline ? 'En línea' : 'Sin conexión',
            ),
            _DetailRow(
              label: 'Pendientes de sincronizar',
              value: '${appState.pendingSync} tareas',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(color: const Color(0xFF6A7282)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.requirements});

  final TaskPhotoRequirements requirements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requirements.showError)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              requirements.errorMessage,
              style: const TextStyle(color: Color(0xFF9F0712)),
            ),
          ),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final slot in requirements.slots)
              _PhotoTile(slot: slot),
          ],
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.slot});

  final TaskPhotoSlot slot;

  @override
  Widget build(BuildContext context) {
    final borderColor = slot.captured ? _kPrimaryGreen : const Color(0xFFE5E5E5);
    final textColor = slot.captured ? _kPrimaryGreen : const Color(0xFF6A7282);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            slot.captured ? Icons.check_circle : Icons.camera_alt_outlined,
            color: textColor,
          ),
          const SizedBox(height: 8),
          Text(
            slot.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

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

class ProfileSheet extends ConsumerWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
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
          _ProfileRow(label: 'Capataz', value: appState.loggedUser ?? '—'),
          const _ProfileRow(label: 'Cuadrilla asignada', value: 'GCBA Norte – equipo 3'),
          const _ProfileRow(label: 'Comuna', value: 'Comunas 1, 3 y 4'),
          _ProfileRow(
            label: 'Sincronización pendiente',
            value: '${appState.pendingSync} tareas',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Simulación GCBA autorizado'),
            subtitle: const Text('Habilita pedidos ad-hoc para pruebas.'),
            value: appState.simulationAuthorized,
            onChanged: (_) =>
                ref.read(appStateProvider.notifier).toggleSimulationAuthorized(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authRepositoryProvider).logout();
                ref.read(appStateProvider.notifier).setLoggedUser(null);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  context.go('/login');
                }
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
