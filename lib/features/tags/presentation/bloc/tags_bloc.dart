import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_all_tags_usecase.dart';
import 'tags_event.dart';
import 'tags_state.dart';

@injectable
class TagsBloc extends Bloc<TagsEvent, TagsState> {
  final GetAllTagsUseCase _getAllTagsUseCase;

  TagsBloc(this._getAllTagsUseCase) : super(TagsInitial()) {
    on<LoadAllTags>(_onLoadAllTags);
    on<RefreshTags>(_onRefreshTags);
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
}
