class WeatherModels {
  WeatherModels({
    required this.cityName,
    required this.temp,
    required this.id,
    required this.air,
    // required this.sunrise,
    // required this.sunset,
    required this.humidity,
    required this.feelsLike,
    required this.speed,
    required this.icon,
    // required this.main,
  });

  final String cityName;
  final double temp;
  final int id;
  final String air;
  // final int sunrise;
  // final int sunset;
  final int humidity;
  final double feelsLike;
  final String icon;
  // final String main;

  dynamic speed;
}
