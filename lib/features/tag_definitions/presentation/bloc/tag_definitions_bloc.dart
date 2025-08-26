import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_tag_definitions_usecase.dart';
import '../../domain/usecases/create_tag_definition_usecase.dart';
import '../../domain/usecases/get_tag_definition_by_id_usecase.dart';
import '../../domain/usecases/get_tag_definition_audit_logs_with_history_usecase.dart';
import '../../domain/usecases/delete_tag_definition_usecase.dart';
import 'tag_definitions_event.dart';
import 'tag_definitions_state.dart';

@injectable
class TagDefinitionsBloc
    extends Bloc<TagDefinitionsEvent, TagDefinitionsState> {
  final GetTagDefinitionsUseCase _getTagDefinitionsUseCase;
  final CreateTagDefinitionUseCase _createTagDefinitionUseCase;
  final GetTagDefinitionByIdUseCase _getTagDefinitionByIdUseCase;
  final GetTagDefinitionAuditLogsWithHistoryUseCase
  _getTagDefinitionAuditLogsWithHistoryUseCase;
  final DeleteTagDefinitionUseCase _deleteTagDefinitionUseCase;

  TagDefinitionsBloc(
    this._getTagDefinitionsUseCase,
    this._createTagDefinitionUseCase,
    this._getTagDefinitionByIdUseCase,
    this._getTagDefinitionAuditLogsWithHistoryUseCase,
    this._deleteTagDefinitionUseCase,
  ) : super(TagDefinitionsInitial()) {
    on<LoadTagDefinitions>(_onLoadTagDefinitions);
    on<RefreshTagDefinitions>(_onRefreshTagDefinitions);
    on<CreateTagDefinition>(_onCreateTagDefinition);
    on<GetTagDefinitionById>(_onGetTagDefinitionById);
    on<GetTagDefinitionAuditLogsWithHistory>(
      _onGetTagDefinitionAuditLogsWithHistory,
    );
    on<DeleteTagDefinition>(_onDeleteTagDefinition);
  }

  Future<void> _onLoadTagDefinitions(
    LoadTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(TagDefinitionsLoading());
    try {
      final tagDefinitions = await _getTagDefinitionsUseCase();
      emit(TagDefinitionsLoaded(tagDefinitions));
    } catch (e) {
      emit(TagDefinitionsError(e.toString()));
    }
  }

  Future<void> _onRefreshTagDefinitions(
    RefreshTagDefinitions event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(TagDefinitionsLoading());
    try {
      final tagDefinitions = await _getTagDefinitionsUseCase();
      emit(TagDefinitionsLoaded(tagDefinitions));
    } catch (e) {
      emit(TagDefinitionsError(e.toString()));
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
      emit(CreateTagDefinitionError(e.toString()));
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
      emit(SingleTagDefinitionError(e.toString(), event.id));
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
      emit(AuditLogsWithHistoryError(e.toString(), event.id));
    }
  }

  Future<void> _onDeleteTagDefinition(
    DeleteTagDefinition event,
    Emitter<TagDefinitionsState> emit,
  ) async {
    emit(DeleteTagDefinitionLoading());
    try {
      await _deleteTagDefinitionUseCase(event.id);
      emit(DeleteTagDefinitionSuccess(event.id));
    } catch (e) {
      emit(DeleteTagDefinitionError(e.toString(), event.id));
    }
  }
}
