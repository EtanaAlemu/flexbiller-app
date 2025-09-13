import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/export_service.dart';
import '../../domain/entities/tag.dart';
import '../../domain/usecases/get_all_tags_usecase.dart';
import '../../domain/usecases/search_tags_usecase.dart';
import 'tags_event.dart';
import 'tags_state.dart';

@injectable
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final GetAllTagsUseCase _getAllTagsUseCase;
  final SearchTagsUseCase _searchTagsUseCase;
  final ExportService _exportService;

  List<Tag> _selectedTags = [];
  List<Tag> _allTags = [];
  bool _isMultiSelectMode = false;

  TagsBloc(
    this._getAllTagsUseCase,
    this._searchTagsUseCase,
    this._exportService,
  ) : super(TagsInitial()) {
    on<LoadAllTags>(_onLoadAllTags);
    on<RefreshTags>(_onRefreshTags);
    on<SearchTags>(_onSearchTags);
    on<ClearSearch>(_onClearSearch);

    // Selection event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<SelectTag>(_onSelectTag);
    on<DeselectTag>(_onDeselectTag);
    on<SelectAllTags>(_onSelectAllTags);
    on<DeselectAllTags>(_onDeselectAllTags);

    // Export event handlers
    on<ExportAllTags>(_onExportAllTags);
    on<ExportSelectedTags>(_onExportSelectedTags);

    // Delete event handlers
    on<DeleteSelectedTags>(_onDeleteSelectedTags);
    on<BulkDeleteTags>(_onBulkDeleteTags);
  }

  Future<void> _onLoadAllTags(
    LoadAllTags event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsLoading());
    try {
      final tags = await _getAllTagsUseCase();
      _allTags = tags;
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onRefreshTags(
    RefreshTags event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsLoading());
    try {
      final tags = await _getAllTagsUseCase();
      _allTags = tags;
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onSearchTags(SearchTags event, Emitter<TagsState> emit) async {
    emit(TagsSearchLoading());
    try {
      final tags = await _searchTagsUseCase(
        event.tagDefinitionName,
        offset: event.offset,
        limit: event.limit,
        audit: event.audit,
      );
      emit(
        TagsSearchLoaded(
          tags: tags,
          searchQuery: event.tagDefinitionName,
          offset: event.offset,
          limit: event.limit,
          audit: event.audit,
        ),
      );
    } catch (e) {
      emit(TagsSearchError(e.toString(), event.tagDefinitionName));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsInitial());
  }

  // Selection event handlers
  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<TagsState> emit,
  ) {
    _isMultiSelectMode = true;
    emit(
      TagsWithSelection(
        tags: _allTags,
        selectedTags: _selectedTags,
        isMultiSelectMode: true,
      ),
    );
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<TagsState> emit,
  ) {
    _isMultiSelectMode = false;
    _selectedTags.clear();
    emit(
      TagsWithSelection(
        tags: _allTags,
        selectedTags: [],
        isMultiSelectMode: false,
      ),
    );
  }

  void _onSelectTag(SelectTag event, Emitter<TagsState> emit) {
    if (!_selectedTags.contains(event.tag)) {
      _selectedTags.add(event.tag);
      emit(
        TagsWithSelection(
          tags: _allTags,
          selectedTags: List.from(_selectedTags),
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    }
  }

  void _onDeselectTag(DeselectTag event, Emitter<TagsState> emit) {
    if (_selectedTags.contains(event.tag)) {
      _selectedTags.remove(event.tag);
      emit(
        TagsWithSelection(
          tags: _allTags,
          selectedTags: List.from(_selectedTags),
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    }
  }

  void _onSelectAllTags(SelectAllTags event, Emitter<TagsState> emit) {
    _selectedTags.clear();
    _selectedTags.addAll(event.tags);
    emit(
      TagsWithSelection(
        tags: _allTags,
        selectedTags: List.from(_selectedTags),
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  void _onDeselectAllTags(DeselectAllTags event, Emitter<TagsState> emit) {
    _selectedTags.clear();
    emit(
      TagsWithSelection(
        tags: _allTags,
        selectedTags: [],
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  // Export event handlers
  Future<void> _onExportAllTags(
    ExportAllTags event,
    Emitter<TagsState> emit,
  ) async {
    try {
      emit(TagsExporting(totalTags: _allTags.length, format: event.format));

      String filePath;
      if (event.format == 'excel') {
        filePath = await _exportService.exportTagsToExcel(_allTags);
      } else {
        filePath = await _exportService.exportTagsToCSV(_allTags);
      }

      final fileName = filePath.split('/').last;

      emit(
        TagsExportSuccess(
          filePath: filePath,
          fileName: fileName,
          exportedCount: _allTags.length,
        ),
      );

      // After a short delay, return to the previous state
      await Future.delayed(const Duration(milliseconds: 100));
      emit(
        TagsWithSelection(
          tags: _allTags,
          selectedTags: _selectedTags,
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    } catch (e) {
      emit(TagsExportFailure('Failed to export tags: $e'));
    }
  }

  Future<void> _onExportSelectedTags(
    ExportSelectedTags event,
    Emitter<TagsState> emit,
  ) async {
    try {
      emit(TagsExporting(totalTags: event.tags.length, format: event.format));

      String filePath;
      if (event.format == 'excel') {
        filePath = await _exportService.exportTagsToExcel(event.tags);
      } else {
        filePath = await _exportService.exportTagsToCSV(event.tags);
      }

      final fileName = filePath.split('/').last;

      emit(
        TagsExportSuccess(
          filePath: filePath,
          fileName: fileName,
          exportedCount: event.tags.length,
        ),
      );

      // After a short delay, return to multi-select mode
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(
        TagsWithSelection(
          tags: _allTags,
          selectedTags: _selectedTags,
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    } catch (e) {
      emit(TagsExportFailure('Failed to export selected tags: $e'));
    }
  }

  // Delete event handlers
  Future<void> _onDeleteSelectedTags(
    DeleteSelectedTags event,
    Emitter<TagsState> emit,
  ) async {
    try {
      emit(TagsDeleting(tagsToDelete: event.tags));

      // Simulate API call for deletion
      await Future.delayed(const Duration(seconds: 2));

      // Remove deleted tags from local lists
      _allTags.removeWhere((tag) => event.tags.contains(tag));
      _selectedTags.removeWhere((tag) => event.tags.contains(tag));

      emit(TagsDeleteSuccess(deletedCount: event.tags.length));

      // After a short delay, return to multi-select mode or normal mode
      await Future.delayed(const Duration(milliseconds: 1500));

      if (_isMultiSelectMode) {
        emit(
          TagsWithSelection(
            tags: _allTags,
            selectedTags: _selectedTags,
            isMultiSelectMode: true,
          ),
        );
      } else {
        emit(TagsLoaded(_allTags));
      }
    } catch (e) {
      emit(
        TagsDeleteFailure(
          message: 'Failed to delete selected tags: $e',
          tagsToDelete: event.tags,
        ),
      );
    }
  }

  Future<void> _onBulkDeleteTags(
    BulkDeleteTags event,
    Emitter<TagsState> emit,
  ) async {
    try {
      emit(TagsDeleting(tagsToDelete: event.tags));

      // Simulate API call for bulk deletion
      await Future.delayed(const Duration(seconds: 2));

      // Remove deleted tags from local lists
      _allTags.removeWhere((tag) => event.tags.contains(tag));
      _selectedTags.removeWhere((tag) => event.tags.contains(tag));

      emit(TagsDeleteSuccess(deletedCount: event.tags.length));

      // After a short delay, return to multi-select mode
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(
        TagsWithSelection(
          tags: _allTags,
          selectedTags: _selectedTags,
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    } catch (e) {
      emit(
        TagsDeleteFailure(
          message: 'Failed to bulk delete tags: $e',
          tagsToDelete: event.tags,
        ),
      );
    }
  }
}
