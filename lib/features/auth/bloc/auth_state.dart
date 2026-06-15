import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final String? username;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.username,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? username,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, username];
}

