/// Case-insensitive alphabetical sort by name, shared by every screen that
/// lists [Exercise]-/[Routine]-like items in name order.
List<T> sortByName<T>(List<T> items, String Function(T item) nameOf) {
  final sorted = [...items];
  sorted.sort(
    (a, b) => nameOf(a).toLowerCase().compareTo(nameOf(b).toLowerCase()),
  );
  return sorted;
}
