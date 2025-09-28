import 'package:equatable/equatable.dart';
import '../../../domain/entities/plan.dart';

/// Base class for multi-select events
abstract class PlansMultiSelectEvent extends Equatable {
  const PlansMultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends PlansMultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select a plan
class EnableMultiSelectModeAndSelect extends PlansMultiSelectEvent {
  final Plan plan;

  const EnableMultiSelectModeAndSelect(this.plan);

  @override
  List<Object?> get props => [plan];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends PlansMultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select a plan
class SelectPlan extends PlansMultiSelectEvent {
  final Plan plan;

  const SelectPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

/// Event to deselect a plan
class DeselectPlan extends PlansMultiSelectEvent {
  final Plan plan;

  const DeselectPlan(this.plan);

  @override
  List<Object?> get props => [plan];
}

/// Event to select all plans
class SelectAllPlans extends PlansMultiSelectEvent {
  final List<Plan> plans;

  const SelectAllPlans({required this.plans});

  @override
  List<Object?> get props => [plans];
}

/// Event to deselect all plans
class DeselectAllPlans extends PlansMultiSelectEvent {
  const DeselectAllPlans();
}

/// Event to bulk export selected plans
class BulkExportPlans extends PlansMultiSelectEvent {
  final String format;

  const BulkExportPlans(this.format);

  @override
  List<Object?> get props => [format];
}
