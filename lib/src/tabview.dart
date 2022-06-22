import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_browser_tabs/flutter_browser_tabs.dart';

class TestState extends StatefulWidget {
  const TestState({Key? key}) : super(key: key);

  @override
  State<TestState> createState() => _TestStateState();
}

class _TestStateState extends State<TestState> {
  String itemState = "no title";
  late Timer _timer;
  int _tickCounter = 0;
  int wcolor = 0;
  Color co = Colors.red;
  late final BrowserTabMetadata meta;

  void timerTick(Timer t) {
    setState(() {
      _tickCounter += 1;
      itemState = "$_tickCounter";
      meta.tabTitle = itemState = "Tab ${meta.tabId} ($wcolor)";
    });
  }

  void buttonPress() {
    List<Color> c = const [Colors.red, Colors.blue, Colors.yellow];
    setState(() {
      wcolor = (wcolor + 1) % c.length;
      co = c[wcolor];
      eventBus.fire(EventTabTitleChanged(meta.tabId, "Tab ${meta.tabId} ($wcolor)"));
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      print("ay yo");
      setState(() {
        var meta = BrowserTabDataInherited.maybeOf(context)?.metadata;
        if (meta != null) {
          itemState = meta.tabTitle;
        }
      });
      _timer = Timer.periodic(const Duration(seconds: 1), timerTick);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    meta = BrowserTabDataInherited.of(context).metadata;
  }

  @override
  void dispose() {
    _timer.cancel();
    // final _TabMetadata meta = TabDataInherited.of(context).metadata;
    // logger.info("DISPOSING OF Tab State ${meta.tabId}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Center(
      child: ElevatedButton(
        child: Text(
          "${meta.tabId} - $_tickCounter FOR TICKER $itemState ",
          style: TextStyle(color: co),
        ),
        onPressed: buttonPress,
      ),
    ));
  }
}
