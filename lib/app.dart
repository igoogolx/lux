import 'package:flutter/material.dart';
import 'package:lux/home.dart';
import 'package:lux/tr.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  final String theme;
  final Color scaffoldBackgroundColor ;
  final LocaleModel defaultLocalModel ;

  const App(this.theme,this.scaffoldBackgroundColor, this.defaultLocalModel,{super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => defaultLocalModel,
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) => MaterialApp(
          theme: ThemeData(
              scaffoldBackgroundColor:scaffoldBackgroundColor ), //Dark mode of dashboard
          home: Home(theme, defaultLocalModel),
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
        )
        ,
      ),
    );
  }
}

