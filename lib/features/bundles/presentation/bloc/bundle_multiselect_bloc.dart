import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/bundle.dart';
import '../bloc/events/bundle_multiselect_events.dart';
import '../bloc/states/bundle_multiselect_states.dart';

/// BLoC for handling multi-select operations
@injectable
class BundleMultiSelectBloc
    extends Bloc<BundleMultiSelectEvent, BundleMultiSelectState> {
  final Logger _logger = Logger();

  final List<Bundle> _selectedBundles = [];
  bool _isMultiSelectMode = false;

  BundleMultiSelectBloc() : super(const BundleMultiSelectInitial()) {
    // Register event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<EnableMultiSelectModeAndSelectAll>(_onEnableMultiSelectModeAndSelectAll);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectBundle>(_onSelectBundle);
    on<DeselectBundle>(_onDeselectBundle);
    on<SelectAllBundles>(_onSelectAllBundles);
    on<DeselectAllBundles>(_onDeselectAllBundles);
    on<BulkExportBundles>(_onBulkExportBundles);
    on<BulkDeleteBundles>(_onBulkDeleteBundles);
  }

  /// Get the current list of selected bundles
  List<Bundle> get selectedBundles => List.unmodifiable(_selectedBundles);

  /// Check if multi-select mode is enabled
  bool get isMultiSelectMode => _isMultiSelectMode;

  /// Check if a bundle is selected
  bool isBundleSelected(Bundle bundle) {
    return _selectedBundles.any(
      (selected) => selected.bundleId == bundle.bundleId,
    );
  }

  /// Get the count of selected bundles
  int get selectedCount => _selectedBundles.length;

  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    _logger.d('Enabling multi-select mode');
    _isMultiSelectMode = true;
    emit(MultiSelectModeEnabled(selectedBundles: _selectedBundles));
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting bundle: ${event.bundle.bundleId}',
    );
    _isMultiSelectMode = true;
    _selectedBundles.add(event.bundle);
    emit(MultiSelectModeEnabled(selectedBundles: _selectedBundles));
  }

  void _onEnableMultiSelectModeAndSelectAll(
    EnableMultiSelectModeAndSelectAll event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    _logger.d(
      'Enabling multi-select mode and selecting all ${event.bundles.length} bundles',
    );
    _isMultiSelectMode = true;
    _selectedBundles.clear();
    _selectedBundles.addAll(event.bundles);
    emit(MultiSelectModeEnabled(selectedBundles: _selectedBundles));
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    _logger.d('Disabling multi-select mode');
    _isMultiSelectMode = false;
    _selectedBundles.clear();
    emit(const MultiSelectModeDisabled());
  }

  void _onSelectBundle(
    SelectBundle event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select bundle: multi-select mode is not enabled');
      return;
    }

    if (!isBundleSelected(event.bundle)) {
      _logger.d('Selecting bundle: ${event.bundle.bundleId}');
      _selectedBundles.add(event.bundle);
      emit(
        BundleSelected(bundle: event.bundle, selectedBundles: _selectedBundles),
      );
    }
  }

  void _onDeselectBundle(
    DeselectBundle event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot deselect bundle: multi-select mode is not enabled');
      return;
    }

    _selectedBundles.removeWhere(
      (bundle) => bundle.bundleId == event.bundle.bundleId,
    );
    _logger.d('Deselecting bundle: ${event.bundle.bundleId}');
    emit(
      BundleDeselected(bundle: event.bundle, selectedBundles: _selectedBundles),
    );
  }

  void _onSelectAllBundles(
    SelectAllBundles event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w('Cannot select all bundles: multi-select mode is not enabled');
      return;
    }

    _selectedBundles.clear();
    _selectedBundles.addAll(event.bundles);
    _logger.d('Selecting all ${event.bundles.length} bundles');
    emit(AllBundlesSelected(selectedBundles: _selectedBundles));
  }

  void _onDeselectAllBundles(
    DeselectAllBundles event,
    Emitter<BundleMultiSelectState> emit,
  ) {
    if (!_isMultiSelectMode) {
      _logger.w(
        'Cannot deselect all bundles: multi-select mode is not enabled',
      );
      return;
    }

    _selectedBundles.clear();
    _logger.d('Deselecting all bundles');
    emit(const AllBundlesDeselected());
  }

  void _onBulkExportBundles(
    BulkExportBundles event,
    Emitter<BundleMultiSelectState> emit,
  ) async {
    _logger.d('Starting bulk export of ${_selectedBundles.length} bundles');
    emit(BulkExportInProgress(event.format));

    try {
      // TODO: Implement actual export functionality
      await Future.delayed(const Duration(seconds: 2)); // Simulate export

      final filePath = '/path/to/exported_bundles.${event.format}';
      _logger.d('Bulk export completed: $filePath');
      emit(
        BulkExportCompleted(filePath: filePath, count: _selectedBundles.length),
      );
    } catch (e) {
      _logger.e('Bulk export failed: $e');
      emit(BulkExportFailed(e.toString()));
    }
  }

  void _onBulkDeleteBundles(
    BulkDeleteBundles event,
    Emitter<BundleMultiSelectState> emit,
  ) async {
    _logger.d('Starting bulk delete of ${_selectedBundles.length} bundles');
    emit(const BulkDeleteInProgress());

    try {
      // TODO: Implement actual delete functionality
      await Future.delayed(const Duration(seconds: 1)); // Simulate delete

      final deletedCount = _selectedBundles.length;
      _selectedBundles.clear();
      _isMultiSelectMode = false;

      _logger.d('Bulk delete completed: $deletedCount bundles deleted');
      emit(BulkDeleteCompleted(deletedCount));
    } catch (e) {
      _logger.e('Bulk delete failed: $e');
      emit(BulkDeleteFailed(e.toString()));
    }
  }
}
