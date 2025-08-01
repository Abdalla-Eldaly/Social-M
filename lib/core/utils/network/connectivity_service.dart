import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


abstract class ConnectivityService {
  Future<bool> hasConnection();
}

@Injectable(as: ConnectivityService)
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity connectivity;

  ConnectivityServiceImpl(this.connectivity);

  @override
  Future<bool> hasConnection() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}