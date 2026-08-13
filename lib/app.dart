import 'package:lux/core/core_config.dart';
import 'package:lux/home.dart';
import 'package:lux/model/app.dart';
import 'package:lux/theme.dart';
import 'package:lux/tr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  final ThemeMode theme;
  final Locale defaultLocal;
  final ClientMode clientMode;

  const App(this.theme, this.defaultLocal, this.clientMode, {super.key});

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  late AppStateModel appState =
      AppStateModel(widget.theme, widget.defaultLocal);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => appState,
      child: Consumer<AppStateModel>(
        builder: (context, appState, child) => MaterialApp(
          themeMode: appState.theme,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: Home(widget.clientMode),
          onGenerateTitle: (context) {
            initTr(context);
            return 'Lux';
          },
          locale: appState.locale,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: [
            Locale('en'),
            Locale('zh'),
          ],
        ),
      ),
    );
  }
}
