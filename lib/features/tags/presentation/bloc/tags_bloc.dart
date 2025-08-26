import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_all_tags_usecase.dart';
import '../../domain/usecases/search_tags_usecase.dart';
import 'tags_event.dart';
import 'tags_state.dart';

@injectable
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final GetAllTagsUseCase _getAllTagsUseCase;
  final SearchTagsUseCase _searchTagsUseCase;

  TagsBloc(this._getAllTagsUseCase, this._searchTagsUseCase) : super(TagsInitial()) {
    on<LoadAllTags>(_onLoadAllTags);
    on<RefreshTags>(_onRefreshTags);
    on<SearchTags>(_onSearchTags);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadAllTags(
    LoadAllTags event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsLoading());
    try {
      final tags = await _getAllTagsUseCase();
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
      emit(TagsLoaded(tags));
    } catch (e) {
      emit(TagsError(e.toString()));
    }
  }

  Future<void> _onSearchTags(
    SearchTags event,
    Emitter<TagsState> emit,
  ) async {
    emit(TagsSearchLoading());
    try {
      final tags = await _searchTagsUseCase(
        event.tagDefinitionName,
        offset: event.offset,
        limit: event.limit,
        audit: event.audit,
      );
      emit(TagsSearchLoaded(
        tags: tags,
        searchQuery: event.tagDefinitionName,
        offset: event.offset,
        limit: event.limit,
        audit: event.audit,
      ));
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
}
