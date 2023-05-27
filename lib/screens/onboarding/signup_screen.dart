import 'package:book_mingle_ui/component/already_have_account_check.dart';
import 'package:book_mingle_ui/component/rounded_button.dart';
import 'package:book_mingle_ui/component/rounded_input_field.dart';
import 'package:book_mingle_ui/component/rounded_password_field.dart';
import 'package:book_mingle_ui/models/signup_model.dart';
import 'package:book_mingle_ui/screens/main/naviqation.dart';
import 'package:book_mingle_ui/screens/onboarding/login_screen.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  late SignUpRequestModel requestModel;
  late Map<String, dynamic> _errors;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    requestModel = SignUpRequestModel();
    _errors = {};
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: double.infinity,
          child: Stack(alignment: Alignment.center, children: <Widget>[
            SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Let's Start",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.08,
                      ),
                    ),
                    RoundedInputField(
                      errorText: _errors.containsKey('name') ? _errors['name'] : null,
                      hintText: "Name",
                      onSaved: (value) => requestModel.name = value?.trim(),
                    ),
                    RoundedInputField(
                      errorText: _errors.containsKey('surname') ? _errors['surname'] : null,
                      hintText: "Surname",
                      onSaved: (value) => requestModel.surname = value?.trim(),
                    ),
                    RoundedInputField(
                      errorText: _errors.containsKey('phoneNumber') ? _errors['phoneNumber'] : null,
                      hintText: "Phone Number",
                      iconData: Icons.phone,
                      onSaved: (value) => requestModel.phoneNumber = value?.trim(),
                    ),
                    RoundedInputField(
                      errorText: _errors.containsKey('email') ? _errors['email'] : null,
                      hintText: "Email",
                      iconData: Icons.email,
                      onSaved: (value) => requestModel.email = value?.trim(),
                    ),
                    RoundedPasswordField(
                      errorText: _errors.containsKey('password') ? _errors['password'] : null,
                      onSaved: (value) => requestModel.password = value?.trim(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(hidePassword ? Icons.visibility : Icons.visibility_off),
                      ),
                      obscureText: hidePassword ? true : false,
                    ),
                    RoundedButton(
                      text: "Sign Up",
                      press: _handleSignUp,
                    ),
                    AlreadyHaveAnAccountCheck(
                      login: false,
                      press: _navigateToLoginScreen,
                    )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    _formKey.currentState!.save();
    print(requestModel.toJson());
    ApiService.signup(requestModel).then((response) async {
      if (response.token.isNotEmpty) {
        await storage.write(key: 'token', value: response.token);

        ApiService.userAbout().then((userAboutResponse) async {
          await storage.write(key: 'userId', value: userAboutResponse.id.toString());
          await storage.write(key: 'name', value: userAboutResponse.name);
          await storage.write(key: 'surname', value: userAboutResponse.surname);
          await storage.write(key: 'email', value: userAboutResponse.email);
        });

        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const Naviqation(),
          ),
        );
      } else {
        print(response.errors);
        setState(() {
          _errors = response.errors;
          _formKey.currentState?.reset();
        });
      }
    });
  }

  void _navigateToLoginScreen() {
    _formKey.currentState!.reset();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }
}
