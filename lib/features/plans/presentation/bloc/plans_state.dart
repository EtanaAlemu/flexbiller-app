part of 'plans_bloc.dart';

abstract class PlansState extends Equatable {
  const PlansState();

  @override
  List<Object> get props => [];
}

class PlansInitial extends PlansState {}

class PlansLoading extends PlansState {}

class PlansRefreshing extends PlansState {
  final List<Plan> plans;

  const PlansRefreshing(this.plans);

  @override
  List<Object> get props => [plans];
}

class PlansLoaded extends PlansState {
  final List<Plan> plans;

  const PlansLoaded(this.plans);

  @override
  List<Object> get props => [plans];
}

class PlansError extends PlansState {
  final String message;

  const PlansError(this.message);

  @override
  List<Object> get props => [message];
}

class PlanLoading extends PlansState {}

class PlanLoaded extends PlansState {
  final Plan plan;

  const PlanLoaded(this.plan);

  @override
  List<Object> get props => [plan];
}

class PlanError extends PlansState {
  final String message;

  const PlanError(this.message);

  @override
  List<Object> get props => [message];
}

