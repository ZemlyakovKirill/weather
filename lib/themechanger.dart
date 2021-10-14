


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger {

  static Future<ThemeMode> change()async{
    final prefs=await SharedPreferences.getInstance();
    if(prefs.containsKey('themeMode')){
      switch(prefs.getInt('themeMode')){
        case 1:
          if(DateTime.now().hour>=21&&DateTime.now().hour<=9) {
            return ThemeMode.dark;
          } else {
            return ThemeMode.light;
          }
        case 2:
          return ThemeMode.light;
        case 3:
          return ThemeMode.dark;
        default:
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }
}