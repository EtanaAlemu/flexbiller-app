import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/usecases/get_all_bundles_usecase.dart';
import '../../domain/usecases/get_bundle_by_id_usecase.dart';
import '../../domain/usecases/get_bundles_for_account_usecase.dart';
import '../../domain/usecases/get_cached_bundles_usecase.dart';
import '../../domain/usecases/get_cached_bundle_by_id_usecase.dart';
import 'bundles_event.dart';
import 'bundles_state.dart';

@injectable
class BundlesBloc extends Bloc<BundlesEvent, BundlesState>
    with BlocErrorHandlerMixin {
  final GetAllBundlesUseCase _getAllBundlesUseCase;
  final GetBundleByIdUseCase _getBundleByIdUseCase;
  final GetBundlesForAccountUseCase _getBundlesForAccountUseCase;
  final GetCachedBundlesUseCase _getCachedBundlesUseCase;
  final GetCachedBundleByIdUseCase _getCachedBundleByIdUseCase;

  BundlesBloc(
    this._getAllBundlesUseCase,
    this._getBundleByIdUseCase,
    this._getBundlesForAccountUseCase,
    this._getCachedBundlesUseCase,
    this._getCachedBundleByIdUseCase,
  ) : super(const BundlesInitial()) {
    on<LoadBundles>(_onLoadBundles);
    on<RefreshBundles>(_onRefreshBundles);
    on<GetBundleById>(_onGetBundleById);
    on<GetBundlesForAccount>(_onGetBundlesForAccount);
    on<LoadCachedBundles>(_onLoadCachedBundles);
  }

  Future<void> _onLoadBundles(
    LoadBundles event,
    Emitter<BundlesState> emit,
  ) async {
    // First, try to load cached data immediately (fast)
    try {
      final cachedBundles = await _getCachedBundlesUseCase();
      emit(BundlesLoaded(cachedBundles));
    } catch (e) {
      // If no cached data, show loading
      emit(const BundlesLoading());
    }

    // Then, refresh from API in the background (slow)
    try {
      final bundles = await _getAllBundlesUseCase();
      emit(BundlesLoaded(bundles));
    } catch (e) {
      // If API fails but we have cached data, keep showing cached data
      // Only show error if we have no cached data
      if (state is! BundlesLoaded) {
        final message = handleException(e, context: 'load_bundles');
        emit(BundlesError(message));
      }
    }
  }

  Future<void> _onRefreshBundles(
    RefreshBundles event,
    Emitter<BundlesState> emit,
  ) async {
    emit(const BundlesLoading());
    try {
      final bundles = await _getAllBundlesUseCase();
      emit(BundlesLoaded(bundles));
    } catch (e) {
      final message = handleException(e, context: 'refresh_bundles');
      emit(BundlesError(message));
    }
  }

  Future<void> _onGetBundleById(
    GetBundleById event,
    Emitter<BundlesState> emit,
  ) async {
    // First, try to load cached data immediately (fast)
    try {
      final cachedBundle = await _getCachedBundleByIdUseCase(event.bundleId);
      if (cachedBundle != null) {
        emit(SingleBundleLoaded(cachedBundle));
      } else {
        // If no cached data, show loading
        emit(const SingleBundleLoading());
      }
    } catch (e) {
      // If no cached data, show loading
      emit(const SingleBundleLoading());
    }

    // Then, refresh from API in the background (slow)
    try {
      final bundle = await _getBundleByIdUseCase(event.bundleId);
      emit(SingleBundleLoaded(bundle));
    } catch (e) {
      // If API fails but we have cached data, keep showing cached data
      // Only show error if we have no cached data
      if (state is! SingleBundleLoaded) {
        final message = handleException(
          e,
          context: 'get_bundle_by_id',
          metadata: {'bundleId': event.bundleId},
        );
        emit(SingleBundleError(message, event.bundleId));
      }
    }
  }

  Future<void> _onGetBundlesForAccount(
    GetBundlesForAccount event,
    Emitter<BundlesState> emit,
  ) async {
    emit(const AccountBundlesLoading());
    try {
      final bundles = await _getBundlesForAccountUseCase(event.accountId);
      emit(AccountBundlesLoaded(bundles, event.accountId));
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_bundles_for_account',
        metadata: {'accountId': event.accountId},
      );
      emit(AccountBundlesError(message, event.accountId));
    }
  }

  Future<void> _onLoadCachedBundles(
    LoadCachedBundles event,
    Emitter<BundlesState> emit,
  ) async {
    try {
      final bundles = await _getCachedBundlesUseCase();
      emit(BundlesLoaded(bundles));
    } catch (e) {
      final message = handleException(e, context: 'load_cached_bundles');
      emit(BundlesError(message));
    }
  }
}
