import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Center(
          child: Lottie.asset(
            'assets/animations/loading.json',
            reverse: true,
            repeat: true,
            height: 100,
            width: 100,
          ),
        ),
      ),
    );
  }
}
