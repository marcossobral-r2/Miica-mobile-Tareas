// © r2 software. All rights reserved.
// File: lib/features/tasks/data/task_fixtures.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Static fixtures for task list mock data.
// Author: AI-generated with r2 software guidelines

import 'package:flutter/material.dart';

import 'package:miica_mobile/models/task_models.dart';

/// Provides mock tasks identical to the legacy MIICA demo content.
/// Responsibilities: seed the app state with predictable data.
/// Limits: static fixtures, no HTTP integration.
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
