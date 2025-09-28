import 'package:equatable/equatable.dart';
import '../../../domain/entities/plan.dart';

/// Base class for multi-select states
abstract class PlansMultiSelectState extends Equatable {
  const PlansMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PlansMultiSelectInitial extends PlansMultiSelectState {
  const PlansMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends PlansMultiSelectState {
  final List<Plan> selectedPlans;

  const MultiSelectModeEnabled({required this.selectedPlans});

  @override
  List<Object?> get props => [selectedPlans];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends PlansMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Plan selected state
class PlanSelected extends PlansMultiSelectState {
  final Plan plan;
  final List<Plan> selectedPlans;

  const PlanSelected({required this.plan, required this.selectedPlans});

  @override
  List<Object?> get props => [plan, selectedPlans];
}

/// Plan deselected state
class PlanDeselected extends PlansMultiSelectState {
  final Plan plan;
  final List<Plan> selectedPlans;

  const PlanDeselected({required this.plan, required this.selectedPlans});

  @override
  List<Object?> get props => [plan, selectedPlans];
}

/// All plans selected state
class AllPlansSelected extends PlansMultiSelectState {
  final List<Plan> selectedPlans;

  const AllPlansSelected({required this.selectedPlans});

  @override
  List<Object?> get props => [selectedPlans];
}

/// All plans deselected state
class AllPlansDeselected extends PlansMultiSelectState {
  const AllPlansDeselected();
}

/// Bulk export in progress state
class BulkExportInProgress extends PlansMultiSelectState {
  final List<Plan> selectedPlans;

  const BulkExportInProgress({required this.selectedPlans});

  @override
  List<Object?> get props => [selectedPlans];
}

/// Bulk export completed state
class BulkExportCompleted extends PlansMultiSelectState {
  final String filePath;

  const BulkExportCompleted({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Bulk export failed state
class BulkExportFailed extends PlansMultiSelectState {
  final String error;

  const BulkExportFailed({required this.error});

  @override
  List<Object?> get props => [error];
}
