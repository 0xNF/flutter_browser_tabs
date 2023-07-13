import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';
import 'package:nf_flutter_hotkeys/nf_hotkeys.dart';

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
    assert(result != null, 'No TabDataInherited found in context');
    return result!;
  }

  static BrowserTabDataInherited? maybeOf(BuildContext context) {
    final BrowserTabDataInherited? result = context.dependOnInheritedWidgetOfExactType<BrowserTabDataInherited>();
    return result;
  }

  @override
  bool updateShouldNotify(BrowserTabDataInherited oldWidget) => oldWidget.metadata.tabTitle != metadata.tabTitle;
}
