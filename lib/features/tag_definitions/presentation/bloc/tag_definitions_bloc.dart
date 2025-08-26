import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_tag_definitions_usecase.dart';
import 'tag_definitions_event.dart';
import 'tag_definitions_state.dart';

@injectable
class TagDefinitionsBloc extends Bloc<TagDefinitionsEvent, TagDefinitionsState> {
  final GetTagDefinitionsUseCase _getTagDefinitionsUseCase;

  TagDefinitionsBloc(this._getTagDefinitionsUseCase) : super(TagDefinitionsInitial()) {
    on<LoadTagDefinitions>(_onLoadTagDefinitions);
    on<RefreshTagDefinitions>(_onRefreshTagDefinitions);
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
}
