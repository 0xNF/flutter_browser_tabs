import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';
import 'package:nf_flutter_hotkeys/nf_hotkeys.dart';
import 'package:flutter_browser_tabs/src/events.dart';

class BrowserTabDataInherited extends InheritedWidget {
  final BrowserTabMetadata metadata;
  final TabHotkeys hotkeys;

  const BrowserTabDataInherited({
    super.key,
    required super.child,
    required this.metadata,
    required this.hotkeys,
  });

  static BrowserTabDataInherited of(BuildContext context) {
    final BrowserTabDataInherited? result = context.dependOnInheritedWidgetOfExactType<BrowserTabDataInherited>();
    assert(result != null, 'No BrowserTabDataInherited found in context');
    return result!;
  }

  static BrowserTabDataInherited? maybeOf(BuildContext context) {
    final BrowserTabDataInherited? result = context.dependOnInheritedWidgetOfExactType<BrowserTabDataInherited>();
    return result;
  }

  @override
  bool updateShouldNotify(BrowserTabDataInherited oldWidget) => oldWidget.metadata.tabTitle != metadata.tabTitle;

  /// Changes the title of the tab that this inherited tab data widget represents
  void changeTitle(String newTitle) {
    eventBus.fire(EventTabTitleChanged(metadata.tabId, newTitle));
  }

  /// Sets the title of this tab back to its default state
  void resetTabTitle() {
    changeTitle("Tab ${metadata.tabId}");
  }
}
