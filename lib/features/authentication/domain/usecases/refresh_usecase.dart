
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/utils/network/failure.dart';
import '../auth_repository/auth_repository.dart';
import '../entites/response/auth_result.dart';

@injectable
class RefreshTokenUseCase extends BaseUseCase<String, AuthOutcome> {
  final  Repository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, AuthOutcome>> execute(String refreshToken) async {
    return await repository.refreshToken(refreshToken);
  }
}