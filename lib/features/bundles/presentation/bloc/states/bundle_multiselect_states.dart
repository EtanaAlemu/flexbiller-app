import 'package:equatable/equatable.dart';
import '../../../domain/entities/bundle.dart';

/// Base class for multi-select states
abstract class BundleMultiSelectState extends Equatable {
  const BundleMultiSelectState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BundleMultiSelectInitial extends BundleMultiSelectState {
  const BundleMultiSelectInitial();
}

/// Multi-select mode enabled state
class MultiSelectModeEnabled extends BundleMultiSelectState {
  final List<Bundle> selectedBundles;

  const MultiSelectModeEnabled({required this.selectedBundles});

  @override
  List<Object?> get props => [selectedBundles];
}

/// Multi-select mode disabled state
class MultiSelectModeDisabled extends BundleMultiSelectState {
  const MultiSelectModeDisabled();
}

/// Bundle selected state
class BundleSelected extends BundleMultiSelectState {
  final Bundle bundle;
  final List<Bundle> selectedBundles;

  const BundleSelected({required this.bundle, required this.selectedBundles});

  @override
  List<Object?> get props => [bundle, selectedBundles];
}

/// Bundle deselected state
class BundleDeselected extends BundleMultiSelectState {
  final Bundle bundle;
  final List<Bundle> selectedBundles;

  const BundleDeselected({required this.bundle, required this.selectedBundles});

  @override
  List<Object?> get props => [bundle, selectedBundles];
}

/// All bundles selected state
class AllBundlesSelected extends BundleMultiSelectState {
  final List<Bundle> selectedBundles;

  const AllBundlesSelected({required this.selectedBundles});

  @override
  List<Object?> get props => [selectedBundles];
}

/// All bundles deselected state
class AllBundlesDeselected extends BundleMultiSelectState {
  const AllBundlesDeselected();
}

/// Bulk export in progress state
class BulkExportInProgress extends BundleMultiSelectState {
  final String format;

  const BulkExportInProgress(this.format);

  @override
  List<Object?> get props => [format];
}

/// Bulk export completed state
class BulkExportCompleted extends BundleMultiSelectState {
  final String filePath;
  final int count;

  const BulkExportCompleted({required this.filePath, required this.count});

  @override
  List<Object?> get props => [filePath, count];
}

/// Bulk export failed state
class BulkExportFailed extends BundleMultiSelectState {
  final String error;

  const BulkExportFailed(this.error);

  @override
  List<Object?> get props => [error];
}

/// Bulk delete in progress state
class BulkDeleteInProgress extends BundleMultiSelectState {
  const BulkDeleteInProgress();
}

/// Bulk delete completed state
class BulkDeleteCompleted extends BundleMultiSelectState {
  final int count;

  const BulkDeleteCompleted(this.count);

  @override
  List<Object?> get props => [count];
}

/// Bulk delete failed state
class BulkDeleteFailed extends BundleMultiSelectState {
  final String error;

  const BulkDeleteFailed(this.error);

  @override
  List<Object?> get props => [error];
}
