import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

sealed class TabEvent {
  const TabEvent();
}

/// Sent when program requests a tab name change programatically
final class EventTabTitleChanged extends TabEvent {
  /// Tab Id to change
  final int tabId;

  /// Title to change the tab to
  final String newTitle;

  const EventTabTitleChanged(this.tabId, this.newTitle);
}

/// Sent when program requests closing a specific tab programatically
///
/// Respects `atLeastOneTab`, unless `force` is true
final class EventTabCloseTab extends TabEvent {
  /// Tab Id to close
  final int tabId;

  /// If `true`, will force the tab to close, even if it would fail certain UX checks otherwise
  final bool force;

  const EventTabCloseTab({
    required this.tabId,
    this.force = false,
  });
}

/// Sent when program requests closing all tabs programatically
///
/// Respects `atLeastOneTab`, unless `force` is true
final class EventTabCloseAll extends TabEvent {
  /// If `true`, will force the tab to close, even if it would fail certain UX checks otherwise
  final bool force;

  const EventTabCloseAll({this.force = false});
}

/// Sent when program requests a new tab programatically
final class EventTabOpened extends TabEvent {
  /// Name to assign to the tab. If left blank, Tab Manager will choose a name automatically
  final String? tabName;
  const EventTabOpened({this.tabName});
}
