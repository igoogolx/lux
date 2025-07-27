import 'package:flutter/material.dart';
import 'package:lux/core_config.dart';
import 'package:lux/home.dart';
import 'package:lux/tr.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';

class App extends StatelessWidget {
  final ThemeMode theme;
  final Color scaffoldBackgroundColor;
  final LocaleModel defaultLocalModel;
  final ClientMode clientMode;

  const App(this.theme, this.scaffoldBackgroundColor, this.defaultLocalModel,
      this.clientMode,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => defaultLocalModel,
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) => MaterialApp(
          themeMode: ThemeMode.light,
          theme: ThemeData(
              brightness: Brightness.light,
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
              radioTheme: RadioThemeData(fillColor:
                  WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return Colors.blue.withValues();
                }
                return Colors.blue;
              })),
              dropdownMenuTheme: DropdownMenuThemeData(
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ))),
              appBarTheme: AppBarTheme(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white)),
          darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
          home: Home(theme, defaultLocalModel, clientMode),
          onGenerateTitle: (context) {
            initTr(context);
            return 'Lux';
          },
          locale: localeModel.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
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
