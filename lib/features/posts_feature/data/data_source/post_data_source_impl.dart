// lib/features/posts/data/data_source/post_data_source_impl.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
 import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/network/api_client.dart';
import '../../../../core/utils/network/connectivity_service.dart';
import '../../../../core/utils/network/failure.dart';
 import '../../../../core/utils/network/network_exception.dart';
import '../../domain/entities/paginated_posts.dart';
import '../models/post_dto/paginated_posts_dto.dart';
import 'contract/post_data_source.dart';

@Injectable(as: PostDataSource)
class PostDataSourceImpl implements PostDataSource {
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  PostDataSourceImpl(this.apiClient, this.connectivityService);

  @override
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize) async {
    if (!(await connectivityService.hasConnection())) {
      return  const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.get(
        '${ApiConstants.posts}?PageNumber=$pageNumber&PageSize=$pageSize',
      );

      if (response.statusCode == 200) {
        final paginatedPostsDto = PaginatedPostsDto.fromJson(response.data);
        return Right(paginatedPostsDto.toDomain());
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return  const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }
}