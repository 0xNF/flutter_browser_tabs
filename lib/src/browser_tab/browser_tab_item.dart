import 'package:flutter/widgets.dart';
import 'package:flutter_browser_tabs/src/browser_tab/browser_tab_metadata.dart';
import 'package:flutter_browser_tabs/src/logger/logger.dart';

class BrowserTabItem extends StatefulWidget {
  final BrowserTabMetadata metadata;
  final bool Function(BrowserTabMetadata) checkDisposed;
  final Widget child;

  const BrowserTabItem({
    Key? key,
    required this.metadata,
    required this.checkDisposed,
    required this.child,
  }) : super(key: key);

  @override
  State<BrowserTabItem> createState() => _BrowserTabItemState();
}

class _BrowserTabItemState extends State<BrowserTabItem> with AutomaticKeepAliveClientMixin {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    logger.info("DISPOSING OF Tab State ${widget.metadata.tabId}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => !widget.checkDisposed(widget.metadata);
}
