import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasesetup/cubits/theme_cubit.dart';
import 'package:firebasesetup/screens/home_page.dart';
import 'package:firebasesetup/screens/auth/login_page.dart';
import 'package:firebasesetup/firebase/firebase_options.dart';
import 'package:firebasesetup/screens/settings/manage_account_page.dart';
import 'package:firebasesetup/screens/todo_pages/my_day_page.dart';
import 'package:firebasesetup/screens/auth/register_page.dart';
import 'package:firebasesetup/screens/settings/settings_page.dart';
import 'package:firebasesetup/screens/todo_pages/user_task_page.dart';
import 'package:firebasesetup/screens/auth/verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'cubits/task_cubit.dart';
import 'di.dart';


final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) {
          return StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const VerifyEmailPage();
              }
              else {
                return const LoginPage();
              }
            },

          );
        }
    ),
    GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        }
    ),
    GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          return const VerifyEmailPage();
        }
    ),
    GoRoute(
        path: '/register',
        builder: (context, state) {
          return const RegisterPage();
        }
    ),
    GoRoute(
        path: '/homepage',
        builder: (context, state) {
          return const HomePage();
        }
    ),

    GoRoute(
        path: '/manage-account',
        builder: (context, state) {
          return const ManageAccountPage();
        }
    ),
    GoRoute(
        path: '/settings',
        builder: (context, state) {
          return const SettingsPage();
        }
    ),
    GoRoute(
        path: '/myday',
        builder: (context, state) {
          var data = state.extra as Map<String,dynamic>;
          return MyDayPage(
            title: data['title'],
            todayDate: data['todayDate'],
            userUid: data['userUid'],
          );
        }
    ),
    GoRoute(
        path: '/user-task',
        builder: (context, state) {
          var data = state.extra as Map<String,dynamic>;
          return UserTaskPage(
            title: data['title'],
            taskId: data['taskId'],
          );
        }
    ),


  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
            create: (_) => sl()..loadTheme()
        ),
        BlocProvider<TaskCubit>(
            create: (_) => sl()
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, theme) {
          return MaterialApp.router(
              routerConfig: goRouter,
              title: 'Firebase',
              debugShowCheckedModeBanner: false,
              theme: theme
          );
        },
      ),
    );
  }
}

