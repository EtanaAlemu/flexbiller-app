import 'package:equatable/equatable.dart';
import '../../../domain/entities/bundle.dart';

/// Base class for multi-select events
abstract class BundleMultiSelectEvent extends Equatable {
  const BundleMultiSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to enable multi-select mode
class EnableMultiSelectMode extends BundleMultiSelectEvent {
  const EnableMultiSelectMode();
}

/// Event to enable multi-select mode and select a bundle
class EnableMultiSelectModeAndSelect extends BundleMultiSelectEvent {
  final Bundle bundle;

  const EnableMultiSelectModeAndSelect(this.bundle);

  @override
  List<Object?> get props => [bundle];
}

/// Event to enable multi-select mode and select all bundles
class EnableMultiSelectModeAndSelectAll extends BundleMultiSelectEvent {
  final List<Bundle> bundles;

  const EnableMultiSelectModeAndSelectAll({required this.bundles});

  @override
  List<Object?> get props => [bundles];
}

/// Event to disable multi-select mode
class DisableMultiSelectMode extends BundleMultiSelectEvent {
  const DisableMultiSelectMode();
}

/// Event to select a bundle
class SelectBundle extends BundleMultiSelectEvent {
  final Bundle bundle;

  const SelectBundle(this.bundle);

  @override
  List<Object?> get props => [bundle];
}

/// Event to deselect a bundle
class DeselectBundle extends BundleMultiSelectEvent {
  final Bundle bundle;

  const DeselectBundle(this.bundle);

  @override
  List<Object?> get props => [bundle];
}

/// Event to select all bundles
class SelectAllBundles extends BundleMultiSelectEvent {
  final List<Bundle> bundles;

  const SelectAllBundles({required this.bundles});

  @override
  List<Object?> get props => [bundles];
}

/// Event to deselect all bundles
class DeselectAllBundles extends BundleMultiSelectEvent {
  const DeselectAllBundles();
}

/// Event to bulk export selected bundles
class BulkExportBundles extends BundleMultiSelectEvent {
  final String format;

  const BulkExportBundles(this.format);

  @override
  List<Object?> get props => [format];
}

/// Event to bulk delete selected bundles
class BulkDeleteBundles extends BundleMultiSelectEvent {
  const BulkDeleteBundles();
}
