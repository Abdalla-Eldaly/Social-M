import 'package:equatable/equatable.dart';

abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState {}

class LoadingState extends BaseState {}

class SuccessState<T> extends BaseState {
  final T data;

  const SuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class ErrorState extends BaseState {
  final String errorMessage;

  const ErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}