import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/flutter_browser_tabs.dart';
import 'package:flutter_undo/flutter_undo.dart' as undo;
import 'package:collection/collection.dart';
import 'package:nf_hotkeys/nf_hotkeys.dart';

/// Window holds state related to a singleton instance of Gravio Studio
///
/// At the moment (April 2022) this is mostly just a Tab Manager
class TabView extends StatefulWidget {
  /// if [false], Window only ever has one Tab child, won't display the Tab Bar, and all TabHots will be disabled
  final bool hasTabs;

  /// hotkeys related to opening, closing, and selecting tabs
  final TabHotkeys? tabHotkeys;

  /// if [true], the tab manager will automatically create a tab on init and refuse to close tabs if only 1 is left
  final bool atLeastOneTab;

  /// builder function for what widget to create when a new tab is opened
  ///
  /// If is set, [child] must not be set
  final Widget Function(BuildContext)? defaultChildBuilder;

  /// widget to show when a new tab is opened
  ///
  /// if set [defaultChildBuilder] must not be set
  final Widget? child;

  const TabView({
    super.key,
    required this.hasTabs,
    this.defaultChildBuilder,
    this.child,
    this.atLeastOneTab = true,
    this.tabHotkeys,
  }) : assert(child != null || defaultChildBuilder != null, "either child or defaultChildBuilder must be supplied");
  @override
  State<TabView> createState() => _TabViewState();
}

class _TabViewState extends State<TabView> with TickerProviderStateMixin {
  /// TabController so TabBar knows what to do and where to scroll
  TabController? _tabController;

  /// Userhot keys for tab related functions -- populated via the Widget
  late TabHotkeys tabHotkeys;

  /// always-increasing atomic counter for how many tabs have been opened
  /// Serves as a simple TabId
  int _tcounter = -1;

  /// TabId of what Tab is currently being viewed
  int activeTabId = 0;

  /// Index into [tabs] of the Tab that is currently being viewed
  int activeTabIndex = 0;

  /// Generated Hotkey list for Tabs 1-9, filled in only if the corresponding hotkey in [tabHotkeys] is not null
  late final List<KeyAction> showTabByIndexList = _generateShowTabHotkeysByIndexList();

  /// List of Tabs opened by the user
  final List<BrowserTab> tabs = [];

  /// Listener for when a tabs title changes
  late final StreamSubscription<EventTabTitleChanged> _tabTitleChangedSub;

  /// Returns the active tab that this Window is showing
  ///
  /// Returns null if no tabs, or if invalid
  BrowserTab? getActiveTab() {
    if (activeTabId.isNegative) {
      logger.error("[getActiveTab] failed because activeTabId is negative");
      return null;
    }
    final BrowserTab? gt = tabs.firstWhereOrNull((element) => element.metadata.tabId == activeTabId);
    return gt;
  }

  /// Replaces the tab controller when a tab is added or deleted, because TabControllers don't handle this well natively
  TabController _createOrReplaceTabController() {
    TabController? oldTc = _tabController;
    late TabController tc;
    if (oldTc == null) {
      tc = TabController(
        length: tabs.length,
        initialIndex: 0,
        vsync: this,
      );
    } else {
      final oldIndex = oldTc.index;
      final newIndex = max(0, min(oldIndex, tabs.length - 1));
      oldTc.dispose();
      tc = TabController(
        length: tabs.length,
        initialIndex: newIndex,
        vsync: this,
      );
      if (tabs.isEmpty) {
        activeTabId = -1;
      } else {
        activeTabId = tabs[newIndex].metadata.tabId;
      }
    }
    tc.addListener(_tabChangeListener);
    return tc;
  }

