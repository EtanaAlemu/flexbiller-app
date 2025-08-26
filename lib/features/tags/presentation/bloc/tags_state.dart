import 'package:equatable/equatable.dart';
import '../../domain/entities/tag.dart';

abstract class TagsState extends Equatable {
  const TagsState();

  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<Tag> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class TagsError extends TagsState {
  final String message;

  const TagsError(this.message);

  @override
  List<Object?> get props => [message];
}

class TagsSearchLoading extends TagsState {}

class TagsSearchLoaded extends TagsState {
  final List<Tag> tags;
  final String searchQuery;
  final int offset;
  final int limit;
  final String audit;

  const TagsSearchLoaded({
    required this.tags,
    required this.searchQuery,
    required this.offset,
    required this.limit,
    required this.audit,
  });

  @override
  List<Object?> get props => [tags, searchQuery, offset, limit, audit];
}

class TagsSearchError extends TagsState {
  final String message;
  final String searchQuery;

  const TagsSearchError(this.message, this.searchQuery);

  @override
  List<Object?> get props => [message, searchQuery];
}
