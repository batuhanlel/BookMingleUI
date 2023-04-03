import 'package:book_mingle_ui/component/rounded_button.dart';
import 'package:book_mingle_ui/screens/onboarding/login_screen.dart';
import 'package:book_mingle_ui/screens/onboarding/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
      height: size.height,
      width: double.infinity,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  textAlign: TextAlign.center,
                  "Welcome to \nThe Book Mingle",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: size.width * 0.08,
                  ),
                ),
                SizedBox(height: size.height * 0.07),
                SvgPicture.asset(
                  "assets/icons/education_reading_library_knowledge_learn_icon.svg",
                  height: size.height * 0.35,
                ),
                RoundedButton(
                  text: "LOGIN",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const LoginScreen();
                        },
                      ),
                    );
                  },
                ),
                RoundedButton(
                  text: "SIGNUP",
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return const SignUpScreen();
                        },
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    ),
    );
  }
}
