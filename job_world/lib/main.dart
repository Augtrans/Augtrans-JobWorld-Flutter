import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_world/routes/AppRoute.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'ManRope',
          useMaterial3: true
      ),
      routerConfig: appRouter,
    );
  }
}