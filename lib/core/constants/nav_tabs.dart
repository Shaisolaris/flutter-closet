/// Bottom navigation tab indices, shared between the root shell and any
/// screen that needs to programmatically switch tabs (e.g. an empty state's
/// "Build an outfit" action jumping from Outfits to... itself, or Plan
/// jumping to Wardrobe when there's nothing to assign yet).
abstract final class NavTab {
  static const int wardrobe = 0;
  static const int outfits = 1;
  static const int plan = 2;
  static const int stats = 3;
}
