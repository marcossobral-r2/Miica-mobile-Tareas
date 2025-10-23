import 'package:flutter/foundation.dart';
import '../models/task_models.dart';

class AppState extends ChangeNotifier {
  AppState({required List<Task> initialTasks})
      : _tasks = initialTasks,
        lastSync = DateTime(2025, 3, 15, 10, 42);

  bool isOnline = true;
  DateTime? lastSync;
  int pendingSync = 0;
  bool simulationAuthorized = false;
  String? loggedUser;

  final List<Task> _tasks;

  List<Task> get tasks => List.unmodifiable(_tasks);

  void toggleConnection() {
    isOnline = !isOnline;
    notifyListeners();
  }

  void updateLastSync(DateTime time) {
    lastSync = time;
    pendingSync = 0;
    notifyListeners();
  }

  void addPendingSync() {
    pendingSync += 1;
    notifyListeners();
  }

  void toggleSimulationAuthorized() {
    simulationAuthorized = !simulationAuthorized;
    notifyListeners();
  }

  void updateTask(Task oldTask, Task updatedTask) {
    final index = _tasks.indexOf(oldTask);
    if (index == -1) return;
    _tasks[index] = updatedTask;
    notifyListeners();
  }

  void setLoggedUser(String? value) {
    loggedUser = value;
    notifyListeners();
  }
}
