import 'package:ilogger/ilogger.dart';

/// public Hookpoint for attaching anything implementing an ILogger
ILogger get logger => _logger;
ILogger _logger = BasicConsoleLogger(name: "Flutter_Browser_Tabs_logger");

/// Sets a Hooked Logger for the library. If `logger` is `null`, then no messages will be logged
void setLoggerHook(ILogger? logger) {
  _logger = logger ?? BasicNullLogger(name: "Flutter_Browser_Tabs_Null_logger");
}
