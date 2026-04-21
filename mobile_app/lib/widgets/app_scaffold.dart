import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final Widget? bottomBar;

  const AppScaffold({
    super.key,
    required this.child,
    this.bottomBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0E6D9),
                Color(0xFFE8D6BF),
                Color(0xFFEADFCF),
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: child,
                ),
              ),
              if (bottomBar != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: bottomBar,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
