/// Plain English strings used by the default bars; replace through a localization layer later.
abstract final class BarStrings {
  /// Tooltip and screen reader label of the Back control.
  static const String back = 'Back';

  /// Screen reader position hint for tab [index] of [total], both 1-based.
  static String tabPosition(int index, int total) => '$index of $total';

  /// Screen reader text for a badge, given [count].
  static String badge(int count) =>
      count == 1 ? '1 notification' : '$count notifications';
}
