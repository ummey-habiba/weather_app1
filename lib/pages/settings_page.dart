import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app1/weather_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const String routeName ='/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isOn =false;
  @override
  void didChangeDependencies() {
context.read<WeatherProvider>().getTempStatus().then((value){
  setState(() {
    isOn=value;
  });
});
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SwitchListTile(value: isOn, onChanged: (value) async{
            setState(() {
              isOn =value;
            });
           await  context.read<WeatherProvider>().setTempStatus(value);
            context.read<WeatherProvider>().setUnit(value);
            context.read<WeatherProvider>().getWeatherData();


          },title: const Text('Show Temperature in Fahrenheit'),
          subtitle: const Text('Default is Celsius'),)

        ],
      ),
    );
  }
}
