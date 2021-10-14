import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Weather {
  String city = "";
  double temperature;
  int humidity;
  double pressure;
  double tempMin;
  double tempMax;
  double feelsLike;
  double windSpeed;

  Weather(this.city, this.temperature, this.humidity, this.pressure,
      this.tempMin, this.windSpeed, this.tempMax, this.feelsLike);

  Weather.fromJson(Map<String, dynamic> json)
      : temperature = (json['main']['temp']).toDouble(),
        city = json['name'],
        humidity = (json['main']['humidity']).toInt(),
        pressure = (json['main']['pressure']).toDouble(),
        tempMin = (json['main']['temp_min']).toDouble(),
        tempMax = (json['main']['temp_max']).toDouble(),
        feelsLike = (json['main']['feels_like']).toDouble(),
        windSpeed = (json['wind']['speed']).toDouble();

  @override
  String toString() {
    return 'Weather{city: $city, temperature: $temperature, humidity: $humidity, pressure: $pressure, tempMin: $tempMin, tempMax: $tempMax, feelsLike: $feelsLike, windSpeed: $windSpeed}';
  }
}

Future<Weather> weatherLoad(double lat, double lon, String name) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final units =
        prefs.containsKey('temperature') ? prefs.getBool('temperature')! : true;
    final windSpeed =
        prefs.containsKey('windSpeed') ? prefs.getBool('windSpeed')! : false;
    final pressure =
        prefs.containsKey('pressure') ? prefs.getBool('pressure')! : false;
    final response = await http
        .get(
          Uri.parse(
              'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=71e3be3663bcca427b12641479ea0402&units=metric&lang=ru'),
        )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      var weather =
          Weather.fromJson(json.decode(response.body) as Map<String, dynamic>);
      if (!windSpeed) {
        weather.windSpeed *= 3.6;
      }
      if (pressure == false) {
        weather.pressure *= 0.75062;
      }
      if (units == false) {
        weather.temperature = 1.8 * weather.temperature + 32;
        weather.tempMax = 1.8 * weather.tempMax + 32;
        weather.tempMin = 1.8 * weather.tempMin + 32;
        weather.feelsLike = 1.8 * weather.feelsLike + 32;
      }
      return weather;
    }
  } on TimeoutException catch (e) {
    return Weather("Timeout error", 0, 0, 0, 0, 0, 0, 0);
  } on SocketException catch (e) {
    return Weather("Нет интернета", 0, 0, 0, 0, 0, 0, 0);
  } on Error catch (e) {
    print(e.toString());
    print(e.stackTrace);
    return Weather("Error", 0, 0, 0, 0, 0, 0, 0);
  }
  return Weather("", 0, 0, 0, 0, 0, 0, 0);
}

class SimpleWeather {
  int dt;
  double temp;
  String desc;

  SimpleWeather(this.dt, this.temp, this.desc);

  @override
  String toString() {
    return 'SimpleWeather{dt: $dt, temp: $temp, desc: $desc}';
  }
}

Future<List<SimpleWeather>> timedWeatherLoad(double lat, double lon,BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final units =
        prefs.containsKey('temperature') ? prefs.getBool('temperature')! : true;
    final currentDate = DateTime.now();
    List<SimpleWeather> result = List.empty(growable: true);
    List<int> milliesPast = List.empty(growable: true);
    List<int> milliesWill = List.empty(growable: true);
    for (int i = currentDate.hour; i >= 0; i--) {
      if (i % 6 == 0) {
        milliesPast.add(currentDate
                .subtract(Duration(
                    hours: currentDate.hour - i,
                    minutes: currentDate.minute,
                    seconds: currentDate.second,
                    milliseconds: currentDate.millisecond,
                    microseconds: currentDate.microsecond))
                .millisecondsSinceEpoch ~/
            1000);
      }
    }
    for (int i = currentDate.hour; i <= 18; i++) {
      if (i % 6 == 0) {
        milliesWill.add(currentDate
                .add(Duration(
                    hours: i - currentDate.hour,
                    minutes: -currentDate.minute,
                    seconds: -currentDate.second,
                    milliseconds: -currentDate.millisecond,
                    microseconds: -currentDate.microsecond))
                .millisecondsSinceEpoch ~/
            1000);
      }
    }
    if (milliesPast.isNotEmpty) {
      for (var value in milliesPast) {
        final res = await loadPast(context,lat, lon, value);
        result.add(res);
      }
    }
    if (milliesWill.isNotEmpty) {
      final res = await loadFuture(context,lat, lon, milliesWill);
      result.addAll(res);
    }
    result.sort((a, b) => a.dt.compareTo(b.dt));
    if (!units) {
      result.forEach((element) {
        element.temp = 1.8 * element.temp + 32;
      });
    }
    return result;
  } on TimeoutException catch (e) {
    return List.empty();
  }on SocketException catch (e) {
    return List.empty();
  }on Error catch (e){
    print(e.toString());
    print(e.stackTrace);
    return List.empty();
  };
}

Future<SimpleWeather> loadPast(BuildContext context,double lat, double lon, int dt) async {
  final response = await http
      .get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=$lat&lon=$lon&dt=$dt&appid=71e3be3663bcca427b12641479ea0402&units=metric&lang=ru'),
      )
      .timeout(Duration(seconds: 10));
  if (response.statusCode == 200) {
    final json = (jsonDecode(response.body) as Map<String, dynamic>)['current'];
    return SimpleWeather(
        dt, json['temp'],
        getIconPathFromWeather(json['weather'][0]['main'],context)
    );
  }
  return SimpleWeather(dt, 0, '');
}

Future<List<SimpleWeather>> loadFuture(BuildContext context,
    double lat, double lon, List<int> dt) async {
  final response = await http
      .get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=current,minutely,daily,alerts&appid=71e3be3663bcca427b12641479ea0402&units=metric&lang=ru'),
      )
      .timeout(Duration(seconds: 10));
  if (response.statusCode == 200) {
    List<dynamic> values =
        (jsonDecode(response.body) as Map<String, dynamic>)['hourly'];
    return values
        .where((element) => dt.contains(element['dt']))
        .map((e) =>
            SimpleWeather(
                e['dt'], e['temp'],
                getIconPathFromWeather(e['weather'][0]['main'],context)))
        .toList();
  }
  return List.empty(growable: true);
}

String getIconPathFromWeather(String parameter,BuildContext context){
  String theme=Theme.of(context).brightness==Brightness.light?"light":"dark";
  switch (parameter){
    case "Rain":case "Snow":
      return "assets/icons/rainmax"+theme+'.svg';
    case "Clouds":
      return "assets/icons/rainmini"+theme+'.svg';
    case "Clear":
      return "assets/icons/sunicon"+theme+'.svg';
    case "Extreme":
      return "assets/icons/thundericon"+theme+'.svg';
  }
  return "assets/icons/thundericon"+theme+'.svg';
}