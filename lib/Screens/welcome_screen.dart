
import 'package:flutter/material.dart';
import 'chat_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final width = constraints.maxWidth;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Welcome screen background image
              Image.asset(
  'assets/images/welcome_ai.png',
  fit: BoxFit.cover,
),

              // Interactive Get Started button
              Positioned(
                left: width * 0.12,
                right: width * 0.12,
                bottom: height * 0.17,
                height: height * 0.075,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ChatPage(),
                        ),
                      );
                    },
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
