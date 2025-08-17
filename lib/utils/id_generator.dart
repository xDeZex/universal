class IdGenerator {
  static int _idCounter = 0;

  static String generateUniqueId() {
    _idCounter++;
    return '${DateTime.now().millisecondsSinceEpoch}_$_idCounter';
  }
}