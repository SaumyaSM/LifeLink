import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:life_link/constants/colors.dart';
import 'package:life_link/models/user_model.dart';
import 'package:life_link/screens/Auth/login_screen.dart';
import 'package:life_link/screens/account/personal_info_form_screen.dart';
import 'package:life_link/screens/account/start_screen.dart';
import 'package:life_link/services/auth_service.dart';
import 'package:life_link/services/toast_service.dart';
import 'package:life_link/services/user_service.dart';
import 'package:life_link/widgets/appbar_widget.dart';
import 'package:life_link/widgets/button_widget.dart';
import 'package:life_link/widgets/card_widget.dart';
import 'package:life_link/widgets/font_types.dart';
import 'package:life_link/widgets/google_button_widget.dart';
import 'package:life_link/widgets/loading_widget.dart';
import 'package:life_link/widgets/text_input_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isLoading = false;

  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  TextEditingController passwordConfirmTEC = TextEditingController();

  void validateForm() {
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailTEC.text.trim())) {
      ToastService.displayErrorMotionToast(
          context: context, description: 'Invalid Email!');
      return;
    }

    if (passwordTEC.text.trim().length < 6) {
      ToastService.displayErrorMotionToast(
          context: context, description: 'Password is too short!');
      return;
    }

    if (passwordTEC.text.trim() != passwordConfirmTEC.text.trim()) {
      ToastService.displayErrorMotionToast(
          context: context, description: 'Passwords dont match!');
      return;
    }

    signup();
  }

  void signup() async {
    setState(() => isLoading = true);

    await AuthService.signupUser(
      email: emailTEC.text.trim(),
      password: passwordTEC.text.trim(),
    ).then((UserCredential user) async {
      UserModel userModel = UserModel(
        id: user.user!.uid,
        fullName: '',
        dateOfBirth: '',
        gender: '',
        nic: '',
        contact: '',
        address: '',
        isDonor: true,
        bloodType: '',
        organType: '',
        isTestsCompleted: false,
        likes: [],
        history: [],
        city: '',
        hlaTyping: {},
        waitingTime: 0,
        imageUrl: '',
      );

      await UserService.createUser(userModel).then((value) {
        ToastService.displaySuccessMotionToast(
            context: context, description: 'SignUp Successful!');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StartScreen(userModel: userModel)));
      }).catchError((error) {
        setState(() => isLoading = false);
        ToastService.displayErrorMotionToast(
            context: context, description: 'Cannot Create User!');
      });
    }).catchError((error) {
      setState(() => isLoading = false);
      ToastService.displayErrorMotionToast(
          context: context, description: 'Cannot Create User!');
    });

    if (!mounted) return;
  }

  void signupWithGoogle() async {
    setState(() => isLoading = true);

    await AuthService.signupUserWithGoogle().then((UserCredential user) async {
      UserModel userModel = UserModel(
        id: user.user!.uid,
        fullName: '',
        dateOfBirth: '',
        gender: '',
        nic: '',
        contact: '',
        address: '',
        isDonor: true,
        bloodType: '',
        organType: '',
        isTestsCompleted: false,
        likes: [],
        history: [],
        city: '',
        hlaTyping: {},
        waitingTime: 0,
        imageUrl: '',
      );

      await UserService.createUser(userModel).then((value) {
        ToastService.displaySuccessMotionToast(
            context: context, description: 'SignUp Successful!');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StartScreen(userModel: userModel)));
      }).catchError((error) {
        setState(() => isLoading = false);
        ToastService.displayErrorMotionToast(
            context: context, description: 'Cannot Create User!');
      });
    }).catchError((error) {
      setState(() => isLoading = false);
      ToastService.displayErrorMotionToast(
          context: context, description: 'Cannot SignUp with Google!');
    });
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
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
                      'SIGN UP',
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
                    const SizedBox(height: 20),
                    TextInputWidget(
                      controller: passwordConfirmTEC,
                      obscureText: true,
                      title: 'Confirm Password',
                      icon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 20),
                    ButtonWidget(
                      onTap: () => validateForm(),
                      title: 'SIGN UP',
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
                      onTap: () => signupWithGoogle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Column(
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen())),
                  child: const Text(
                    'Log In',
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
