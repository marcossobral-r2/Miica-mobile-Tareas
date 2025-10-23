import 'package:flutter/material.dart';

class Task {
  Task({
    required this.status,
    this.priority,
    required this.commune,
    required this.address,
    required this.reference,
    required this.species,
    required this.tags,
    required this.alerts,
    required this.primaryAction,
    required this.secondaryAction,
    required this.detail,
  });

  TaskStatus status;
  TaskPriority? priority;
  final String commune;
  final String address;
  final String reference;
  final String species;
  final List<TaskTag> tags;
  final List<TaskAlert> alerts;
  TaskAction primaryAction;
  TaskAction secondaryAction;
  final TaskDetail detail;

  bool matchesQuery(String query) {
    final searchable = [
      address,
      reference,
      species,
      commune,
      for (final tag in tags) tag.label,
      primaryAction.label,
      secondaryAction.label,
    ].join(' ').toLowerCase();
    return searchable.contains(query);
  }
}

enum TaskStatus { pending, inProgress, completed }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Pendiente';
      case TaskStatus.inProgress:
        return 'En ejecución';
      case TaskStatus.completed:
        return 'Completado';
    }
  }

  ChipStyle get chipStyle {
    switch (this) {
      case TaskStatus.pending:
        return const ChipStyle(
          background: Color(0xFFFEF9C2),
          foreground: Color(0xFF884A00),
          border: Color(0xFFFFDF20),
        );
      case TaskStatus.inProgress:
        return const ChipStyle(
          background: Color(0xFFDBEAFE),
          foreground: Color(0xFF193BB8),
          border: Color(0xFF8DC5FF),
        );
      case TaskStatus.completed:
        return const ChipStyle(
          background: Color(0xFFDCFCE7),
          foreground: Color(0xFF016630),
          border: Color(0xFF7AF1A7),
        );
    }
  }
}

enum TaskPriority { high, medium, low }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }

  ChipStyle get chipStyle {
    switch (this) {
      case TaskPriority.high:
        return const ChipStyle(
          background: Color(0xFFFFE2E2),
          foreground: Color(0xFF9F0712),
          border: Color(0xFFFFE2E2),
        );
      case TaskPriority.medium:
        return const ChipStyle(
          background: Color(0xFFE0F2FE),
          foreground: Color(0xFF035397),
          border: Color(0xFFA0D2FE),
        );
      case TaskPriority.low:
        return const ChipStyle(
          background: Color(0xFFE7F8ED),
          foreground: Color(0xFF1B5E20),
          border: Color(0xFFC1E8CD),
        );
    }
  }
}

class TaskTag {
  const TaskTag(this.label, {this.variant = TaskTagVariant.neutral});

  final String label;
  final TaskTagVariant variant;
}

enum TaskTagVariant { neutral, accent }

extension TaskTagVariantX on TaskTagVariant {
  ChipStyle get style {
    switch (this) {
      case TaskTagVariant.neutral:
        return const ChipStyle(
          background: Color(0xFFF5F5F5),
          foreground: Color(0xFF4A5565),
          border: Color(0xFFF5F5F5),
        );
      case TaskTagVariant.accent:
        return const ChipStyle(
          background: Color(0x191B5E20),
          foreground: Color(0xFF1B5E20),
          border: Color(0x331B5E20),
        );
    }
  }
}

class TaskAlert {
  const TaskAlert({
    required this.variant,
    required this.message,
  });

  final TaskAlertVariant variant;
  final String message;
}

enum TaskAlertVariant { warning, info }

extension TaskAlertVariantX on TaskAlertVariant {
  AlertStyle get style {
    switch (this) {
      case TaskAlertVariant.warning:
        return const AlertStyle(
          background: Color(0xFFFEFCE8),
          foreground: Color(0xFF884A00),
          border: Color(0xFFFFF085),
          icon: Icons.warning_amber_outlined,
        );
      case TaskAlertVariant.info:
        return const AlertStyle(
          background: Color(0xFFEFF6FF),
          foreground: Color(0xFF193BB8),
          border: Color(0xFFBDDAFF),
          icon: Icons.info_outline,
        );
    }
  }
}

class TaskAction {
  const TaskAction({
    required this.label,
    required this.style,
    this.icon,
  });

  final String label;
  final TaskActionStyle style;
  final IconData? icon;
}

enum TaskActionStyle { primary, outline, success }

