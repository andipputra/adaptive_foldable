/// Where a page's actions are shown when the layout has several panes.
enum NavActionPlacement {
  /// The scaffold picks the pane touching the bar edge.
  auto,

  /// Always in the navigation column.
  column,

  /// Always in the pane's own header bar.
  paneHeader,
}
