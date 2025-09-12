import 'package:flutter/material.dart';
import 'package:serene/shared/theme.dart';
import 'package:serene/ui/widgets/app_logo.dart';
import 'package:serene/ui/widgets/custom_button.dart';
import 'package:serene/ui/widgets/custom_text_field.dart';
import 'package:serene/ui/widgets/gradient_background.dart';

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
    return Scaffold(
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
                  CustomButton(
                    text: 'Login',
                    onPressed: () {
                      Navigator.pushNamed(context, '/chatscreen');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}