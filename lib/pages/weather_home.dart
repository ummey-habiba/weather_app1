import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app1/custom_widgets/app_background.dart';
import 'package:weather_app1/models/current_response.dart';
import 'package:weather_app1/models/forecast_response.dart';
import 'package:weather_app1/pages/settings_page.dart';
import 'package:weather_app1/utils/helper_function.dart';
import '../utils/constant.dart';
import '../weather_provider.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  static const String routeName = '/';

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isConnected = true;

  Future<void> getData() async {
    if (await isConnectedToInternet()) {
      await context.read<WeatherProvider>().determinePosition();
      final status = await context.read<WeatherProvider>().getTempStatus();
      context.read<WeatherProvider>().setUnit(status);
      await context.read<WeatherProvider>().getWeatherData();
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }

  Future<bool> isConnectedToInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  @override
  void didChangeDependencies() {
    Connectivity().checkConnectivity();
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile)) {
        setState(() {
          isConnected = true;
          getData();
        });
      } else {
        setState(() {
          isConnected = false;
        });
      }
    });

    getData();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              getData();
            },
            icon: const Icon(Icons.location_on),
          ),
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: _CitySearchDelegate())
                    .then((city) async {
                  if (city != null && city.isNotEmpty) {
                    await context
                        .read<WeatherProvider>()
                        .ConvertCityToLatLng(city);
                    await context.read<WeatherProvider>().getWeatherData();
                  }
                });
              },
              icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, SettingsPage.routeName),
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Consumer<WeatherProvider>(
          builder: (context, provider, child) => provider.hasDataLoaded
              ? Stack(
            children: [
              const AppBackground(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80.0,
                  ),
                  if (!isConnected)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding:const  EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        width: double.infinity,  color: Colors.black,
                        child: const Text(
                          '!No Internet Connection!',

                        ),
                      ),
                    ),
                  CurrentWeatherView(
                      currentResponse: provider.currentResponse!,
                      symbol: provider.unitSymbol),
                  const Spacer(),
                  const Row(
                    children: [
                      Text(
                        ' Daily Forecast',
                        style: TextStyle(fontSize: 24.0),
                      ),
                    ],
                  ),

                  ForecastWeatherView(
                    items: provider.forecastResponse!.list!,
                    symbol: provider.unitSymbol,
                  ),
                ],
              ),
            ],
          )
              : Center(
            child: isConnected
                ? const CircularProgressIndicator()
                : const Text('!!!No Internet Connection'),
          )),
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}

class CurrentWeatherView extends StatelessWidget {
  const CurrentWeatherView({
    super.key,
    required this.currentResponse,
    required this.symbol,
  });

  final CurrentResponse currentResponse;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          getFormattedDateTime(
            currentResponse.dt!,
          ),
          style: const TextStyle(fontSize: 20.0),
        ),
        Text(
          '${currentResponse.name},${currentResponse.sys!.country}',
          style: const TextStyle(fontSize: 27.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(getIconUrl(
              currentResponse.weather!.first.icon!,
            )),
            Text(
              '${currentResponse.main!.temp!.round()}$degree$symbol',
              style: const TextStyle(fontSize: 50.0),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Feel like ${currentResponse.main!.feelsLike!.round()}$degree$symbol',
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              '${currentResponse.weather!.first.main}-${currentResponse.weather!.first.description}',
              style: const TextStyle(fontSize: 18.0),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop,size: 18.0,),
            Column(
              children: [
                const Text('Humidity'),
                Text(' ${currentResponse.main!.humidity}%')
              ],
            ),
            const SizedBox( width: 20.0,),
            const Icon(Icons.visibility,size: 18.0,),
            Column(
              children: [
                const  Text('Visibility '),
                Text('${currentResponse.visibility}km')
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_sharp,size: 18.0,),
            Column(
              children: [
                const  Text('SunRise '),
                Text('${getFormattedDateTime(currentResponse.sys!.sunrise!, pattern: 'hh:mm a')}')
              ],
            ),
            const SizedBox( width: 15.0,),
            const Icon(Icons.nights_stay,size: 18.0,),
            Column(
              children: [
                const  Text('SunSet '),
                Text('${getFormattedDateTime(currentResponse.sys!.sunset!, pattern: 'hh:mm a')}')
              ],
            ),

          ],
        )
      ],
    );
  }
}

class ForecastWeatherView extends StatelessWidget {
  const ForecastWeatherView(
      {super.key, required this.items, required this.symbol});

  final List<ForecastItem> items;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 80.0,
            child: Card(
              color: Colors.black26,
              child: Column(
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    getFormattedDateTime(item.dt!, pattern: 'EEE dd'),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    getFormattedDateTime(item.dt!, pattern: 'hh:mm a'),
                    style: const TextStyle(fontSize: 10.0),
                  ),
                  CachedNetworkImage(
                    imageUrl: getIconUrl(item.weather!.first.icon!),
                    width: 50.0,
                    height: 50.0,
                    placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      size: 40.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${item.main!.temp!.round()}$degree',
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      const SizedBox(
                        width: 2.0,
                      ),
                      Text(
                        '${item.main!.feelsLike!.round()}$degree',
                        style: const TextStyle(fontSize: 15.0),
                      )
                    ],
                  ),
                  Text(
                    '${item.weather!.first.main}\n${item.weather!.first.description}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15.0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, query);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? majorCities
        : majorCities
        .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final city = filteredList[index];
        return ListTile(
          onTap: () {
            close(context, city);
          },
          title: Text(city),
        );
      },
    );
  }
}


