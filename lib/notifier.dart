
import 'package:local_notifier/local_notifier.dart';

class Notifier {
  final _appName = "Lux";
  Future<void> ensureInitialized()async {
    await localNotifier.setup(
      appName: _appName,
      // The parameter shortcutPolicy only works on Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  Future<void> show(String body)async{
    LocalNotification notification =
    LocalNotification(title: _appName, body: body);
    await notification.show();
  }
}

final notifier = Notifier();
