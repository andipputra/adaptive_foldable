/// Which part of the bar gives way first when space runs out.
enum NavCompression {
  /// Actions overflow while the tab bar stays whole.
  navigation,

  /// The tab bar minimizes to one control first, keeping the actions.
  task,
}