  /// Lazily genertaes the available Hotkeys for switching tabs. Hotkeys that are not defined by the user are not included in the output
  List<KeyAction> _generateShowTabHotkeysByIndexList() {
    List<KeyAction> lst = [
      if (tabHotkeys.activateTabFirst != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTabFirst!,
          undo.BasicCommand(
            commandName: "Activate Tab 1",
            execute: () => _showTabByIndex(0),
            canExecute: () => tabs.length > 1,
          ),
        ),
      if (tabHotkeys.activateTab2 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab2!,
          undo.BasicCommand(
            commandName: "Activate Tab 2",
            execute: () => _showTabByIndex(min(tabs.length - 1, 1)),
            canExecute: () => tabs.length > 2,
          ),
        ),
      if (tabHotkeys.activateTab3 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab3!,
          undo.BasicCommand(
            commandName: "Activate Tab 3",
            execute: () => _showTabByIndex(min(tabs.length - 1, 2)),
            canExecute: () => tabs.length > 3,
          ),
        ),
      if (tabHotkeys.activateTab4 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab4!,
          undo.BasicCommand(
            commandName: "Activate Tab 4",
            execute: () => _showTabByIndex(min(tabs.length - 1, 3)),
            canExecute: () => tabs.length > 4,
          ),
        ),
      if (tabHotkeys.activateTab5 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab5!,
          undo.BasicCommand(
            commandName: "Activate Tab 5",
            execute: () => _showTabByIndex(min(tabs.length - 1, 4)),
            canExecute: () => tabs.length > 5,
          ),
        ),
      if (tabHotkeys.activateTab6 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab6!,
          undo.BasicCommand(
            commandName: "Activate Tab 6",
            execute: () => _showTabByIndex(min(tabs.length - 1, 5)),
            canExecute: () => tabs.length > 6,
          ),
        ),
      if (tabHotkeys.activateTab7 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab7!,
          undo.BasicCommand(
            commandName: "Activate Tab 7",
            execute: () => _showTabByIndex(min(tabs.length - 1, 6)),
            canExecute: () => tabs.length > 7,
          ),
        ),
      if (tabHotkeys.activateTab8 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab8!,
          undo.BasicCommand(
            commandName: "Activate Tab 8",
            execute: () => _showTabByIndex(min(tabs.length - 1, 7)),
            canExecute: () => tabs.length > 8,
          ),
        ),
      if (tabHotkeys.activateTab9 != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTab9!,
          undo.BasicCommand(
            commandName: "Activate Tab 9",
            execute: () => _showTabByIndex(min(tabs.length - 1, 8)),
            canExecute: () => tabs.length > 9,
          ),
        ),
      if (tabHotkeys.activateTabLast != null)
        UserHotkeys.keyActionFromSingleActivator(
          tabHotkeys.activateTabLast!,
          undo.BasicCommand(
            commandName: "Activate Last Tab",
            execute: () => _showTabByIndex(tabs.length - 1),
            canExecute: () => tabs.length > 1,
          ),
        ),
    ];

    return lst;
  }

  /// Callback function for the TabItem so that the TabItem knows if it can be disposed or not.
  /// This is combined with the Tab's `AutomaticKeepAliveClientMixin` mixin to not dispose of state before it needs to be
  bool checkTabDisposed(BrowserTabMetadata metadata) {
    for (final g in tabs) {
      if (g.metadata.tabId == metadata.tabId) {
        return false;
      }
    }
    return true;
  }

  /// Callback method for when a Tab's title changes
  void _onTabTitleChanged(EventTabTitleChanged evt) {
    for (var g in tabs) {
      if (g.metadata.tabId == evt.tabId) {
        setState(() => g.metadata.tabTitle = evt.newTitle);
        break;
      }
    }
  }

  /// Adds a tab
  void _onAddTab() {
    logger.info("Adding new tab at index ${tabs.length}");
    _tcounter++;
    final BrowserTabMetadata meta = BrowserTabMetadata(tabTitle: "Tab $_tcounter", tabId: _tcounter);
    final Key gKey = GlobalKey(debugLabel: "TabItem Key $_tcounter");
    final BrowserTabItem tabItem = BrowserTabItem(
      key: gKey,
      metadata: meta,
      checkDisposed: checkTabDisposed,
      child: widget.defaultChildBuilder != null ? widget.defaultChildBuilder!(context) : widget.child!,
    );
    final BrowserTab tab = BrowserTab(meta, tabItem);
    setState(() {
      tabs.add(tab);
      if (tabs.length != _tabController!.length) {
        _tabController = _createOrReplaceTabController();
      }
      _tabController!.animateTo(_tabController!.length - 1);
    });
  }

  /// Checks if a Tab can be closed or not.
  ///
  /// set `force=true` if you want to delete a tab without any of the tab requirement checks
  ///
  /// if `widget.atLeastOneTab` is true, then the last remaiing tab cannot be closed
  bool _canCloseTab(int tabId, bool force) {
    if (force) {
      return true;
    }
    if (widget.atLeastOneTab) {
      return tabs.length > 1;
    }
    return tabs.isNotEmpty;
  }

  /// Closes a Tab, subject to the rules of [_canCloseTab]
  void _onTabClose(BrowserTabMetadata tabMetadata, {bool force = false}) {
    int idx = tabs.indexWhere((x) => x.metadata.tabId == tabMetadata.tabId);
    bool canClose = _canCloseTab(tabMetadata.tabId, force);
    if (idx > -1 && canClose) {
      logger.info("Closing tab with Id ${tabMetadata.tabId} (${tabMetadata.tabTitle})");
      setState(() {
        tabs.removeAt(idx);
        _tabController = _createOrReplaceTabController();
      });
    }
  }

