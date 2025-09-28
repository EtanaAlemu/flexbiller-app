import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/plan.dart';
import '../../domain/usecases/get_plans.dart';
import '../../domain/usecases/get_plan_by_id.dart';

part 'plans_event.dart';
part 'plans_state.dart';

@injectable
class PlansBloc extends Bloc<PlansEvent, PlansState> {
  final GetPlans _getPlans;
  final GetPlanById _getPlanById;

  PlansBloc({required GetPlans getPlans, required GetPlanById getPlanById})
    : _getPlans = getPlans,
      _getPlanById = getPlanById,
      super(PlansInitial()) {
    on<GetPlansEvent>(_onGetPlans);
    on<GetPlanByIdEvent>(_onGetPlanById);
    on<RefreshPlansEvent>(_onRefreshPlans);
  }

  Future<void> _onGetPlans(
    GetPlansEvent event,
    Emitter<PlansState> emit,
  ) async {
    emit(PlansLoading());

    final result = await _getPlans();

    result.fold(
      (failure) => emit(PlansError(failure.message)),
      (plans) => emit(PlansLoaded(plans)),
    );
  }

  Future<void> _onGetPlanById(
    GetPlanByIdEvent event,
    Emitter<PlansState> emit,
  ) async {
    emit(PlanLoading());

    final result = await _getPlanById(event.planId);

    result.fold(
      (failure) => emit(PlanError(failure.message)),
      (plan) => emit(PlanLoaded(plan)),
    );
  }

  Future<void> _onRefreshPlans(
    RefreshPlansEvent event,
    Emitter<PlansState> emit,
  ) async {
    if (state is PlansLoaded) {
      emit(PlansRefreshing((state as PlansLoaded).plans));
    } else {
      emit(PlansLoading());
    }

    final result = await _getPlans();

    result.fold(
      (failure) => emit(PlansError(failure.message)),
      (plans) => emit(PlansLoaded(plans)),
    );
  }
}

