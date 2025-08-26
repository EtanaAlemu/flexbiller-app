import 'package:equatable/equatable.dart';

abstract class TagDefinitionsEvent extends Equatable {
  const TagDefinitionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTagDefinitions extends TagDefinitionsEvent {}

class RefreshTagDefinitions extends TagDefinitionsEvent {}