  /// Changes the active tab to [index]
  void _showTabByIndex(int index) {
    int tabCount = tabs.length;
    final TabController? tc = _tabController;
    if (tabs.isEmpty) {
      logger.warn("Tried to switch tabs but tabs list is empty");
      return;
    }
    if (tc == null) {
      logger.warn("Tried to switch tabs but tab controller was empty");
      return;
    }
    int idx = ((index % tabCount) + tabCount) % tabCount;
    logger.info("Switching to tab $index out of $tabCount");

    tc.animateTo(idx);
  }

  /// Switches to the Tab given by the [tabId]. If not tab is found, nothing happens
  void _showTabById(int tabId) {
    int index = tabs.indexWhere((element) => element.metadata.tabId == tabId);
    if (index.isNegative) {
      logger.error("[_showTabById] failed to scroll to tab with id $tabId, not in the list of tabs");
      return;
    }
    _showTabByIndex(index);
  }

  /// Scrolls the tab bar to [index], but does not change the active tab
  void _scrollToTab(int index) {
    if (index < tabs.length) {}
  }

  /// Attached to the TabController so that we can updte the [activeTabId] when the user switches Tabs
  void _tabChangeListener() {
    setState(() {
      int idx = _tabController?.index ?? -1;
      if (idx > -1) {
        activeTabId = tabs[idx].metadata.tabId;
      } else {
        logger.error("[ERROR IN TAB CHANGE] Index was -1");
      }
      activeTabIndex = idx;
      logger.info("Switched tab", eventProperties: {'index': idx});
    });
  }

  @override
  void initState() {
    super.initState();
    tabHotkeys = widget.tabHotkeys ?? TabHotkeys.webBrowser();
    _tabTitleChangedSub = eventBus.on<EventTabTitleChanged>().listen(_onTabTitleChanged);
    activeTabId = 0;
    _tabController = _createOrReplaceTabController();
    if (widget.atLeastOneTab) {
      _onAddTab();
    }
  }

  @override
  void didUpdateWidget(covariant TabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (tabs.length != _tabController?.length) {
      _tabController = _createOrReplaceTabController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return undo.InheritedUndo(
      child: KeyboardWidget(
        bindings: [
          if (tabHotkeys.closeTab != null)
            UserHotkeys.keyActionFromSingleActivator(
              tabHotkeys.closeTab!,
              undo.BasicCommand(
                commandName: "Close Tab (${UserHotkeys.commandStringFromHotkey(tabHotkeys.closeTab)})",
                execute: () {
                  final BrowserTab? gt = getActiveTab();
                  if (gt != null) {
                    _onTabClose(gt.metadata);
                  }
                },
                canExecute: () => getActiveTab() != null,
              ),
            ),
          if (tabHotkeys.newTab != null)
            UserHotkeys.keyActionFromSingleActivator(
              tabHotkeys.newTab!,
              undo.BasicCommand(
                commandName: "New Tab (${UserHotkeys.commandStringFromHotkey(tabHotkeys.newTab)})",
                execute: () => _onAddTab(),
                canExecute: () => widget.hasTabs,
              ),
            ),
          if (tabHotkeys.activateNextTab != null)
            UserHotkeys.keyActionFromSingleActivator(
              tabHotkeys.activateNextTab!,
              undo.BasicCommand(
                commandName: "Activate Next Tab (${UserHotkeys.commandStringFromHotkey(tabHotkeys.activateNextTab)})",
                execute: () => _showTabByIndex(activeTabIndex + 1),
                canExecute: () => tabs.length > 1,
              ),
            ),
          if (tabHotkeys.activatePreviousTab != null)
            UserHotkeys.keyActionFromSingleActivator(
              tabHotkeys.activatePreviousTab!,
              undo.BasicCommand(
                commandName: "Activate Previous Tab (${UserHotkeys.commandStringFromHotkey(tabHotkeys.activatePreviousTab)})",
                execute: () => _showTabByIndex(activeTabIndex - 1),
                canExecute: () => tabs.length > 1,
              ),
            ),
          ...showTabByIndexList,
        ],
        child: Scaffold(
          appBar: !widget.hasTabs && _tabController != null
              ? null
              : BrowserTabBar(
                  tabController: _tabController!,
                  tabs: tabs,
                  tabHotkeys: tabHotkeys,
                  onTabClose: _onTabClose,
                  onShowTabById: _showTabById,
                  onShowTabByIndex: _showTabByIndex,
                  onAddTab: _onAddTab,
                ),
          body: Stack(
            fit: StackFit.expand,
            children: [
              ...tabs.map(
                /* Tab contents are invisible but still kept in memory while they aren't the active tab */
                (e) => Visibility(
                  key: Key("VisibilityForTab_${e.metadata.tabId}"),
                  visible: activeTabId == e.metadata.tabId,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSize: true,
                  maintainInteractivity: false,
                  child: BrowserTabDataInherited(
                    hotkeys: tabHotkeys,
                    metadata: e.metadata,
                    child: e.child,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
