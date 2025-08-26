import 'package:equatable/equatable.dart';

abstract class TagsEvent extends Equatable {
  const TagsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTags extends TagsEvent {}

class RefreshTags extends TagsEvent {}
