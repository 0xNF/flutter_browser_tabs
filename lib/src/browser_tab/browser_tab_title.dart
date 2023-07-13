import 'package:flutter/material.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_data_inherited.dart';
import 'package:nf_flutter_hotkeys/nf_hotkeys.dart';
import 'browser_tab_metadata.dart';

class BrowserTabTitle extends StatefulWidget {
  final void Function(BrowserTabMetadata) onTabClose;
  final bool canCloseTab;
  const BrowserTabTitle({
    super.key,
    required this.onTabClose,
    required this.canCloseTab,
  });

  @override
  State<BrowserTabTitle> createState() => BrowserTabTitleState();
}

class BrowserTabTitleState extends State<BrowserTabTitle> {
  BrowserTabMetadata? metadata;
  bool selected = false;

  void onTabCloseClicked() {
    widget.onTabClose(metadata!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    metadata = BrowserTabDataInherited.of(context).metadata;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (x) => setState(() => selected = true),
      onExit: (x) => setState(() => selected = false),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: metadata!.tabTitle,
            child: Text(
              metadata!.tabTitle,
              // style: TextStyle(color: selected),
            ),
          ),
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainInteractivity: false,
            maintainState: true,
            visible: widget.canCloseTab && selected,
            child: IconButton(
              onPressed: widget.canCloseTab ? onTabCloseClicked : null,
              tooltip: "Close this tab (${UserHotkeys.commandStringFromHotkey(BrowserTabDataInherited.of(context).hotkeys.closeTab)})",
              icon: const Icon(Icons.close),
              iconSize: 15,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
