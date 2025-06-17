class ExerciseLogService {
  static const String _exerciseKey = 'my_exercises';

  // Singleton pattern
  static final ExerciseLogService _instance = ExerciseLogService._internal();
  factory ExerciseLogService() => _instance;
  ExerciseLogService._internal();

  List<Map<String, dynamic>> exerciseLog = [];

  double getTotalBurned() {
    double burned = 0;
    for (var ex in exerciseLog) {
      burned += (ex['calories'] ?? 0) is num ? ex['calories'] : double.tryParse(ex['calories'].toString()) ?? 0;
    }
    return burned;
  }
}
