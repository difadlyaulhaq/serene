import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticated(userCredential.user!));
      } catch (e) {
        emit(AuthError("Login gagal: ${e.toString()}"));
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutRequested>((event, emit) async {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    });
  }
}