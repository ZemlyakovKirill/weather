import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Weather {
  double temperature;
  int humidity;
  String desc="";
  double pressure;
  double feelsLike;
  double windSpeed;
  List<SimpleWeather> hourly;
  List<DailyWeather> daily;
  Weather( this.temperature, this.humidity, this.pressure, this.feelsLike, this.windSpeed,this.hourly,this.daily,Function(String) func,String parameter){
    desc=func.call(parameter);
  }
  Weather.empty()
    :temperature=0,
  humidity=0,
  desc="",
  pressure=0,
  feelsLike=0,
  windSpeed=0,
  hourly=List.empty(growable: true),
  daily=List.empty(growable: true);


  @override
  String toString() {
    return 'Weather{temperature: $temperature, humidity: $humidity, desc: $desc, pressure: $pressure, feelsLike: $feelsLike, windSpeed: $windSpeed, hourly: $hourly, daily: $daily}';
  }

}

class SimpleWeather {
  int dt;
  double temp;
  String desc;
  
  SimpleWeather(this.dt, this.temp, this.desc);


  SimpleWeather.empty(int dt,String path)
      :this.dt=dt,
        this.temp=0,
        desc=path;

  @override
  String toString() {
    return 'SimpleWeather{dt: $dt, temp: $temp, desc: $desc}';
  }
}
class DailyWeather {
  int dt;
  double temp;
  int humidity;
  double feelsLike;
  double pressure;
  double windSpeed;
  String desc;


  DailyWeather(this.dt, this.temp, this.humidity, this.feelsLike, this.pressure,
      this.windSpeed, this.desc);

  DailyWeather.empty(int dt,String path)
      :dt=dt,
        temp=0,
        desc=path,
        humidity=0,
        windSpeed=0,
        pressure=0,
        feelsLike=0;

  @override
  String toString() {
    return 'DailyWeather{dt: $dt, temp: $temp, humidity: $humidity, feelsLike: $feelsLike, pressure: $pressure, windSpeed: $windSpeed, desc: $desc}';
  }
}

Future<Weather> timedWeatherLoad(double lat, double lon,BuildContext context) async {
  Weather weather=Weather.empty();
  List<int> milliesPast = List.empty(growable: true);
  List<int> milliesWill = List.empty(growable: true);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final units =
    prefs.containsKey('temperature') ? prefs.getBool('temperature')! : true;
    final windSpeed =
    prefs.containsKey('windSpeed') ? prefs.getBool('windSpeed')! : false;
    final pressure =
    prefs.containsKey('pressure') ? prefs.getBool('pressure')! : false;

    final currentDate = DateTime.now();
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
    print(milliesWill);
    if (milliesPast.isNotEmpty) {
      for (var value in milliesPast) {
        await loadPast(context, lat, lon, value,weather);
      }
    }
    await loadFuture(context, lat, lon, milliesWill,weather);
    if (!units) {
      weather.temperature=weather.desc.contains(RegExp("error|noconnection|timeout"))?0:1.8*weather.temperature+32;
      weather.feelsLike=weather.desc.contains(RegExp("error|noconnection|timeout"))?0:1.8*weather.feelsLike+32;
      weather.hourly.forEach((element) {
        element.temp=element.desc.contains(RegExp("error|noconnection|timeout"))?0:1.8*element.temp+32;
      });
      weather.daily.forEach((element){
        element.temp=element.desc.contains(RegExp("error|noconnection|timeout"))?0:1.8*element.temp+32;
        element.feelsLike=element.desc.contains(RegExp("error|noconnection|timeout"))?0:1.8*element.feelsLike+32;
      });
    }
    if(!windSpeed){
      weather.windSpeed=weather.windSpeed*0.27778;
      weather.daily.forEach((element){element.windSpeed=element.windSpeed*0.27778;});
    }
    if(!pressure){
      weather.pressure=weather.pressure*0.75;
      weather.daily.forEach((element){element.pressure=element.pressure * 0.75;});
    }
    weather.hourly.sort((a,b)=>a.dt.compareTo(b.dt));
    return weather;
  }

