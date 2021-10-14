import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class City {
  String? name;
  double? lat;
  double? lon;
  bool? isFavorite;

  City();

  City.fromNameAndFavorite(this.name, this.isFavorite);

  City.fromJson(Map<String, String> json) {
    this.name = json['name'];
    this.lat = double.tryParse(json['lat']!);
    this.lon = double.tryParse(json['lon']!);
    this.isFavorite = json['isFavorite']!.toLowerCase() == 'true';
  }

  City.fromXML(XmlElement code) {
    this.name = code.getElement('name')!.text;
    this.lat = double.tryParse(code.getElement('lat')!.text);
    this.lon = double.tryParse(code.getElement('lng')!.text);
    this.isFavorite = false;
  }

  Map toJson() => {
        'name': name,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'isFavorite': isFavorite.toString()
      };

  @override
  String toString() {
    return 'City{name: $name, lat: $lat, lon: $lon, isFavorite: $isFavorite}';
  }

  static Future<List<String>> _favorites () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('favorites') ||
        prefs.getStringList('favorites')!.isEmpty) {
      prefs.setStringList('favorites', List.empty(growable: true));
    }
    return prefs.getStringList('favorites')!;
  }

  static Future<List<City>> getFavorites() async {
    List<String> ctStr = await _favorites();
    List<City> cities = ctStr
        .map((element) =>
            City.fromJson(Map<String, String>.from(json.decode(element))))
        .toList();
    return cities;
  }

  static Future<void> addFavorite(City city) async {
    city.isFavorite = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> fav = await _favorites();
    fav.add(jsonEncode(city));
    prefs.setStringList('favorites', fav);
  }

  static Future<void> removeFavorite(City city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<City> fav = await getFavorites();
    fav.removeWhere((element) => city.lat==element.lat&&city.lon==element.lon);
    print(fav);
    var favStr=fav.map((e) => json.encode(e)).toList();
    prefs.setStringList('favorites', favStr);
  }

  static Future<List<City>> getCitiesByName(String name) async {
    try {
      final response = await http
          .get(Uri.parse("http://api.geonames.org/postalCodeSearch"
              "?placename=$name"
              "&username=themlyakov"
              "&maxRows=5"
              "&country=RU"))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final doc = XmlDocument.parse(response.body);
          final fav = await getFavorites();
          Iterable<XmlElement> code = doc.findAllElements('code');
          List<City> cities = code
              .map((e) => City.fromXML(e))
              .where((element) => fav
                  .where((el) =>
                      el.name!.toLowerCase() == element.name!.toLowerCase())
                  .isEmpty)
              .where((element) => !element.name!.contains(RegExp('[0-9]')))
              .toList();
          return cities;
        }
      }
    } on Exception catch (e) {
      return List.empty();
    }
    return List.empty();
  }

  static void cleanFavorites() async {
    (await SharedPreferences.getInstance())
        .setStringList('favorites', List.empty(growable: true));
  }

  Container getCityAsContainer(BuildContext context,
      Function(double, double,String) callback, Function favCallback) {
    return Container(
        child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TextButton(
            onPressed: () {
              callback.call(lat!, lon!,name!);
              Navigator.pop(context);
            },
            child: Text(name!,
                style: TextStyle(
                  fontFamily: "Manrope",
                  fontSize: MediaQuery.of(context).size.height*0.027,
                  color: Theme.of(context).textTheme.bodyText1!.color
                )),
          ),
          GestureDetector(
              onTap: () => favCallback.call(),
              child:
                  Icon(isFavorite! ? Icons.star : Icons.star_border_outlined,color: Theme.of(context).textTheme.bodyText1!.color,)),
        ]),
        Divider(color:Color.fromRGBO(0, 0, 0, 0.15))
      ],
    ));
  }
}
