import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../../../core/bloc/bloc_error_handler_mixin.dart';
import '../../domain/entities/tag_definition.dart';
import '../../domain/usecases/get_tag_definitions_usecase.dart';
import '../../domain/usecases/create_tag_definition_usecase.dart';
import '../../domain/usecases/get_tag_definition_by_id_usecase.dart';
import '../../domain/usecases/get_tag_definition_audit_logs_with_history_usecase.dart';
import '../../domain/usecases/delete_tag_definition_usecase.dart';
import '../../data/datasources/tag_definitions_local_data_source.dart';
import '../../data/models/tag_definition_model.dart';
import 'tag_definitions_event.dart';
import 'tag_definitions_state.dart';

@injectable
class TagDefinitionsBloc extends Bloc<TagDefinitionsEvent, TagDefinitionsState>
    with BlocErrorHandlerMixin {
  final GetTagDefinitionsUseCase _getTagDefinitionsUseCase;
  final CreateTagDefinitionUseCase _createTagDefinitionUseCase;
  final GetTagDefinitionByIdUseCase _getTagDefinitionByIdUseCase;
  final GetTagDefinitionAuditLogsWithHistoryUseCase
  _getTagDefinitionAuditLogsWithHistoryUseCase;
  final DeleteTagDefinitionUseCase _deleteTagDefinitionUseCase;
  final TagDefinitionsLocalDataSource _localDataSource;
  final Logger _logger = Logger();

  List<TagDefinitionModel> _allTagDefinitions = [];
  List<TagDefinition> _allTagDefinitionEntities = [];
  List<TagDefinition> _selectedTagDefinitions = [];
  bool _isMultiSelectMode = false;

  TagDefinitionsBloc(
    this._getTagDefinitionsUseCase,
    this._createTagDefinitionUseCase,
    this._getTagDefinitionByIdUseCase,
    this._getTagDefinitionAuditLogsWithHistoryUseCase,
    this._deleteTagDefinitionUseCase,
    this._localDataSource,
  ) : super(TagDefinitionsInitial()) {
    on<LoadTagDefinitions>(_onLoadTagDefinitions);
    on<RefreshTagDefinitions>(_onRefreshTagDefinitions);
    on<CreateTagDefinition>(_onCreateTagDefinition);
    on<GetTagDefinitionById>(_onGetTagDefinitionById);
    on<GetTagDefinitionAuditLogsWithHistory>(
      _onGetTagDefinitionAuditLogsWithHistory,
    );
    on<DeleteTagDefinition>(_onDeleteTagDefinition);

    // Multi-select event handlers
    on<EnableMultiSelectMode>(_onEnableMultiSelectMode);
    on<DisableMultiSelectMode>(_onDisableMultiSelectMode);
    on<EnableMultiSelectModeAndSelect>(_onEnableMultiSelectModeAndSelect);
    on<SelectTagDefinition>(_onSelectTagDefinition);
    on<DeselectTagDefinition>(_onDeselectTagDefinition);
    on<SelectAllTagDefinitions>(_onSelectAllTagDefinitions);
    on<DeselectAllTagDefinitions>(_onDeselectAllTagDefinitions);
    on<ExportSelectedTagDefinitions>(_onExportSelectedTagDefinitions);
    on<DeleteSelectedTagDefinitions>(_onDeleteSelectedTagDefinitions);
    on<SearchTagDefinitions>(_onSearchTagDefinitions);
  }

  Future<void> _onLoadTagDefinitions(
    LoadTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(TagDefinitionsLoading());

    try {
      // 1. Try to get data from local cache first
      final cachedTagDefinitions = await _localDataSource
          .getCachedTagDefinitions();

      if (cachedTagDefinitions.isNotEmpty) {
        _allTagDefinitions = cachedTagDefinitions;
        emit(
          TagDefinitionsLoaded(
            cachedTagDefinitions.map((model) => model.toEntity()).toList(),
          ),
        );

        // Sync in background if online (without triggering UI updates)
        _syncTagDefinitionsInBackground();
        return;
      }

      // 2. If no cached data, fetch from remote
      final tagDefinitions = await _getTagDefinitionsUseCase();
      _allTagDefinitions = tagDefinitions
          .map((entity) => TagDefinitionModel.fromEntity(entity))
          .toList();

      // Cache the fetched data locally
      await _localDataSource.cacheTagDefinitions(_allTagDefinitions);

      // Store the converted entities
      _allTagDefinitionEntities = tagDefinitions;

      emit(TagDefinitionsLoaded(tagDefinitions));
    } catch (e) {
      // If remote fails but we have cached data, return cached data
      try {
        final cachedTagDefinitions = await _localDataSource
            .getCachedTagDefinitions();
        if (cachedTagDefinitions.isNotEmpty) {
          _allTagDefinitions = cachedTagDefinitions;
          _allTagDefinitionEntities = cachedTagDefinitions
              .map((model) => model.toEntity())
              .toList();
          emit(TagDefinitionsLoaded(_allTagDefinitionEntities));
          return;
        }
      } catch (cacheError) {
        // Ignore cache error
      }

      final message = handleException(e, context: 'load_tag_definitions');
      emit(TagDefinitionsError(message));
    }
  }

  Future<void> _syncTagDefinitionsInBackground() async {
    try {
      final tagDefinitions = await _getTagDefinitionsUseCase();
      final tagDefinitionModels = tagDefinitions
          .map((entity) => TagDefinitionModel.fromEntity(entity))
          .toList();
      await _localDataSource.cacheTagDefinitions(tagDefinitionModels);
    } catch (e) {
      // Silently fail background sync
    }
  }

  Future<void> _onRefreshTagDefinitions(
    RefreshTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(TagDefinitionsLoading());
    try {
      final tagDefinitions = await _getTagDefinitionsUseCase();
      _allTagDefinitions = tagDefinitions
          .map((entity) => TagDefinitionModel.fromEntity(entity))
          .toList();

      // Cache the refreshed data locally
      await _localDataSource.cacheTagDefinitions(_allTagDefinitions);

      // Store the converted entities
      _allTagDefinitionEntities = tagDefinitions;

      emit(TagDefinitionsLoaded(tagDefinitions));
    } catch (e) {
      final message = handleException(e, context: 'refresh_tag_definitions');
      emit(TagDefinitionsError(message));
    }
  }

  Future<void> _onCreateTagDefinition(
    CreateTagDefinition event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(CreateTagDefinitionLoading());
    try {
      final tagDefinition = await _createTagDefinitionUseCase(
        name: event.name,
        description: event.description,
        isControlTag: event.isControlTag,
        applicableObjectTypes: event.applicableObjectTypes,
      );
      emit(CreateTagDefinitionSuccess(tagDefinition));
    } catch (e) {
      final message = handleException(
        e,
        context: 'create_tag_definition',
        metadata: {
          'name': event.name,
          'isControlTag': event.isControlTag,
          'applicableObjectTypes': event.applicableObjectTypes,
        },
      );
      emit(CreateTagDefinitionError(message));
    }
  }

  Future<void> _onGetTagDefinitionById(
    GetTagDefinitionById event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(SingleTagDefinitionLoading());
    try {
      final tagDefinition = await _getTagDefinitionByIdUseCase(event.id);
      emit(SingleTagDefinitionLoaded(tagDefinition));
    } catch (e) {
      final message = handleException(e, context: 'get_tag_definition_by_id');
      emit(SingleTagDefinitionError(message, event.id));
    }
  }

  Future<void> _onGetTagDefinitionAuditLogsWithHistory(
    GetTagDefinitionAuditLogsWithHistory event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(AuditLogsWithHistoryLoading());
    try {
      final auditLogs = await _getTagDefinitionAuditLogsWithHistoryUseCase(
        event.id,
      );
      emit(AuditLogsWithHistoryLoaded(auditLogs, event.id));
    } catch (e) {
      final message = handleException(
        e,
        context: 'get_tag_definition_audit_logs',
      );
      emit(AuditLogsWithHistoryError(message, event.id));
    }
  }

  Future<void> _onDeleteTagDefinition(
    DeleteTagDefinition event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    _logger.d('🔍 BLoC: _onDeleteTagDefinition called for ID: ${event.id}');
    emit(DeleteTagDefinitionLoading());
    try {
      _logger.d(
        '🔍 BLoC: Calling deleteTagDefinitionUseCase for ID: ${event.id}',
      );
      await _deleteTagDefinitionUseCase(event.id);
      _logger.i(
        '🔍 BLoC: Delete successful, emitting DeleteTagDefinitionSuccess',
      );
      emit(DeleteTagDefinitionSuccess(event.id));
      _logger.d('🔍 BLoC: DeleteTagDefinitionSuccess emitted');
    } catch (e) {
      final message = handleException(
        e,
        context: 'delete_tag_definition',
        metadata: {'tag_definition_id': event.id},
      );
      emit(DeleteTagDefinitionError(message, event.id));
    }
  }

  // Multi-select event handlers
  void _onEnableMultiSelectMode(
    EnableMultiSelectMode event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _isMultiSelectMode = true;
    _selectedTagDefinitions.clear();
    emit(
      TagDefinitionsWithSelection(
        tagDefinitions: List.from(_allTagDefinitionEntities),
        selectedTagDefinitions: List.from(_selectedTagDefinitions),
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  void _onDisableMultiSelectMode(
    DisableMultiSelectMode event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _isMultiSelectMode = false;
    _selectedTagDefinitions.clear();
    emit(
      TagDefinitionsLoaded(
        _allTagDefinitions.map((model) => model.toEntity()).toList(),
      ),
    );
  }

  void _onEnableMultiSelectModeAndSelect(
    EnableMultiSelectModeAndSelect event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _logger.d(
      '🔍 BLoC: Enabling multi-select mode for tag: ${event.tagDefinition.name}',
    );
    _logger.d(
      '🔍 BLoC: _allTagDefinitionEntities count: ${_allTagDefinitionEntities.length}',
    );
    _logger.d(
      '🔍 BLoC: _allTagDefinitions count: ${_allTagDefinitions.length}',
    );

    _isMultiSelectMode = true;
    _selectedTagDefinitions.clear();

    // Find the corresponding entity from _allTagDefinitionEntities
    final correspondingEntity = _allTagDefinitionEntities.firstWhere(
      (entity) => entity.id == event.tagDefinition.id,
      orElse: () => event.tagDefinition,
    );
    _selectedTagDefinitions.add(correspondingEntity);

    // If _allTagDefinitionEntities is empty, convert from _allTagDefinitions
    final tagDefinitions = _allTagDefinitionEntities.isNotEmpty
        ? _allTagDefinitionEntities
        : _allTagDefinitions.map((model) => model.toEntity()).toList();
    _logger.d(
      '🔍 BLoC: Using ${tagDefinitions.length} entities for multi-select',
    );

    emit(
      TagDefinitionsWithSelection(
        tagDefinitions: List.from(tagDefinitions),
        selectedTagDefinitions: List.from(_selectedTagDefinitions),
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  void _onSelectTagDefinition(
    SelectTagDefinition event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _logger.d('🔍 BLoC: Selecting tag: ${event.tagDefinition.name}');
    _logger.d(
      '🔍 BLoC: Current selection count: ${_selectedTagDefinitions.length}',
    );

    // Find the corresponding entity from _allTagDefinitionEntities
    final correspondingEntity = _allTagDefinitionEntities.firstWhere(
      (entity) => entity.id == event.tagDefinition.id,
      orElse: () => event.tagDefinition,
    );

    if (!_selectedTagDefinitions.contains(correspondingEntity)) {
      _selectedTagDefinitions.add(correspondingEntity);
      _logger.d(
        '🔍 BLoC: Added to selection. New count: ${_selectedTagDefinitions.length}',
      );
    } else {
      _logger.d('🔍 BLoC: Tag already selected, skipping');
    }

    _logger.d(
      '🔍 BLoC: Emitting TagDefinitionsWithSelection with ${_selectedTagDefinitions.length} selected items',
    );

    // If _allTagDefinitionEntities is empty, convert from _allTagDefinitions
    final tagDefinitions = _allTagDefinitionEntities.isNotEmpty
        ? _allTagDefinitionEntities
        : _allTagDefinitions.map((model) => model.toEntity()).toList();

    emit(
      TagDefinitionsWithSelection(
        tagDefinitions: List.from(tagDefinitions),
        selectedTagDefinitions: List.from(_selectedTagDefinitions),
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  void _onDeselectTagDefinition(
    DeselectTagDefinition event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _selectedTagDefinitions.remove(event.tagDefinition);
    if (_selectedTagDefinitions.isEmpty) {
      _isMultiSelectMode = false;
      emit(
        TagDefinitionsLoaded(
          _allTagDefinitions.map((model) => model.toEntity()).toList(),
        ),
      );
    } else {
      emit(
        TagDefinitionsWithSelection(
          tagDefinitions: _allTagDefinitions
              .map((model) => model.toEntity())
              .toList(),
          selectedTagDefinitions: List.from(_selectedTagDefinitions),
          isMultiSelectMode: _isMultiSelectMode,
        ),
      );
    }
  }

  void _onSelectAllTagDefinitions(
    SelectAllTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) {
    // If _allTagDefinitionEntities is empty, convert from _allTagDefinitions
    final tagDefinitions = _allTagDefinitionEntities.isNotEmpty
        ? _allTagDefinitionEntities
        : _allTagDefinitions.map((model) => model.toEntity()).toList();

    _selectedTagDefinitions = List.from(tagDefinitions);
    emit(
      TagDefinitionsWithSelection(
        tagDefinitions: List.from(tagDefinitions),
        selectedTagDefinitions: List.from(_selectedTagDefinitions),
        isMultiSelectMode: _isMultiSelectMode,
      ),
    );
  }

  void _onDeselectAllTagDefinitions(
    DeselectAllTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) {
    _selectedTagDefinitions.clear();
    _isMultiSelectMode = false;

    // If _allTagDefinitionEntities is empty, convert from _allTagDefinitions
    final tagDefinitions = _allTagDefinitionEntities.isNotEmpty
        ? _allTagDefinitionEntities
        : _allTagDefinitions.map((model) => model.toEntity()).toList();

    emit(TagDefinitionsLoaded(tagDefinitions));
  }

  Future<void> _onExportSelectedTagDefinitions(
    ExportSelectedTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(ExportTagDefinitionsLoading());
    try {
      if (_selectedTagDefinitions.isEmpty) {
        emit(
          ExportTagDefinitionsError('No tag definitions selected for export'),
        );
        return;
      }

      // Generate file content based on format
      Uint8List bytes;
      String fileExtension;

      if (event.format.toLowerCase() == 'excel') {
        bytes = _generateExcelContent(_selectedTagDefinitions);
        fileExtension = 'xlsx';
      } else {
        final csvContent = _generateCSVContent(_selectedTagDefinitions);
        bytes = Uint8List.fromList(
          csvContent.codeUnits.map((e) => e.toUnsigned(8)).toList(),
        );
        fileExtension = 'csv';
      }

      // Generate timestamp for unique file naming
      final dateTime = DateTime.now();
      final formattedDate =
          '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}${dateTime.second.toString().padLeft(2, '0')}';

      final fileName = 'tag_definitions_export_$formattedDate.$fileExtension';

      // Show file picker to let user choose where to save
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported tag definitions',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [fileExtension],
        bytes: bytes,
      );

      if (outputFile == null) {
        // User cancelled file picker
        emit(ExportTagDefinitionsError('Export cancelled by user'));
        return;
      }

      // Store the count before clearing the selection
      final exportedCount = _selectedTagDefinitions.length;

      // Disable multi-select mode after export
      _isMultiSelectMode = false;
      _selectedTagDefinitions.clear();

      final successMessage =
          '$exportedCount tag definitions exported successfully to ${outputFile.split('/').last}';

      emit(ExportTagDefinitionsSuccess(successMessage));

      // Return to normal list view
      emit(
        TagDefinitionsLoaded(
          _allTagDefinitions.map((model) => model.toEntity()).toList(),
        ),
      );
    } catch (e) {
      final message = handleException(e, context: 'export_tag_definitions');
      emit(ExportTagDefinitionsError(message));
    }
  }

  Future<void> _onDeleteSelectedTagDefinitions(
    DeleteSelectedTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(DeleteSelectedTagDefinitionsLoading());
    try {
      final selectedIds = _selectedTagDefinitions.map((td) => td.id).toList();
      final deletedCount = selectedIds.length;

      // Delete each selected tag definition
      for (final id in selectedIds) {
        await _deleteTagDefinitionUseCase(id);
      }

      // Remove deleted items from local cache
      _allTagDefinitions.removeWhere((model) => selectedIds.contains(model.id));

      // Disable multi-select mode after deletion
      _isMultiSelectMode = false;
      _selectedTagDefinitions.clear();

      emit(
        DeleteSelectedTagDefinitionsSuccess(
          'Successfully deleted $deletedCount tag definitions',
          deletedCount,
        ),
      );

      // Return to normal list view
      emit(
        TagDefinitionsLoaded(
          _allTagDefinitions.map((model) => model.toEntity()).toList(),
        ),
      );
    } catch (e) {
      final message = handleException(
        e,
        context: 'delete_tag_definition',
        metadata: {
          'selected_count': _selectedTagDefinitions.length,
          'selected_ids': _selectedTagDefinitions.map((td) => td.id).toList(),
        },
      );
      emit(DeleteSelectedTagDefinitionsError(message));
    }
  }

  void _onSearchTagDefinitions(
    SearchTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) {
    // Guard clause: Don't search if data isn't loaded yet
    if (_allTagDefinitions.isEmpty) {
      return;
    }

    if (event.searchQuery.isEmpty) {
      // If search is empty, return to normal loaded state
      emit(
        TagDefinitionsLoaded(
          _allTagDefinitions.map((model) => model.toEntity()).toList(),
        ),
      );
      return;
    }

    // Filter tag definitions based on search query
    final searchResults = _allTagDefinitions
        .map((model) => model.toEntity())
        .where(
          (tagDef) =>
              tagDef.name.toLowerCase().contains(
                event.searchQuery.toLowerCase(),
              ) ||
              (tagDef.description?.toLowerCase().contains(
                    event.searchQuery.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();

    emit(TagDefinitionsSearchResults(searchResults, event.searchQuery));
  }

  /// Generate CSV content for tag definitions
  String _generateCSVContent(List<TagDefinition> tagDefinitions) {
    final buffer = StringBuffer();

    // CSV Header
    buffer.writeln('ID,Name,Description,Type,Object Types,Audit Logs');

    // CSV Data
    for (final tagDef in tagDefinitions) {
      final objectTypes = tagDef.applicableObjectTypes.join(';');
      final auditLogs = tagDef.auditLogs?.length.toString() ?? '0';

      buffer.writeln(
        '"${tagDef.id}",'
        '"${tagDef.name}",'
        '"${tagDef.description ?? ''}",'
        '"${tagDef.isControlTag ? 'Control Tag' : 'Regular Tag'}",'
        '"$objectTypes",'
        '"$auditLogs"',
      );
    }

    return buffer.toString();
  }

  /// Generate Excel content for tag definitions
  Uint8List _generateExcelContent(List<TagDefinition> tagDefinitions) {
    // Create a new Excel file
    final excel = Excel.createExcel();

    // Delete the default sheet
    excel.delete('Sheet1');

    // Create a new sheet for tag definitions
    final sheet = excel['Tag Definitions'];

    // Define headers
    final headers = [
      'ID',
      'Name',
      'Description',
      'Type',
      'Object Types',
      'Audit Logs Count',
    ];

    // Add headers to the first row
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue50,
        fontColorHex: ExcelColor.white,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );
    }

    // Add tag definition data
    for (int rowIndex = 0; rowIndex < tagDefinitions.length; rowIndex++) {
      final tagDef = tagDefinitions[rowIndex];
      final row = rowIndex + 1; // +1 because headers are in row 0

      // ID
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(
        tagDef.id,
      );

      // Name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(
        tagDef.name,
      );

      // Description
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = TextCellValue(
        tagDef.description ?? '',
      );

      // Type
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row))
          .value = TextCellValue(
        tagDef.isControlTag ? 'Control Tag' : 'Regular Tag',
      );

      // Object Types
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row))
          .value = TextCellValue(
        tagDef.applicableObjectTypes.join('; '),
      );

      // Audit Logs Count
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row))
          .value = IntCellValue(
        tagDef.auditLogs?.length ?? 0,
      );
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 20);
    }

    // Add some styling to the data rows
    for (int rowIndex = 1; rowIndex <= tagDefinitions.length; rowIndex++) {
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
        );
        cell.cellStyle = CellStyle(
          horizontalAlign: HorizontalAlign.Left,
          verticalAlign: VerticalAlign.Center,
        );
      }
    }

    // Save the Excel file
    return Uint8List.fromList(excel.save()!);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
