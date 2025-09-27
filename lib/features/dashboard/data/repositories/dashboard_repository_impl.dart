import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      final dashboardData = await localDataSource.getDashboardData();
      return Right(dashboardData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountChartData>>> getAccountChartData() async {
    try {
      final chartData = await localDataSource.getAccountChartData();
      return Right(chartData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SubscriptionChartData>>>
  getSubscriptionChartData() async {
    try {
      final chartData = await localDataSource.getSubscriptionChartData();
      return Right(chartData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RevenueChartData>>> getRevenueChartData() async {
    try {
      final chartData = await localDataSource.getRevenueChartData();
      return Right(chartData);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
