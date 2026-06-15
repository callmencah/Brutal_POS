import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> login(String username, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    await Future.delayed(const Duration(milliseconds: 500));

    if (username == 'admin' && password == 'admin') {
      emit(AuthState(
        status: AuthStatus.authenticated,
        username: username,
      ));
    } else {
      emit(const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Invalid credentials',
      ));
    }
  }

  void logout() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void checkAuth() {
    emit(state.copyWith(status: AuthStatus.initial));
  }
}

