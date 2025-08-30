import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lux/core_config.dart';
import 'package:lux/home.dart';
import 'package:lux/theme.dart';
import 'package:lux/tr.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

class App extends StatefulWidget {
  final ThemeMode theme;
  final LocaleModel defaultLocalModel;
  final ClientMode clientMode;

  const App(this.theme, this.defaultLocalModel, this.clientMode, {super.key});

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {
  ThemeMode curTheme = ThemeMode.system;
  late LocaleModel curLocaleModel;

  @override
  void initState() {
    super.initState();
    setState(() {
      curTheme = widget.theme;
      curLocaleModel = widget.defaultLocalModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.defaultLocalModel,
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) => MaterialApp(
          themeMode: curTheme,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: Home(curTheme, curLocaleModel, widget.clientMode),
          onGenerateTitle: (context) {
            initTr(context);
            return 'Lux';
          },
          locale: localeModel.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('zh'),
          ],
        ),
      ),
    );
  }
}
