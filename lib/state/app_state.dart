// © r2 software. All rights reserved.
// File: lib/state/app_state.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Riverpod-based app state for tasks, connectivity, and user session.
// Author: AI-generated with r2 software guidelines

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:miica_mobile/features/tasks/data/task_fixtures.dart';
import 'package:miica_mobile/models/task_models.dart';

/// Immutable snapshot of MIICA app-wide state.
/// Responsibilities: hold tasks, connectivity flags, and session data.
/// Limits: no side effects or business logic.
class AppState {
  const AppState({
    required this.tasks,
    required this.isOnline,
    required this.lastSync,
    required this.pendingSync,
    required this.simulationAuthorized,
    required this.loggedUser,
  });

  factory AppState.initial(List<Task> initialTasks) => AppState(
        tasks: List.unmodifiable(initialTasks),
        isOnline: true,
        lastSync: DateTime(2025, 3, 15, 10, 42),
        pendingSync: 0,
        simulationAuthorized: false,
        loggedUser: null,
      );

  final List<Task> tasks;
  final bool isOnline;
  final DateTime? lastSync;
  final int pendingSync;
  final bool simulationAuthorized;
  final String? loggedUser;

  AppState copyWith({
    List<Task>? tasks,
    bool? isOnline,
    DateTime? lastSync,
    int? pendingSync,
    bool? simulationAuthorized,
    String? loggedUser,
  }) {
    return AppState(
      tasks: tasks != null ? List.unmodifiable(tasks) : this.tasks,
      isOnline: isOnline ?? this.isOnline,
      lastSync: lastSync ?? this.lastSync,
      pendingSync: pendingSync ?? this.pendingSync,
      simulationAuthorized: simulationAuthorized ?? this.simulationAuthorized,
      loggedUser: loggedUser ?? this.loggedUser,
    );
  }
}

/// Manages [AppState] mutations triggered by the UI.
/// Responsibilities: expose high-level actions and notify listeners.
/// Limits: operates purely on in-memory fixtures.
class AppStateNotifier extends Notifier<AppState> {
  @override
  AppState build() => AppState.initial(createMockTasks());

  void toggleConnection() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void updateLastSync(DateTime time) {
    state = state.copyWith(lastSync: time, pendingSync: 0);
  }

  void addPendingSync() {
    state = state.copyWith(pendingSync: state.pendingSync + 1);
  }

  void toggleSimulationAuthorized() {
    state = state.copyWith(simulationAuthorized: !state.simulationAuthorized);
  }

  void updateTask(Task oldTask, Task updatedTask) {
    final tasks = List<Task>.from(state.tasks);
    final index = tasks.indexOf(oldTask);
    if (index == -1) {
      return;
    }
    tasks[index] = updatedTask;
    state = state.copyWith(tasks: tasks);
  }

  void setLoggedUser(String? value) {
    state = state.copyWith(loggedUser: value);
  }
}
