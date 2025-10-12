import 'package:equatable/equatable.dart';

abstract class BundlesEvent extends Equatable {
  const BundlesEvent();

  @override
  List<Object?> get props => [];
}

class LoadBundles extends BundlesEvent {
  const LoadBundles();
}

class RefreshBundles extends BundlesEvent {
  const RefreshBundles();
}

class GetBundleById extends BundlesEvent {
  final String bundleId;

  const GetBundleById(this.bundleId);

  @override
  List<Object?> get props => [bundleId];
}

class GetBundlesForAccount extends BundlesEvent {
  final String accountId;

  const GetBundlesForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadCachedBundles extends BundlesEvent {
  const LoadCachedBundles();
}
