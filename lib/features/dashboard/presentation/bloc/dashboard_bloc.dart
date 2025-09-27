import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/usecases/get_dashboard_data.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc({required this.getDashboardData}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getDashboardData();

    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (dashboardData) => emit(DashboardLoaded(dashboardData)),
    );
  }
}
