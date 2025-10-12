import 'package:equatable/equatable.dart';
import '../../domain/entities/bundle.dart';

abstract class BundlesState extends Equatable {
  const BundlesState();

  @override
  List<Object?> get props => [];
}

class BundlesInitial extends BundlesState {
  const BundlesInitial();
}

class BundlesLoading extends BundlesState {
  const BundlesLoading();
}

class BundlesLoaded extends BundlesState {
  final List<Bundle> bundles;

  const BundlesLoaded(this.bundles);

  @override
  List<Object?> get props => [bundles];
}

class BundlesError extends BundlesState {
  final String message;

  const BundlesError(this.message);

  @override
  List<Object?> get props => [message];
}

class SingleBundleLoading extends BundlesState {
  const SingleBundleLoading();
}

class SingleBundleLoaded extends BundlesState {
  final Bundle bundle;

  const SingleBundleLoaded(this.bundle);

  @override
  List<Object?> get props => [bundle];
}

class SingleBundleError extends BundlesState {
  final String message;
  final String bundleId;

  const SingleBundleError(this.message, this.bundleId);

  @override
  List<Object?> get props => [message, bundleId];
}

class AccountBundlesLoading extends BundlesState {
  const AccountBundlesLoading();
}

class AccountBundlesLoaded extends BundlesState {
  final List<Bundle> bundles;
  final String accountId;

  const AccountBundlesLoaded(this.bundles, this.accountId);

  @override
  List<Object?> get props => [bundles, accountId];
}

class AccountBundlesError extends BundlesState {
  final String message;
  final String accountId;

  const AccountBundlesError(this.message, this.accountId);

  @override
  List<Object?> get props => [message, accountId];
}
