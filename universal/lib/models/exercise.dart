import 'unique_name.dart';

enum ExerciseRenameError { blank, duplicate }

class Exercise {
  final String id;
  final String name;

  const Exercise({
    required this.id,
    required this.name,
  });

  Exercise copyWith({String? name}) {
    return Exercise(id: id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  static String nameFor(String exerciseId, List<Exercise> exercises) {
    final exercise = exercises.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => Exercise(id: exerciseId, name: 'Unknown Exercise'),
    );
    return exercise.name;
  }

  ExerciseRenameError? validateRename(String newName, List<Exercise> existing) {
    final error = validateUniqueName<Exercise>(
      candidate: newName,
      existing: existing,
      nameOf: (e) => e.name,
      excludeWhere: (e) => e.id == id,
    );
    return switch (error) {
      UniqueNameError.blank => ExerciseRenameError.blank,
      UniqueNameError.duplicate => ExerciseRenameError.duplicate,
      null => null,
    };
  }

  static Exercise? resolve(String name, List<Exercise> existing) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final lowerName = trimmed.toLowerCase();

    for (final exercise in existing) {
      if (exercise.name.toLowerCase() == lowerName) {
        return exercise;
      }
    }

    return Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: trimmed,
    );
  }
}
