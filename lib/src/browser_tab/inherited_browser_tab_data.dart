import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';
import 'package:flutter_browser_tabs/src/events.dart';
import 'package:nf_flutter_hotkeys/nf_flutter_hotkeys.dart';

class InheritedBrowserTabData extends InheritedWidget {
  final BrowserTabMetadata metadata;
  final TabHotkeys hotkeys;

  const InheritedBrowserTabData({
    super.key,
    required super.child,
    required this.metadata,
    required this.hotkeys,
  });

  static InheritedBrowserTabData of(BuildContext context) {
    final InheritedBrowserTabData? result = context.dependOnInheritedWidgetOfExactType<InheritedBrowserTabData>();
    assert(result != null, 'No BrowserTabDataInherited found in context');
    return result!;
  }

  static InheritedBrowserTabData? maybeOf(BuildContext context) {
    final InheritedBrowserTabData? result = context.dependOnInheritedWidgetOfExactType<InheritedBrowserTabData>();
    return result;
  }

  @override
  bool updateShouldNotify(InheritedBrowserTabData oldWidget) => oldWidget.metadata.tabTitle != metadata.tabTitle;

  /// Changes the title of the tab that this inherited tab data widget represents
  void changeTitle(String newTitle) {
    eventBus.fire(EventTabTitleChanged(metadata.tabId, newTitle));
  }

  /// Sets the title of this tab back to its default state
  void resetTabTitle() {
    changeTitle("Tab ${metadata.tabId}");
  }

  /// Closes all other tabs except this one
  void closeOthers({bool force = false}) {
    eventBus.fire(EventTabCloseAll(force: force));
  }
}
