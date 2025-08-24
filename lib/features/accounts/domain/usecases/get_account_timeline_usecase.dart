import 'package:injectable/injectable.dart';
import '../entities/account_timeline.dart';
import '../repositories/account_timeline_repository.dart';

@injectable
class GetAccountTimelineUseCase {
  final AccountTimelineRepository _timelineRepository;

  GetAccountTimelineUseCase(this._timelineRepository);

  Future<AccountTimeline> call(String accountId) async {
    return await _timelineRepository.getAccountTimeline(accountId);
  }
}
