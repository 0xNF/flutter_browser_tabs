import 'package:event_bus/event_bus.dart';

final EventBus eventBus = EventBus();

class EventTabTitleChanged {
  final int tabId;
  final String newTitle;

  const EventTabTitleChanged(this.tabId, this.newTitle);
}
