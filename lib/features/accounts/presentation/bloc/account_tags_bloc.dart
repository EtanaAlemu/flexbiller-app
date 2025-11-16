import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/usecases/assign_multiple_tags_to_account_usecase.dart';
import '../../domain/usecases/assign_tag_to_account_usecase.dart';
import '../../domain/usecases/create_tag_usecase.dart';
import '../../domain/usecases/delete_tag_usecase.dart';
import '../../domain/usecases/get_account_tags_usecase.dart';
import '../../domain/usecases/get_all_tags_for_account_usecase.dart';
import '../../domain/usecases/refresh_account_tags_usecase.dart';
import '../../domain/usecases/remove_multiple_tags_from_account_usecase.dart';
import '../../domain/usecases/remove_tag_from_account_usecase.dart';
import '../../domain/usecases/update_tag_usecase.dart';
import '../../domain/repositories/account_tags_repository.dart';
import '../../domain/entities/account_tag.dart';
import 'events/account_tags_events.dart';
import 'states/account_tags_states.dart';

@injectable
class AccountTagsBloc extends Bloc<AccountTagsEvent, AccountTagsState>
    with BlocErrorHandlerMixin {
  final GetAccountTagsUseCase _getAccountTagsUseCase;
  final GetAllTagsForAccountUseCase _getAllTagsForAccountUseCase;
  final CreateTagUseCase _createTagUseCase;
  final UpdateTagUseCase _updateTagUseCase;
  final DeleteTagUseCase _deleteTagUseCase;
  final AssignTagToAccountUseCase _assignTagToAccountUseCase;
  final AssignMultipleTagsToAccountUseCase _assignMultipleTagsToAccountUseCase;
  final RemoveTagFromAccountUseCase _removeTagFromAccountUseCase;
  final RemoveMultipleTagsFromAccountUseCase
  _removeMultipleTagsFromAccountUseCase;
  final RefreshAccountTagsUseCase _refreshAccountTagsUseCase;
  final AccountTagsRepository _accountTagsRepository;
  final Logger _logger = Logger();

  StreamSubscription<List<AccountTagAssignment>>? _accountTagsSubscription;
  String? _currentAccountId;

  AccountTagsBloc(
    this._getAccountTagsUseCase,
    this._getAllTagsForAccountUseCase,
    this._createTagUseCase,
    this._updateTagUseCase,
    this._deleteTagUseCase,
    this._assignTagToAccountUseCase,
    this._assignMultipleTagsToAccountUseCase,
    this._removeTagFromAccountUseCase,
    this._removeMultipleTagsFromAccountUseCase,
    this._refreshAccountTagsUseCase,
    this._accountTagsRepository,
  ) : super(const AccountTagsInitial('')) {
    on<LoadAccountTags>(_onLoadAccountTags);
    on<RefreshAccountTags>(_onRefreshAccountTags);
    on<LoadAllTagsForAccount>(_onLoadAllTagsForAccount);
    on<CreateTag>(_onCreateTag);
    on<UpdateTag>(_onUpdateTag);
    on<DeleteTag>(_onDeleteTag);
    on<AssignTagToAccount>(_onAssignTagToAccount);
    on<AssignMultipleTagsToAccount>(_onAssignMultipleTagsToAccount);
    on<RemoveTagFromAccount>(_onRemoveTagFromAccount);
    on<RemoveMultipleTagsFromAccount>(_onRemoveMultipleTagsFromAccount);
    on<SyncAccountTags>(_onSyncAccountTags);
    on<ClearAccountTags>(_onClearAccountTags);
  }

  /// Initialize stream subscriptions for reactive updates from repository
  void _initializeStreamSubscriptions() {
    _logger.d('🔍 AccountTagsBloc: Initializing stream subscriptions');
    _logger.d(
      '🔍 AccountTagsBloc: Repository stream: ${_accountTagsRepository.accountTagsStream}',
    );
    // Listen to account tags updates from repository background sync
    _accountTagsSubscription = _accountTagsRepository.accountTagsStream.listen(
      (updatedTags) {
        _logger.d(
          '🔍 AccountTagsBloc: Stream update received with ${updatedTags.length} tags, currentAccountId: $_currentAccountId',
        );

        // Only process updates if we have a current account ID
        if (_currentAccountId != null) {
          // Filter tags for the current account
          final currentAccountTags = updatedTags
              .where((tag) => tag.accountId == _currentAccountId)
              .toList();

          _logger.d(
            '🔍 AccountTagsBloc: Filtered ${currentAccountTags.length} tags for current account',
          );

          // Update tags list with fresh data directly without triggering new events
          final currentState = state;
          _logger.d(
            '🔍 AccountTagsBloc: Current state: ${currentState.runtimeType}',
          );

          // Update if we're in a loaded state or loading state
          if (currentState is AccountTagsLoaded) {
            emit(
              AccountTagsLoaded(
                accountId: _currentAccountId!,
                tags: currentAccountTags,
              ),
            );
            _logger.d(
              '🔍 AccountTagsBloc: Account tags updated from background sync: ${currentAccountTags.length} tags',
            );
          } else if (currentState is AccountTagsLoading) {
            // Handle the case when we're still loading and background sync completes
            emit(
              AccountTagsLoaded(
                accountId: _currentAccountId!,
                tags: currentAccountTags,
              ),
            );
            _logger.d(
              '🔍 AccountTagsBloc: Account tags loaded from background sync: ${currentAccountTags.length} tags',
            );
          } else {
            _logger.d(
              '🔍 AccountTagsBloc: Ignoring stream update - current state is not loaded or loading: ${currentState.runtimeType}',
            );
          }
        } else {
          _logger.d(
            '🔍 AccountTagsBloc: Ignoring stream update - no current account ID set',
          );
        }
      },
      onError: (error) {
        _logger.e('🔍 AccountTagsBloc: Stream error: $error');
        if (_currentAccountId != null) {
          emit(
            AccountTagsFailure(
              accountId: _currentAccountId!,
              message: 'Stream error: $error',
            ),
          );
        }
      },
    );
    _logger.d('🔍 AccountTagsBloc: Stream subscription created successfully');
  }

  Future<void> _onLoadAccountTags(
    LoadAccountTags event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: LoadAccountTags called for accountId: ${event.accountId}',
    );

    _currentAccountId = event.accountId;

    // Set up stream subscription if not already set up
    if (_accountTagsSubscription == null) {
      _initializeStreamSubscriptions();
    }

    emit(AccountTagsLoading(event.accountId));

    try {
      // LOCAL-FIRST: This will return local data immediately
      final tags = await _getAccountTagsUseCase(event.accountId);
      _logger.d(
        '🔍 AccountTagsBloc: LoadAccountTags succeeded with ${tags.length} tags from local cache',
      );
      emit(AccountTagsLoaded(accountId: event.accountId, tags: tags));

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when new data arrives
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: LoadAccountTags exception: $e');
      emit(
        AccountTagsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshAccountTags(
    RefreshAccountTags event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: RefreshAccountTags called for accountId: ${event.accountId}',
    );

    if (state is AccountTagsLoaded) {
      final currentState = state as AccountTagsLoaded;
      emit(
        AccountTagsLoaded(accountId: event.accountId, tags: currentState.tags),
      );
    } else {
      emit(AccountTagsLoading(event.accountId));
    }

    try {
      // LOCAL-FIRST: This will return local data immediately and trigger background sync
      final tags = await _refreshAccountTagsUseCase(event.accountId);
      _logger.d(
        '🔍 AccountTagsBloc: RefreshAccountTags succeeded with ${tags.length} tags from local cache',
      );
      emit(AccountTagsLoaded(accountId: event.accountId, tags: tags));

      // The repository will handle background sync and emit updates via stream
      // The UI will reactively update when fresh data arrives
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: RefreshAccountTags exception: $e');
      emit(
        AccountTagsFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onLoadAllTagsForAccount(
    LoadAllTagsForAccount event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: LoadAllTagsForAccount called for accountId: ${event.accountId}',
    );

    emit(AllTagsForAccountLoading(event.accountId));

    try {
      final allTags = await _getAllTagsForAccountUseCase(event.accountId);
      _logger.d(
        '🔍 AccountTagsBloc: LoadAllTagsForAccount succeeded with ${allTags.length} tags',
      );
      emit(
        AllTagsForAccountLoaded(accountId: event.accountId, allTags: allTags),
      );
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: LoadAllTagsForAccount exception: $e');
      emit(
        AllTagsForAccountFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onCreateTag(
    CreateTag event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: CreateTag called for accountId: ${event.accountId}',
    );

    emit(CreatingTag(event.accountId));

    try {
      final tag = await _createTagUseCase(
        name: event.name,
        description: event.description,
        color: event.color,
        icon: event.icon,
      );

      _logger.i('🔍 AccountTagsBloc: CreateTag succeeded');
      emit(TagCreated(accountId: event.accountId, tag: tag));
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: CreateTag exception: $e');
      emit(
        TagCreationFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onUpdateTag(
    UpdateTag event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: UpdateTag called for accountId: ${event.accountId}, tagId: ${event.tagId}',
    );

    emit(UpdatingTag(accountId: event.accountId, tagId: event.tagId));

    try {
      final tag = await _updateTagUseCase(
        tagId: event.tagId,
        name: event.name,
        description: event.description,
        color: event.color,
        icon: event.icon,
      );

      _logger.i('🔍 AccountTagsBloc: UpdateTag succeeded');
      emit(TagUpdated(accountId: event.accountId, tag: tag));
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: UpdateTag exception: $e');
      emit(
        TagUpdateFailure(
          accountId: event.accountId,
          tagId: event.tagId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onDeleteTag(
    DeleteTag event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: DeleteTag called for accountId: ${event.accountId}, tagId: ${event.tagId}',
    );

    emit(DeletingTag(accountId: event.accountId, tagId: event.tagId));

    try {
      await _deleteTagUseCase(event.tagId);

      _logger.i('🔍 AccountTagsBloc: DeleteTag succeeded');
      emit(TagDeleted(accountId: event.accountId, tagId: event.tagId));
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: DeleteTag exception: $e');
      emit(
        TagDeletionFailure(
          accountId: event.accountId,
          tagId: event.tagId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onAssignTagToAccount(
    AssignTagToAccount event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: AssignTagToAccount called for accountId: ${event.accountId}, tagId: ${event.tagId}',
    );

    emit(AssigningTag(accountId: event.accountId, tagId: event.tagId));

    try {
      final tagAssignment = await _assignTagToAccountUseCase(
        accountId: event.accountId,
        tagId: event.tagId,
      );

      _logger.i('🔍 AccountTagsBloc: AssignTagToAccount succeeded');
      emit(
        TagAssigned(accountId: event.accountId, tagAssignment: tagAssignment),
      );
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: AssignTagToAccount exception: $e');
      emit(
        TagAssignmentFailure(
          accountId: event.accountId,
          tagId: event.tagId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onAssignMultipleTagsToAccount(
    AssignMultipleTagsToAccount event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: AssignMultipleTagsToAccount called for accountId: ${event.accountId}',
    );

    emit(
      AssigningMultipleTags(accountId: event.accountId, tagIds: event.tagIds),
    );

    try {
      final tagAssignments = await _assignMultipleTagsToAccountUseCase(
        event.accountId,
        event.tagIds,
      );

      _logger.i('🔍 AccountTagsBloc: AssignMultipleTagsToAccount succeeded');
      emit(
        MultipleTagsAssigned(
          accountId: event.accountId,
          tagAssignments: tagAssignments,
        ),
      );
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e(
        '🔍 AccountTagsBloc: AssignMultipleTagsToAccount exception: $e',
      );
      emit(
        MultipleTagsAssignmentFailure(
          accountId: event.accountId,
          tagIds: event.tagIds,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRemoveTagFromAccount(
    RemoveTagFromAccount event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: RemoveTagFromAccount called for accountId: ${event.accountId}, tagId: ${event.tagId}',
    );

    emit(RemovingTag(accountId: event.accountId, tagId: event.tagId));

    try {
      await _removeTagFromAccountUseCase(
        accountId: event.accountId,
        tagId: event.tagId,
      );

      _logger.i('🔍 AccountTagsBloc: RemoveTagFromAccount succeeded');
      emit(TagRemoved(accountId: event.accountId, tagId: event.tagId));
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: RemoveTagFromAccount exception: $e');
      emit(
        TagRemovalFailure(
          accountId: event.accountId,
          tagId: event.tagId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onRemoveMultipleTagsFromAccount(
    RemoveMultipleTagsFromAccount event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: RemoveMultipleTagsFromAccount called for accountId: ${event.accountId}',
    );

    emit(
      RemovingMultipleTags(accountId: event.accountId, tagIds: event.tagIds),
    );

    try {
      await _removeMultipleTagsFromAccountUseCase(
        event.accountId,
        event.tagIds,
      );

      _logger.i('🔍 AccountTagsBloc: RemoveMultipleTagsFromAccount succeeded');
      emit(
        MultipleTagsRemoved(accountId: event.accountId, tagIds: event.tagIds),
      );
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e(
        '🔍 AccountTagsBloc: RemoveMultipleTagsFromAccount exception: $e',
      );
      emit(
        MultipleTagsRemovalFailure(
          accountId: event.accountId,
          tagIds: event.tagIds,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  Future<void> _onSyncAccountTags(
    SyncAccountTags event,
    Emitter<AccountTagsState> emit,
  ) async {
    _logger.d(
      '🔍 AccountTagsBloc: SyncAccountTags called for accountId: ${event.accountId}',
    );

    emit(SyncingAccountTags(event.accountId));

    try {
      final tags = await _refreshAccountTagsUseCase(event.accountId);
      _logger.i(
        '🔍 AccountTagsBloc: SyncAccountTags succeeded with ${tags.length} tags',
      );
      emit(AccountTagsSynced(accountId: event.accountId, tags: tags));
      add(LoadAccountTags(event.accountId)); // Reload to update UI
    } catch (e) {
      _logger.e('🔍 AccountTagsBloc: SyncAccountTags exception: $e');
      emit(
        AccountTagsSyncFailure(
          accountId: event.accountId,
          message: 'An unexpected error occurred: $e',
        ),
      );
    }
  }

  void _onClearAccountTags(
    ClearAccountTags event,
    Emitter<AccountTagsState> emit,
  ) {
    emit(AccountTagsInitial(event.accountId));
  }

  @override
  Future<void> close() async {
    await _accountTagsSubscription?.cancel();
    return super.close();
  }
}
