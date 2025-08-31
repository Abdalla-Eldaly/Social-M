import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:social_m_app/features/posts_feature/data/models/post_dto/user_dto.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/network/api_client.dart';
import '../../../../core/utils/network/connectivity_service.dart';
 import '../../../../core/utils/network/network_exception.dart';
import '../../domain/entities/paginated_posts.dart';
import '../models/post_dto/comment_dto.dart';
import '../models/post_dto/paginated_posts_dto.dart';
import '../models/post_dto/post_dto.dart';
import 'contract/post_data_source.dart';

@Injectable(as: PostDataSource)
class PostDataSourceImpl implements PostDataSource {
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  PostDataSourceImpl(this.apiClient, this.connectivityService);

  @override
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
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
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }

  @override
  Future<Either<NetworkException, List<PostDto>>> getUserPosts(int userId) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.get(
        '${ApiConstants.posts}/user/$userId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> postsJson = response.data;
        final List<PostDto> posts = postsJson
            .map((json) => PostDto.fromJson(json))
            .toList();
        return Right(posts);
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }
  @override
  Future<Either<NetworkException, CommentDto>> addComment(String comment, int postId) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.post(
        '${ApiConstants.posts}/$postId/comments',
        data: {'content': comment},
      );

      if (response.statusCode == 201) {
        final commentDto = CommentDto.fromJson(response.data);
        return Right(commentDto);
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }

  @override
  Future<Either<NetworkException, UserDto>> getUserInfo() async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.get(
        '${ApiConstants.user}/me',
      );

      if (response.statusCode == 200) {
        final userDto = UserDto.fromJson(response.data);
        return Right(userDto);
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }


  @override
  Future<Either<NetworkException, List<UserDto>>> getUserFollowers(int userId) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.get(
        '${ApiConstants.user}/$userId/followers',
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data;
        final List<UserDto> users = usersJson
            .map((json) => UserDto.fromJson(json))
            .toList();
        return Right(users);
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }

  @override
  Future<Either<NetworkException, List<UserDto>>> getUserFollowing(int userId) async {
    if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiClient.get(
        '${ApiConstants.user}/$userId/following',
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data;
        final List<UserDto> users = usersJson
            .map((json) => UserDto.fromJson(json))
            .toList();
        return Right(users);
      } else {
        return Left(NetworkException(
          message: response.data is String
              ? response.data
              : response.data['title'] ?? 'Unknown error',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        return const Left(NetworkException(
          message: 'No internet connection. Please check your network.',
        ));
      }
      return Left(NetworkException(
        message: 'Network error: ${e.message ?? 'Unknown error'}',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }

}