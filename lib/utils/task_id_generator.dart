class TaskIDGenerator {
  static int _counter = 0;

  static int generateTaskID() {
    return _counter++;
  }
}