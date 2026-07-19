enum UniqueNameError { blank, duplicate }

/// Blank/duplicate validation shared by every model that enforces
/// case-insensitive unique names (e.g. [Exercise], [Routine]).
UniqueNameError? validateUniqueName<T>({
  required String candidate,
  required Iterable<T> existing,
  required String Function(T item) nameOf,
  bool Function(T item)? excludeWhere,
}) {
  final trimmed = candidate.trim();
  if (trimmed.isEmpty) {
    return UniqueNameError.blank;
  }

  final lowerTrimmed = trimmed.toLowerCase();
  final collides = existing.any(
    (item) =>
        (excludeWhere == null || !excludeWhere(item)) &&
        nameOf(item).toLowerCase() == lowerTrimmed,
  );
  if (collides) {
    return UniqueNameError.duplicate;
  }

  return null;
}
