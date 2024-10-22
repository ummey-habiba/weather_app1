import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_app1/pages/weather_home.dart';
import 'package:weather_app1/weather_provider.dart';

import 'pages/settings_page.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]);
  runApp(ChangeNotifierProvider(
      create:(context) => WeatherProvider(),
      child: const MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
        brightness: Brightness.dark),
        useMaterial3: true,
      ),
      initialRoute: WeatherHome.routeName,
      routes: {
        WeatherHome.routeName:(context) => const WeatherHome(),
        SettingsPage.routeName:(context) => const SettingsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
