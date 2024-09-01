import Cocoa
import FlutterMacOS
import flutter_desktop_sleep

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  var _windowManager = FlutterDesktopSleepPlugin()

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

   override func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    return _windowManager.applicationShouldTerminate(controller);
    }

    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
            if !flag {
                for window in NSApp.windows {
                    if !window.isVisible {
                        window.setIsVisible(true)
                    }
                    window.makeKeyAndOrderFront(self)
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
            return true
        }
}
