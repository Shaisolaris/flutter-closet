/// Lightweight, dependency-free unique ID generation for records created in
/// the UI (new items, outfits, and plan entries).
///
/// Combines the current microsecond timestamp with a monotonically
/// increasing in-memory counter so two IDs generated within the same
/// microsecond (possible on fast web/desktop builds) still never collide.
library;

int _counter = 0;

/// Returns a new unique ID, prefixed with [prefix] (e.g. `'item'`, `'outfit'`).
String generateId(String prefix) {
  _counter += 1;
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$timestamp-$_counter';
}
