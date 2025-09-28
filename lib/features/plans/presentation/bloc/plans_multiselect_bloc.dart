import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/plan.dart';
import '../bloc/events/plans_multiselect_events.dart';
import '../bloc/states/plans_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class PlansMultiSelectBloc
    extends Bloc<PlansMultiSelectEvent, PlansMultiSelectState> {
  final Logger _logger = Logger();

  final List<Plan> _selectedPlans = [];
  bool _isMultiSelectMode = false;

  PlansMultiSelectBloc() : super(const PlansMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectPlan>(_onSelectPlan);
    on<DeselectPlan>(_onDeselectPlan);
    on<SelectAllPlans>(_onSelectAllPlans);
    on<DeselectAllPlans>(_onDeselectAllPlans);
    on<BulkExportPlans>(_onBulkExportPlans);
  }

  /// Get the current list of selected plans
  List<Plan> get selectedPlans => List.unmodifiable(_selectedPlans);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if a plan is selected
  bool isPlanSelected(Plan plan) {
    return _selectedPlans.any((selected) => selected.id == plan.id);
  }

  /// Get the count of selected plans
  int get selectedCount => _selectedPlans.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    emit(MultiSelectModeEnabled(selectedPlans: _selectedPlans));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting plan: ${event.plan.id}',
    );
    _isMultiSelectMode = true;
    _selectedPlans.add(event.plan);
    emit(MultiSelectModeEnabled(selectedPlans: _selectedPlans));
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedPlans.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectPlan(SelectPlan event, Emitter<PlansMultiSelectState> emit) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select plan: multi-select mode not enabled');
      return;
    }

    if (!isPlanSelected(event.plan)) {
      _logger.d('Selecting plan: ${event.plan.id}');
      _selectedPlans.add(event.plan);
      emit(PlanSelected(plan: event.plan, selectedPlans: _selectedPlans));
    }
  }

  void _onDeselectPlan(
    DeselectPlan event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect plan: multi-select mode not enabled');
      return;
    }

    _logger.d('Deselecting plan: ${event.plan.id}');
    _selectedPlans.removeWhere((plan) => plan.id == event.plan.id);
    emit(PlanDeselected(plan: event.plan, selectedPlans: _selectedPlans));
  }

  void _onSelectAllPlans(
    SelectAllPlans event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select all plans: multi-select mode not enabled');
      return;
    }

    _logger.d('Selecting all ${event.plans.length} plans');
    _selectedPlans.clear();
    _selectedPlans.addAll(event.plans);
    emit(AllPlansSelected(selectedPlans: _selectedPlans));
  }

  void _onDeselectAllPlans(
    DeselectAllPlans event,
    Emitter<PlansMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect all plans: multi-select mode not enabled');
      return;
    }

    _logger.d('Deselecting all plans');
    _selectedPlans.clear();
    emit(const AllPlansDeselected());
  }

  Future<void> _onBulkExportPlans(
    BulkExportPlans event,
    Emitter<PlansMultiSelectState> emit,
  ) async {
    if (!_isMultiSelectMode || _selectedPlans.isEmpty) {
      _logger.w(
        'Cannot bulk export: no plans selected or multi-select mode disabled',
      );
      return;
    }

    _logger.d(
      'Starting bulk export of ${_selectedPlans.length} plans in ${event.format} format',
    );
    emit(BulkExportInProgress(selectedPlans: _selectedPlans));

    try {
      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      // Generate file content based on format
      String fileContent;
      String fileExtension;

      if (event.format == 'excel') {
        fileContent = _generateExcelContent(_selectedPlans);
        fileExtension = 'xlsx';
      } else {
        fileContent = _generateCSVContent(_selectedPlans);
        fileExtension = 'csv';
      }

      // Convert string content to bytes
      final bytes = Uint8List.fromList(fileContent.codeUnits);

      // Let user choose where to save the file
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Plans Export',
        fileName: 'plans_export_$formattedDate.$fileExtension',
        type: event.format == 'excel' ? FileType.custom : FileType.custom,
        allowedExtensions: event.format == 'excel' ? ['xlsx'] : ['csv'],
        bytes: bytes,
      );

      if (outputFile != null) {
        _logger.d('Plans exported successfully to: $outputFile');
        emit(BulkExportCompleted(filePath: outputFile));

        // Close multi-select mode after successful export with a brief delay
        await Future.delayed(const Duration(milliseconds: 1500));
        _isMultiSelectMode = false;
        _selectedPlans.clear();
        emit(const MultiSelectModeDisabled());
      } else {
        _logger.d('Export cancelled by user');
        emit(const PlansMultiSelectInitial());
      }
    } catch (e) {
      _logger.e('Error during bulk export: $e');
      emit(BulkExportFailed(error: e.toString()));
    }
  }

  /// Generate CSV content for plans
  String _generateCSVContent(List<Plan> plans) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln(
      'Plan ID,Name,Description,Price,Billing Cycle,Is Active,Features Count,Created At,Updated At',
    );

    // CSV Data
    for (final plan in plans) {
      buffer.writeln(
        [
          plan.id,
          '"${plan.name}"',
          '"${plan.description}"',
          plan.price.toStringAsFixed(2),
          plan.billingCycle,
          plan.isActive ? 'Yes' : 'No',
          plan.flexbillPlanFeatures.length,
          plan.createdAt.toIso8601String(),
          plan.updatedAt.toIso8601String(),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  /// Generate Excel content for plans (simplified CSV format for now)
  String _generateExcelContent(List<Plan> plans) {
    // For now, we'll generate a CSV format that can be opened in Excel
    // In a real implementation, you might want to use a proper Excel library
    return _generateCSVContent(plans);
  }

  /// Toggle selection of a plan
  void togglePlanSelection(Plan plan) {
    if (!_isMultiSelectMode) {
      add(const EnableMultiSelectMode());
    }

    if (isPlanSelected(plan)) {
      add(DeselectPlan(plan));
    } else {
      add(SelectPlan(plan));
    }
  }

  /// Clear all selections
  void clearSelections() {
    if (_isMultiSelectMode) {
      add(const DeselectAllPlans());
    }
  }

  /// Exit multi-select mode
  void exitMultiSelectMode() {
    if (_isMultiSelectMode) {
      add(const DisableMultiSelectMode());
    }
  }
}
