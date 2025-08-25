import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/comment.dart';
import '../../../domain/usecases/add_comment_use_case.dart';
import '../../../../../core/utils/network/network_exception.dart';

abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentAddedSuccess extends CommentState {
  final Comment newComment;

  const CommentAddedSuccess({required this.newComment});

  @override
  List<Object?> get props => [newComment];
}

class CommentError extends CommentState {
  final NetworkException failure;

  const CommentError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

@injectable
class CommentCubit extends Cubit<CommentState> {
  final AddCommentUseCase _addCommentUseCase;

  CommentCubit(this._addCommentUseCase) : super(CommentInitial());

  Future<void> addComment(int postId, String content) async {
    emit(CommentLoading());

    final result = await _addCommentUseCase.execute(content, postId);

    result.fold(
          (failure) => emit(CommentError(failure)),
          (newComment) => emit(CommentAddedSuccess(newComment: newComment)),
    );
  }
}