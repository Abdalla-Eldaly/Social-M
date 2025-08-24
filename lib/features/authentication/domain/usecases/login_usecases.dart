
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/utils/network/failure.dart';
import '../auth_repository/auth_repository.dart';
import '../entites/response/auth_result.dart';

@injectable
class LoginUseCase extends BaseUseCase<(String, String), AuthOutcome> {
  final  Repository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, AuthOutcome>> execute((String, String) input) async {
    return await repository.login(input.$1, input.$2);
  }
}