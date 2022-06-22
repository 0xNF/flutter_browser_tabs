import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_item.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';

class BrowserTab {
  final BrowserTabMetadata metadata;
  final BrowserTabItem child;

  const BrowserTab(this.metadata, this.child);
}