Future<void> loadPast(BuildContext context,double lat, double lon, int dt,Weather weather) async {
  try {
    final response = await http
        .get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=$lat&lon=$lon&dt=$dt&appid=71e3be3663bcca427b12641479ea0402&units=metric&lang=ru'),
    )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = (jsonDecode(response.body) as Map<String, dynamic>)['current'];
      weather.hourly.add(
        SimpleWeather(
            dt*1000,
            json['temp'],
            getIconPathFromWeather(json['weather'][0]['main'], context))
      );
    }
  } on SocketException catch (e) {
    weather.hourly.add(
        SimpleWeather(
            dt*1000,
            0,
            getIconPathFromWeather("No con", context))
    );
  } on TimeoutException catch (e) {
    weather.hourly.add(
        SimpleWeather(
            dt*1000,
            0,
            getIconPathFromWeather("Time out", context))
    );
  } on Error catch (e) {
    weather.hourly.add(
        SimpleWeather(
            dt*1000,
            0,
            getIconPathFromWeather("Error", context))
    );
  }
}

Future<void> loadFuture(BuildContext context,
    double lat, double lon, List<int> dt,Weather weather) async {
  try {
    final response = await http
        .get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=71e3be3663bcca427b12641479ea0402&units=metric&lang=ru'),
    )
        .timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      final json = (jsonDecode(response.body) as Map<String, dynamic>);
      if(weather.desc==""){
        weather.desc=getIconPathFromWeather(json['current']['weather'][0]['main'], context);
        weather.temperature=json['current']['temp'].toDouble();
        weather.feelsLike=json['current']['feels_like'].toDouble();
        weather.pressure=json['current']['pressure'].toDouble();
        weather.windSpeed=json['current']['wind_speed'].toDouble();
        weather.humidity=json['current']['humidity'].toInt();
      }
      if (dt.isNotEmpty) {
        List<SimpleWeather> hourlyWeather=json['hourly']
            .where((el)=>dt.contains(el['dt']))
            .map((element)=>
            SimpleWeather(
              element['dt']*1000,
              element['temp'],
              getIconPathFromWeather(element['weather'][0]['main'], context)
            )).toList().cast<SimpleWeather>();
        weather.hourly.addAll(hourlyWeather);
      }
      //this.dt, this.temp, this.humidity, this.feelsLike, this.pressure,
      //       this.windSpeed, this.desc
      List<DailyWeather> dailyWeather=json['daily']
        .sublist(0,8)
        .map((element)=>DailyWeather(
          element['dt']*1000,
          element['temp']['day'].toDouble(),
          element['humidity'].toInt(),
          element['feels_like']['day'].toDouble(),
          element['pressure'].toDouble(),
          element['wind_speed'].toDouble(),
          getIconPathFromWeather(element['weather'][0]['main'], context)
      )).toList().cast<DailyWeather>();
      weather.daily.addAll(dailyWeather);
    }
  } on SocketException catch (e) {
    weather.hourly.addAll(
      List.generate(dt.length, (index) => SimpleWeather(
        dt[index]*1000,
        0,
        getIconPathFromWeather("No con", context)
      ))
    );
    weather.desc=getIconPathFromWeather("No con", context);
    weather.daily=List.empty(growable: true)
      ..add(DailyWeather.empty(
          DateTime.now().millisecondsSinceEpoch,
          getIconPathFromWeather("No con", context)));
  } on TimeoutException catch (e) {
    weather.hourly.addAll(
        List.generate(dt.length, (index) => SimpleWeather(
            dt[index]*1000,
            0,
            getIconPathFromWeather("Time out", context)
        ))
    );
    weather.desc=getIconPathFromWeather("Time out", context);
    weather.daily=List.empty(growable: true)
      ..add(DailyWeather.empty(
          DateTime.now().millisecondsSinceEpoch,
          getIconPathFromWeather("Time out", context)));
  } on Error catch (e) {
    print(e.toString());
    weather.hourly.addAll(
        List.generate(dt.length, (index) => SimpleWeather(
            dt[index]*1000,
            0,
            getIconPathFromWeather("Error", context)
        ))
    );
    weather.daily=List.empty(growable: true)
      ..add(DailyWeather.empty(
          DateTime.now().millisecondsSinceEpoch,
          getIconPathFromWeather("Time out", context)));
  }
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
    case "No con":
      return "assets/icons/noconnection.svg";
    case "Time out":
      return "assets/icons/timeout.svg";
    case "Error":
      return "assets/icons/error.svg";
  }
  return "assets/icons/thundericon"+theme+'.svg';
}