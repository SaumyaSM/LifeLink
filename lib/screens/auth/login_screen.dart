import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/screens/Auth/password_reset.dart';
import 'package:life_link/screens/Auth/loading_screen.dart';
import 'package:life_link/screens/auth/signup_screen.dart';
import 'package:life_link/screens/main_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/services/toast_service.dart';
import 'package:life_link/widgets/appbar_widget.dart';
import 'package:life_link/widgets/button_widget.dart';
import 'package:life_link/widgets/card_widget.dart';
import 'package:life_link/widgets/font_types.dart';
import 'package:life_link/widgets/google_button_widget.dart';
import 'package:life_link/widgets/loading_widget.dart';
import 'package:life_link/widgets/text_input_widget.dart';
import 'package:life_link/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;

  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  onClickLogin() async {
    if (emailTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(
          context: context, description: 'Email is Missing!');
      return;
    }

    if (passwordTEC.text.trim() == '') {
      ToastService.displayErrorMotionToast(
          context: context, description: 'Password is Missing!');
      return;
    }

    setState(() => isLoading = true);

    await AuthService.loginUser(
            email: emailTEC.text.trim(), password: passwordTEC.text.trim())
        .then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    }).catchError((error) {
      setState(() => isLoading = false);
      ToastService.displayErrorMotionToast(
          context: context, description: 'Invalid Login!');
      return;
    });
  }

  void loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      final UserCredential userCredential =
          await AuthService.loginUserWithGoogle();

      if (userCredential.user == null) {
        throw Exception("Failed to get user information from Google Sign-In");
      }

      if (!mounted) return;

      ToastService.displaySuccessMotionToast(
          context: context, description: 'Login Successful!');

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoadingScreen()));
    } catch (error) {
      print("Google Sign-In Error: $error");

      if (!mounted) return;

      setState(() => isLoading = false);
      ToastService.displayErrorMotionToast(
          context: context,
          description: 'Google Sign-In Failed: ${error.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LoadingWidget(
        inAsyncCall: isLoading,
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    decoration: const BoxDecoration(
                      gradient: kGradientLogin,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(35),
                        topLeft: Radius.circular(35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: kNoHeightAppbarWidget,
              body: LoadingWidget(
                inAsyncCall: isLoading,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.06),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/LifeLink-Logo.PNG',
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                const SizedBox(width: 10),
                Text(
                  'LifeLink',
                  style: FontStyles.headLIneTextFieldStyle(),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: CardWidget(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'LOGIN',
                      style: FontStyles.boldTextFieldStyle(),
                    ),
                    const SizedBox(height: 30),
                    TextInputWidget(
                      controller: emailTEC,
                      title: 'Email',
                      icon: const Icon(Icons.mail_outline),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextInputWidget(
                      controller: passwordTEC,
                      obscureText: true,
                      title: 'Password',
                      icon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPassword())),
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      onTap: () => onClickLogin(),
                      title: 'LOGIN',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'or continue with',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GoogleButtonWidget(
                      onTap: () => loginWithGoogle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignupScreen()));
            },
            child: Column(
              children: [
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignupScreen())),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
