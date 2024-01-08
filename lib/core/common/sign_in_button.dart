import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/theme/pallete.dart';

class SignInButton extends ConsumerStatefulWidget {
  final bool isFromLogin;
  const SignInButton({super.key, this.isFromLogin = true});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInButtonState();
}

class _SignInButtonState extends ConsumerState<SignInButton> {

  void signInWithGoogle(BuildContext context) {
    setState(() {
      ref.read(authControllerProvider.notifier).signInWithGoogle(context, widget.isFromLogin);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context),
        icon: Image.asset(Constants.googlePath, width: 35,), 
        label: Text(
          'Continue with google', 
          style: TextStyle(
            fontSize: 18,
            color: currentTheme == Pallete.darkModeAppTheme
                   ? Colors.white
                   : Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: currentTheme == Pallete.darkModeAppTheme
                          ? Pallete.greyColor
                          : Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }
}