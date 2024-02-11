import 'package:flutter_bloc/flutter_bloc.dart';

class TaskCubit extends Cubit<bool> {
  TaskCubit() : super(false);

  void changeDefaultTaskListsCreated() {
    emit(true);
  }
}