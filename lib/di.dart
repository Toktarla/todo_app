import 'package:dio/dio.dart';
import 'package:firebasesetup/cubits/task_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubits/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Database
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Local Storage
  sl.registerSingleton<SharedPreferences>(prefs);
  // Dio
  sl.registerSingleton<Dio>(Dio());

  // Cubits
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl())
  );
  sl.registerFactory<TaskCubit>(() => TaskCubit()
  );

}