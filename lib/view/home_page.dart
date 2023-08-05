import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_api_location/constant/weather_const.dart';
import 'package:weather_api_location/models/weather_models.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherModels? weatherModels;
  String? bgImage;
  bool onPressed = false;
  Future<void> weatherName({
    String? cityName,
  }) async {
    final dio = Dio();
    final response = await dio.get(WeatherApi.api(cityName: cityName ?? 'osh'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      weatherModels = WeatherModels(
        id: response.data['weather'][0]['id'],
        air: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        temp: response.data['main']['temp'],
        speed: response.data['wind']['speed'],
        cityName: response.data['name'],
        humidity: response.data['main']['humidity'],
        feelsLike: response.data['main']['feels_like'],
      );
      setBgImage();
      setState(() {});
    }
  }

  Future<void> weatherLocation() async {
    setState(() {
      weatherModels = null;
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final response = await dio.get(WeatherApi.getLocator(
          lat: position.latitude,
          lon: position.longitude,
        ));
        if (response.statusCode == 200 || response.statusCode == 201) {
          weatherModels = WeatherModels(
            air: response.data['weather'][0]['description'],
            id: response.data['current']['weather'][0]['id'],
            speed: response.data['current']['wind_speed'],
            cityName: response.data['timezone'],
            humidity: response.data['current']['humidity'],
            feelsLike: response.data['current']['feels_like'],
            icon: response.data['current']['weather'][0]['icon'],
            temp: response.data['current']['temp'],
          );
        }
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final response = await dio.get(WeatherApi.getLocator(
        lat: position.latitude,
        lon: position.longitude,
      ));
      if (response.statusCode == 200 || response.statusCode == 201) {
        weatherModels = WeatherModels(
          id: response.data['current']['weather'][0]['id'],
          speed: response.data['current']['wind_speed'],
          cityName: response.data['timezone'],
          humidity: response.data['current']['humidity'],
          feelsLike: response.data['current']['feels_like'],
          icon: response.data['current']['weather'][0]['icon'],
          temp: response.data['current']['temp'],
          air: response.data['current']['weather'][0]['description'],
        );
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    weatherName();
    setBgImage();
    super.initState();
  }

  List<String> cities = [
    'bishkek',
    'osh',
    'batken',
    'naryn',
    'talas',
    'karakol',
    'jalalabad',
    'tokmok',
  ];

  void setBgImage() {
    if (weatherModels != null) {
      String air = weatherModels!.air.toLowerCase();

      if (air.contains('дождь')) {
        bgImage = 'assets/images/rain.png';
      } else if (air.contains('пасмурно')) {
        bgImage = 'assets/images/overcast.png';
      } else if (air.contains('ясно')) {
        bgImage = 'assets/images/clear.png';
      } else if (air.contains('переменная облачность')) {
        bgImage = 'assets/images/scatteredclouds.png';
      } else if (air.contains('облачно с прояснениями')) {
        bgImage = 'assets/images/scatteredclouds.png';
      } else if (air.contains('небольшая облачность')) {
        bgImage = 'assets/images/fewclouds.png';
      } else if (air.contains('мгла')) {
        bgImage = 'assets/images/mgla.png';
      } else if (air.contains('дымка')) {
        bgImage = 'assets/images/mgla.png';
      } else {
        bgImage = 'assets/images/clear.png';
      }
    } else {
      // If weatherModels is null, set a default image
      bgImage = 'assets/images/clear.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    bgImage ??= 'assets/images/clear.png';
    return Scaffold(
      body: weatherModels == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 77, 108, 151),
                backgroundColor: Colors.grey,
              ),
            )
          : Stack(
              children: [
                Image.asset(
                  bgImage!,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      expandedHeight: 300,
                      backgroundColor: Colors.transparent,
                      floating: true,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  weatherModels!.cityName,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${weatherModels!.temp.toStringAsFixed(0)}°C',
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    weatherLocation();
                                    onPressed = true;
                                  },
                                  icon: Icon(
                                    Icons.near_me,
                                    color: onPressed
                                        ? Colors.white
                                        : const Color.fromARGB(
                                            255, 77, 108, 151),
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        Card(
                          color: const Color.fromARGB(179, 77, 108, 151),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weatherModels!.air.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Image.network(
                                    WeatherApi.getIcon(weatherModels!.icon, 2)),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(179, 77, 108, 151),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ВЛАЖНОСТЬ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${weatherModels!.humidity.toString()}%',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(179, 77, 108, 151),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ОЩУЩАЕТСЯ КАК',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${weatherModels!.feelsLike.toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                  fontSize: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: const Color.fromARGB(179, 77, 108, 151),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'ВЕТЕР',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Text(
                                weatherModels!.speed.toString(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'км/ч',
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.05,
                  minChildSize: 0.05,
                  maxChildSize: 0.7,
                  builder: (context, controller) => ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                    child: Container(
                      color: const Color.fromARGB(255, 77, 108, 151),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 4,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey,
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: controller,
                              itemCount: cities.length,
                              itemBuilder: (context, index) => ListTile(
                                  onTap: () {
                                    setState(() {
                                      weatherModels == null;
                                    });
                                    weatherName(cityName: cities[index]);
                                    // Navigator.pop(context);
                                  },
                                  title: Row(
                                    children: [
                                      if (weatherModels != null)
                                        Image.network(
                                          WeatherApi.getIcon(
                                              weatherModels!.icon, 2),
                                        ),
                                      Text(
                                        cities[index].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      if (weatherModels != null)
                                        Text(
                                          '${weatherModels!.temp.toStringAsFixed(0)}°C',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