class ChipStyle {
  const ChipStyle({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

class AlertStyle {
  const AlertStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final IconData icon;
}

class TaskDetail {
  const TaskDetail({
    required this.location,
    required this.plate,
    required this.reference,
    required this.speciesFullName,
    required this.commune,
    required this.diameter,
    required this.height,
    required this.work,
    required this.photos,
    required this.isConnected,
  });

  final String location;
  final String plate;
  final String reference;
  final String speciesFullName;
  final String commune;
  final String diameter;
  final String height;
  final TaskWorkDetail work;
  final TaskPhotoRequirements photos;
  final bool isConnected;

  TaskDetail copyWith({
    TaskWorkDetail? work,
    TaskPhotoRequirements? photos,
    bool? isConnected,
  }) {
    return TaskDetail(
      location: location,
      plate: plate,
      reference: reference,
      speciesFullName: speciesFullName,
      commune: commune,
      diameter: diameter,
      height: height,
      work: work ?? this.work,
      photos: photos ?? this.photos,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class TaskWorkDetail {
  const TaskWorkDetail({
    required this.activity,
    required this.requiresTrafficCut,
    required this.pruningTypeField,
    required this.removalTypeField,
    required this.steps,
    required this.modelKeyField,
    required this.observationsPlaceholder,
    required this.observationsLimit,
    required this.observationsLength,
    this.observationsValue,
  });

  final String activity;
  final bool requiresTrafficCut;
  final TaskDropdownField pruningTypeField;
  final TaskDropdownField removalTypeField;
  final List<TaskChecklistItem> steps;
  final TaskDropdownField modelKeyField;
  final String observationsPlaceholder;
  final int observationsLimit;
  final int observationsLength;
  final String? observationsValue;

  TaskWorkDetail copyWith({
    bool? requiresTrafficCut,
    TaskDropdownField? pruningTypeField,
    TaskDropdownField? removalTypeField,
    List<TaskChecklistItem>? steps,
    TaskDropdownField? modelKeyField,
    int? observationsLength,
    String? observationsValue,
  }) {
    return TaskWorkDetail(
      activity: activity,
      requiresTrafficCut: requiresTrafficCut ?? this.requiresTrafficCut,
      pruningTypeField: pruningTypeField ?? this.pruningTypeField,
      removalTypeField: removalTypeField ?? this.removalTypeField,
      steps: steps ?? this.steps,
      modelKeyField: modelKeyField ?? this.modelKeyField,
      observationsPlaceholder: observationsPlaceholder,
      observationsLimit: observationsLimit,
      observationsLength: observationsLength ?? this.observationsLength,
      observationsValue: observationsValue ?? this.observationsValue,
    );
  }
}

class TaskDropdownField {
  const TaskDropdownField({
    required this.label,
    required this.placeholder,
    required this.required,
    this.value,
    this.hasError = false,
  });

  final String label;
  final String placeholder;
  final bool required;
  final String? value;
  final bool hasError;

  TaskDropdownField copyWith({
    String? value,
    bool? hasError,
  }) {
    return TaskDropdownField(
      label: label,
      placeholder: placeholder,
      required: required,
      value: value ?? this.value,
      hasError: hasError ?? this.hasError,
    );
  }
}

class TaskChecklistItem {
  const TaskChecklistItem({
    required this.label,
    required this.completed,
  });

  final String label;
  final bool completed;

  TaskChecklistItem copyWith({bool? completed}) {
    return TaskChecklistItem(
      label: label,
      completed: completed ?? this.completed,
    );
  }
}

class TaskPhotoRequirements {
  const TaskPhotoRequirements({
    required this.reminder,
    required this.slots,
    required this.showError,
    required this.errorMessage,
  });

  final String reminder;
  final List<TaskPhotoSlot> slots;
  final bool showError;
  final String errorMessage;

  TaskPhotoRequirements copyWith({
    List<TaskPhotoSlot>? slots,
    bool? showError,
    String? errorMessage,
  }) {
    return TaskPhotoRequirements(
      reminder: reminder,
      slots: slots ?? this.slots,
      showError: showError ?? this.showError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TaskPhotoSlot {
  const TaskPhotoSlot({
    required this.label,
    required this.required,
    this.captured = false,
    this.thumbnail,
  });

  final String label;
  final bool required;
  final bool captured;
  final ImageProvider? thumbnail;

  TaskPhotoSlot copyWith({
    bool? captured,
    ImageProvider? thumbnail,
  }) {
    return TaskPhotoSlot(
      label: label,
      required: required,
      captured: captured ?? this.captured,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
