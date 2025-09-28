part of 'plans_bloc.dart';

abstract class PlansEvent extends Equatable {
  const PlansEvent();

  @override
  List<Object> get props => [];
}

class GetPlansEvent extends PlansEvent {
  const GetPlansEvent();
}

class GetPlanByIdEvent extends PlansEvent {
  final String planId;

  const GetPlanByIdEvent(this.planId);

  @override
  List<Object> get props => [planId];
}

class RefreshPlansEvent extends PlansEvent {
  const RefreshPlansEvent();
}

