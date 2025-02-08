import 'package:ezpc_tasks_app/features/auth/presentation/screens/register/bank_acount.dart';
import 'package:ezpc_tasks_app/features/checkr/screens/welcomebackground.dart';
import 'package:ezpc_tasks_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-bank',
      builder: (context, state) => const AddBankAccountPage(),
    ),
    GoRoute(
      path: '/create-candidate',
      builder: (context, state) => const WelcomeBackgroundCheckScreen(),
    ),
  ],
);
