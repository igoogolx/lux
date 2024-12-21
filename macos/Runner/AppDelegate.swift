import Cocoa
import FlutterMacOS
import flutter_desktop_sleep

@main
class AppDelegate: FlutterAppDelegate {
  var _windowManager = FlutterDesktopSleepPlugin()

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

   override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    return _windowManager.applicationShouldTerminate(controller);
    }
}
