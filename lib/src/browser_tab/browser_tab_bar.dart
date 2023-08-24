import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_title.dart';
import 'package:flutter_browser_tabs/src/browser_tab/inherited_browser_tab_data.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';
import 'package:nf_flutter_hotkeys/nf_hotkeys.dart';

class BrowserTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<BrowserTab> tabs;
  final TabHotkeys tabHotkeys;
  final Color? rowColor;
  final Color? iconColor;
  final void Function(BrowserTabMetadata metadata) onTabClose;
  final void Function(int tabId) onShowTabById;
  final void Function(int tabIndex) onShowTabByIndex;
  final void Function() onAddTab;

  const BrowserTabBar({
    super.key,
    this.rowColor,
    this.iconColor,
    required this.tabController,
    required this.tabs,
    required this.tabHotkeys,
    required this.onTabClose,
    required this.onShowTabById,
    required this.onShowTabByIndex,
    required this.onAddTab,
  });

  /// Generates the List of available tabs when the user clicks the List Tabs button
  List<PopupMenuEntry<int>> _generateTabSelectioList() {
    List<PopupMenuEntry<int>> entries = [];
    for (int i = 0; i < tabs.length; i++) {
      final BrowserTab t = tabs[i];
      String hotkeyStr = "";
      if (i == 0 && tabHotkeys.activateTabFirst != null) {
        hotkeyStr = " (${UserHotkeys.commandStringFromHotkey(tabHotkeys.activateTabFirst)})";
      } else if (i == tabs.length - 1) {
        hotkeyStr = " (${UserHotkeys.commandStringFromHotkey(tabHotkeys.activateTabLast)})";
      }
      PopupMenuEntry<int> entry = PopupMenuItem(
        value: t.metadata.tabId,
        child: Text("${t.metadata.tabTitle}$hotkeyStr"),
      );
      entries.add(entry);
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return (PreferredSize(
      preferredSize: const Size(100, 50),
      child: Container(
        color: rowColor ?? Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TabBar(
                controller: tabController,
                tabs: tabs
                    .map((e) => Tab(
                          child: InheritedBrowserTabData(
                            hotkeys: tabHotkeys,
                            metadata: e.metadata,
                            child: BrowserTabTitle(
                              onTabClose: onTabClose,
                              canCloseTab: tabs.length > 1,
                            ),
                          ),
                        ))
                    .toList(),
                isScrollable: true,
              ),
            ),
            PopupMenuButton<int>(
              tooltip: "Select tab",
              onSelected: onShowTabById,
              itemBuilder: (ctx) => _generateTabSelectioList(),
              color: iconColor ?? Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(
                Icons.list,
              ),
            ),
            IconButton(
              tooltip: "Add tab (${UserHotkeys.commandStringFromHotkey(tabHotkeys.newTab)})",
              onPressed: onAddTab,
              color: iconColor ?? Theme.of(context).colorScheme.onPrimary,
              icon: const Icon(
                Icons.add,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  @override
  Size get preferredSize => const Size(100, 50);
}
