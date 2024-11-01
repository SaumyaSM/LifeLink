import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  bool inAsyncCall;
  Widget child;

  LoadingWidget({
    Key? key,
    this.inAsyncCall = true,
    this.child = const SizedBox(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return ModalProgressHUD(
    //   inAsyncCall: inAsyncCall,
    //   color: kColorGold,
    //   opacity: 0.0,
    //   //progressIndicator: Lottie.asset('assets/images/nsbm.json'),
    //   // progressIndicator: LoadingAnimationWidget.inkDrop(
    //   //   color: k_color_green,
    //   //   size: 40,
    //   // ),
    //   progressIndicator: LoadingAnimationWidget.staggeredDotsWave(
    //     color: kColorGold,
    //     size: 50,
    //   ),
    //   child: child,
    // );
    return inAsyncCall
        ? Center(
            child: CircularProgressIndicator(),
          )
        : child;
  }
}
