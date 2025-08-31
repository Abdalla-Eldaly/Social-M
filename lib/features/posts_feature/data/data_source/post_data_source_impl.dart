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
import '../models/post_dto/create_post_dto.dart';
import '../models/post_dto/paginated_posts_dto.dart';
import '../models/post_dto/post_dto.dart';
import 'contract/post_data_source.dart';

@Injectable(as: PostDataSource)
class PostDataSourceImpl implements PostDataSource {
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  PostDataSourceImpl(this.apiClient, this.connectivityService);

   Future<Either<NetworkException, T>> _handleApiCall<T>(
      Future<Response> Function() apiCall,
      T Function(dynamic data) onSuccess,
      {int expectedStatusCode = 200}
      ) async {
     if (!(await connectivityService.hasConnection())) {
      return const Left(NetworkException(
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await apiCall();

      if (response.statusCode == expectedStatusCode) {
        return Right(onSuccess(response.data));
      } else {
        return Left(_createNetworkExceptionFromResponse(response));
      }
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(NetworkException(
        message: 'Unexpected error: $e',
      ));
    }
  }

   NetworkException _createNetworkExceptionFromResponse(Response response) {
    final data = response.data;

     if (data is Map<String, dynamic>) {
       Map<String, List<String>>? validationErrors;
      if (data.containsKey('errors') && data['errors'] is Map<String, dynamic>) {
        final errors = data['errors'] as Map<String, dynamic>;
        validationErrors = <String, List<String>>{};

        errors.forEach((field, fieldErrors) {
          if (fieldErrors is List) {
            validationErrors![field] = fieldErrors.map((e) => e.toString()).toList();
          } else if (fieldErrors is String) {
            validationErrors![field] = [fieldErrors];
          }
        });
      }

       String message = 'Unknown error';
      if (data.containsKey('title') && data['title'] is String) {
        final title = data['title'] as String;
        if (title.isNotEmpty && title != 'One or more validation errors occurred.') {
          message = title;
        } else if (validationErrors != null && validationErrors.isNotEmpty) {
           final errorMessages = <String>[];
          validationErrors.forEach((field, errors) {
            errorMessages.addAll(errors.map((error) => '$field: $error'));
          });
          message = 'Validation failed:\n${errorMessages.join('\n')}';
        }
      } else if (data.containsKey('message') && data['message'] is String) {
        message = data['message'];
      } else if (data.containsKey('error') && data['error'] is String) {
        message = data['error'];
      }

      return NetworkException(
        message: message,
        statusCode: response.statusCode,
        validationErrors: validationErrors,
        traceId: data['traceId'] as String?,
      );
    } else if (data is String && data.isNotEmpty) {
      return NetworkException(
        message: data,
        statusCode: response.statusCode,
      );
    }

    return NetworkException(
      message: 'HTTP ${response.statusCode}: Unknown error',
      statusCode: response.statusCode,
    );
  }

  NetworkException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: 'No internet connection. Please check your network.',
      );
    }

    return NetworkException.fromDioError(e);
  }

  @override
  Future<Either<NetworkException, PaginatedPosts>> getPosts(int pageNumber, int pageSize) async {
    return _handleApiCall(
          () => apiClient.get('${ApiConstants.posts}?PageNumber=$pageNumber&PageSize=$pageSize'),
          (data) => PaginatedPostsDto.fromJson(data).toDomain(),
    );
  }

  @override
  Future<Either<NetworkException, List<PostDto>>> getUserPosts(int userId) async {
    return _handleApiCall(
          () => apiClient.get('${ApiConstants.posts}/user/$userId'),
          (data) {
        final List<dynamic> postsJson = data;
        return postsJson.map((json) => PostDto.fromJson(json)).toList();
      },
    );
  }

  @override
  Future<Either<NetworkException, CommentDto>> addComment(String comment, int postId) async {
    return _handleApiCall(
          () => apiClient.post(
        '${ApiConstants.posts}/$postId/comments',
        data: {'content': comment},
      ),
          (data) => CommentDto.fromJson(data),
      expectedStatusCode: 201,
    );
  }

  @override
  Future<Either<NetworkException, UserDto>> getUserInfo() async {
    return _handleApiCall(
          () => apiClient.get('${ApiConstants.user}/me'),
          (data) => UserDto.fromJson(data),
    );
  }

  @override
  Future<Either<NetworkException, List<UserDto>>> getUserFollowers(int userId) async {
    return _handleApiCall(
          () => apiClient.get('${ApiConstants.user}/$userId/followers'),
          (data) {
        final List<dynamic> usersJson = data;
        return usersJson.map((json) => UserDto.fromJson(json)).toList();
      },
    );
  }

  @override
  Future<Either<NetworkException, PostDto>> createPost(CreatePostDto createPostDto) async {
    return _handleApiCall(
          () async {
        final formData = FormData.fromMap({
          ...createPostDto.toJson(),
          'ImageFile': await createPostDto.getImageMultipart(),
        });
        return apiClient.post(ApiConstants.posts, data: formData);
      },
          (data) => PostDto.fromJson(data),
      expectedStatusCode: 201,
    );
  }

  @override
  Future<Either<NetworkException, List<UserDto>>> getUserFollowing(int userId) async {
    return _handleApiCall(
          () => apiClient.get('${ApiConstants.user}/$userId/following'),
          (data) {
        final List<dynamic> usersJson = data;
        return usersJson.map((json) => UserDto.fromJson(json)).toList();
      },
    );
  }
}