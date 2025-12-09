import 'package:flutter/material.dart';

import '../widgets/sign_in_view_body.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

  static const routeName = "signInView";

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
        body: SafeArea(child: SignInViewBody()));
  }
}
