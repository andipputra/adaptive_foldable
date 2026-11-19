import 'package:flutter/foundation.dart';

/// Registered metadata for one pane in a multi-pane layout.
class NavPaneEntry {
  /// Creates an entry for [paneId].
  const NavPaneEntry({
    required this.paneId,
    this.isPrimary = false,
    this.order = 0,
  });

  /// Unique identifier of this pane.
  final String paneId;

  /// Whether this pane is considered the primary pane.
  final bool isPrimary;

  /// Display or spatial order of the pane (e.g. 0 for start, 1 for end).
  final int order;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavPaneEntry &&
          runtimeType == other.runtimeType &&
          paneId == other.paneId &&
          isPrimary == other.isPrimary &&
          order == other.order;

  @override
  int get hashCode => Object.hash(paneId, isPrimary, order);
}

/// Tracks the active panes in a multi-pane layout.
///
/// Coordinates with layout containers (such as `FoldAwareTwoPane`) and
/// `NavActionRegistry` to map published actions to specific active panes.
class NavPaneRegistry extends ChangeNotifier {
  final Map<String, NavPaneEntry> _panes = {};

  /// All currently registered pane entries in order.
  List<NavPaneEntry> get panes {
    final list = _panes.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return List.unmodifiable(list);
  }

  /// All active pane IDs in display order.
  List<String> get activePaneIds => panes.map((p) => p.paneId).toList();

  /// Whether [paneId] is currently registered.
  bool hasPane(String paneId) => _panes.containsKey(paneId);

  /// Returns the entry for [paneId], or null if not registered.
  NavPaneEntry? entryFor(String paneId) => _panes[paneId];

  /// Whether [paneId] is marked as the primary pane.
  bool isPrimary(String paneId) => _panes[paneId]?.isPrimary ?? false;

  /// Returns the pane ID of the primary pane, or null if none is marked primary.
  String? get primaryPaneId {
    for (final entry in panes) {
      if (entry.isPrimary) return entry.paneId;
    }
    return null;
  }

  /// Registers [entry]. Replaces any existing registration for the same pane ID.
  void register(NavPaneEntry entry) {
    final existing = _panes[entry.paneId];
    if (existing == entry) return;
    _panes[entry.paneId] = entry;
    notifyListeners();
  }

  /// Convenience method to register a pane by [paneId].
  void registerPane(String paneId, {bool isPrimary = false, int order = 0}) {
    register(NavPaneEntry(paneId: paneId, isPrimary: isPrimary, order: order));
  }

  /// Unregisters the pane with [paneId].
  void unregister(String paneId) {
    if (_panes.remove(paneId) != null) {
      notifyListeners();
    }
  }

  /// Clears all registered panes.
  void clear() {
    if (_panes.isEmpty) return;
    _panes.clear();
    notifyListeners();
  }
}
