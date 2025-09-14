import 'package:flutter/material.dart';
import 'package:serene/blocs/auth/auth_event.dart';
import 'package:serene/shared/theme.dart';
import 'package:serene/ui/widgets/app_logo.dart';
import 'package:serene/ui/widgets/custom_button.dart';
import 'package:serene/ui/widgets/custom_text_field.dart';
import 'package:serene/ui/widgets/gradient_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:serene/blocs/auth/auth_bloc.dart';
import 'package:serene/blocs/auth/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Gunakan BlocListener untuk menangani "side-effects" seperti navigasi dan snackbar
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Jika login berhasil, navigasi ke halaman chat dan hapus riwayat navigasi sebelumnya
          Navigator.pushNamedAndRemoveUntil(context, '/chatscreen', (route) => false);
        } else if (state is AuthError) {
          // Jika login gagal, tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: GradientBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 30),
                    Text(
                      'Serene',
                      style: headingStyle.copyWith(
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aku di sini kapan pun \nkamu butuh teman.',
                      style: subHeadingStyle.copyWith(
                        color: darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 50),
                    // Gunakan BlocBuilder hanya untuk membangun ulang widget yang perlu berubah
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        // Cek apakah state saat ini adalah AuthLoading
                        bool isLoading = state is AuthLoading;

                        // Perbaikan pada CustomButton
                        return CustomButton(
                          text: 'Login', // Teks tetap ada
                          onPressed: isLoading
                              ? null // Nonaktifkan tombol saat loading
                              : () {
                                  if (_emailController.text.isEmpty ||
                                      _passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Email dan Password harus diisi'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  } else {
                                    // Kirim event LoginRequested ke AuthBloc
                                    context.read<AuthBloc>().add(
                                          LoginRequested(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          ),
                                        );
                                  }
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}