import 'package:book_mingle_ui/component/already_have_account_check.dart';
import 'package:book_mingle_ui/component/rounded_button.dart';
import 'package:book_mingle_ui/component/rounded_input_field.dart';
import 'package:book_mingle_ui/component/rounded_password_field.dart';
import 'package:book_mingle_ui/models/login_model.dart';
import 'package:book_mingle_ui/screens/main/naviqation.dart';
import 'package:book_mingle_ui/screens/onboarding/signup_screen.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool hidePassword = true;
  late LoginRequestModel requestModel;
  late Map<String, dynamic> _errors;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    requestModel = LoginRequestModel();
    _errors = {};
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.08,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      RoundedInputField(
                        errorText:
                            _errors.containsKey('email') ? _errors['email'] : null,
                        hintText: "Your Email",
                        onSaved: (value) => requestModel.email = value?.trim(),
                      ),
                      RoundedPasswordField(
                        errorText: _errors.containsKey('password')
                            ? _errors['password']
                            : null,
                        onSaved: (value) => requestModel.password = value?.trim(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        obscureText: hidePassword ? true : false,
                      ),
                      SizedBox(height: size.height * 0.02),
                      RoundedButton(
                        text: "Login",
                        press: _handleLogin,
                      ),
                      AlreadyHaveAnAccountCheck(
                        login: true,
                        press: _navigateToSignUpScreen,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    _formKey.currentState?.save();
    print(requestModel.toJson());
    ApiService.login(requestModel).then((loginResponse) async {
      if (loginResponse.token.isNotEmpty) {
        await storage.write(key: 'token', value: loginResponse.token);

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
        String? token = await storage.read(key: 'token');
        print("current key ${token!}");
        showFormValidationErrorMessages(loginResponse.errors);
        showBadCredentialsErrorMessages(loginResponse.error.toString());
      }
    });
  }

  void showFormValidationErrorMessages(Map<String, dynamic> errors) {
    if (errors.isNotEmpty) {
      setState(() {
        _errors = errors;
        _formKey.currentState?.reset();
      });
    }
  }

  void showBadCredentialsErrorMessages(String message) {
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToSignUpScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const SignUpScreen();
        },
      ),
    );
  }
}
