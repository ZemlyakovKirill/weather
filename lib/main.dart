import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:untitled/favourites.dart';
import 'package:untitled/search.dart';
import 'package:untitled/settings.dart';
import 'package:untitled/themechanger.dart';
import 'package:untitled/weatherparse.dart';

import 'bottomSheet.dart';
import 'loading.dart';

StreamController<bool> themeController=StreamController();
void main() async {
  runApp(const MyApp());
}

String bgPath = "";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: themeController.stream,
      builder: (context, snapshot) {
        return FutureBuilder(
          future: ThemeChanger.change(),
          builder: (context,AsyncSnapshot<ThemeMode>themeSnapshot) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Weather App',
              themeMode: themeSnapshot.data != null?themeSnapshot.data:ThemeMode.system,
              theme: ThemeData(
                brightness: Brightness.light,
                backgroundColor: Color.fromRGBO(226, 235, 255, 1),
                textTheme: TextTheme(
                    bodyText1: TextStyle(
                      color: Colors.black,
                    ),
                    bodyText2: TextStyle(color: Color.fromRGBO(3, 140, 254, 1)),
                    button: TextStyle(
                      color: Color.fromRGBO(1, 97, 254, 1),
                    )),
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                backgroundColor: Color.fromRGBO(12, 23, 43, 1),
                textTheme: TextTheme(
                    bodyText1: TextStyle(
                      color: Colors.white,
                    ),
                    bodyText2: TextStyle(color: Colors.white),
                    button: TextStyle(color: Color.fromRGBO(5, 19, 64, 1))),
              ),
              home: const MyHomePage(title: 'Weather App Home'),
            );
          }
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final int popUpChoice = 0;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SelectionPopUp { fisrt, second, third, fourth, fifth }

String currentDate() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd MMMM');
  final String formatted = formatter.format(now);
  return formatted;
}

class _MyHomePageState extends State<MyHomePage> {
 double lat = 60;
  int? selection;
  double lon = 60;
  String name="Волчанск";
  bool flag=false;
  String tempType="";
  String windType="";
  String pressureType="";
  bool bottomClosed=true;

  void _setSettings() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    tempType=prefs.containsKey('temperature')?(prefs.getBool('temperature')!?"˚C":"˚F"):"˚C";
    windType=prefs.containsKey('windSpeed')?(prefs.getBool('windSpeed')!?"км/ч":"м/с"):"м/с";
    pressureType=prefs.containsKey('pressure')?(prefs.getBool('pressure')!?"гПа":"мм.рт.ст."):"мм.рт.ст.";
  }
  void _updateCity(double lat, double lon,String name) {
    setState(() {
      this.lat = lat;
      this.lon = lon;
      this.name=name;
    });
  }
  void openBottom(){
    setState(() {
      bottomClosed=false;
    });
  }
 void closeBottom(){
     bottomClosed=true;
 }

  void _flagChange(){
      flag=!flag;
  }
  Stream<dynamic> _weatherData(double lat, double lon) async* {
    yield await weatherLoad(lat, lon,name);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    WidgetsBinding.instance!.addPostFrameCallback((_)  {_setSettings(); });
    return StreamBuilder(
        stream: _weatherData(lat, lon),
        builder: (context, snapshot) {
          if (snapshot!=null) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return loading(context);
              case ConnectionState.done:
                return Scaffold(
                  backgroundColor: Theme.of(context).backgroundColor,
                  appBar: null,
                  body: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Theme.of(context).brightness==Brightness.light
                                ?"assets/images/lightbackground.jpg"
                                :"assets/images/darkbackground.png"),
                            fit: BoxFit.cover)),
                    constraints: const BoxConstraints.expand(),
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: FutureBuilder(
                      future: timedWeatherLoad(lat, lon,context),
                      builder: (context,AsyncSnapshot<List<SimpleWeather>> sn) {
                        bool isClosed=true;
                        return StatefulBuilder(
                          builder: (context,StateSetter sState) {
                            return SlidingUpPanel(
                              maxHeight: MediaQuery.of(context).size.height*0.74,
                              minHeight: sn.connectionState==ConnectionState.done?MediaQuery.of(context).size.height*0.3:0,
                              onPanelSlide: (pos){
                                if(pos<0.5&&pos>=0)
                                  sState(()=>isClosed=true);
                                else
                                  sState(()=>isClosed=false);
                              },
                              borderRadius: BorderRadius.vertical(top:Radius.circular(15)),
                              panel:Builder(
                                builder: (context) {
                                  switch (sn.connectionState) {
                                    case ConnectionState.done:
                                      return Center(child: bottomSheet(
                                        context: context,
                                        date: currentDate(),
                                        isClosed: isClosed,
                                        lat: lat,
                                        lon: lon,
                                        pressureStr: pressureType,
                                        tempStr: tempType,
                                        windStr: windType,
                                        wth: snapshot.data as Weather,
                                        listTimeWth: sn.data as List<
                                          SimpleWeather>
                                      ));
                                    default:
                                      return Container();
                                }
                                }
                              ),
                              body: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Builder(
                                              builder: (BuildContext innerContext) =>
                                                  NeumorphicButton(
                                                      margin:
                                                          EdgeInsets.fromLTRB(21, 20, 0, 0),
                                                      padding: EdgeInsets.symmetric(
                                                          vertical: 14, horizontal: 7.5),
                                                      style: NeumorphicStyle(
                                                          lightSource: LightSource.topLeft,
                                                          depth: 1,
                                                          shape: NeumorphicShape.convex,
                                                          boxShape:
                                                              NeumorphicBoxShape.circle(),
                                                          color: Theme.of(context)
                                                              .textTheme
                                                              .button!
                                                              .color),
                                                      onPressed: () =>
                                                          Scaffold.of(innerContext)
                                                              .openDrawer(),
                                                      child: Icon(Icons.menu,
                                                          size: 30, color: Colors.white)),
                                            ),
                                            Builder(
                                              builder: (context) {
                                                if (!isClosed) {
                                                  return Container(
                                                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            height: 60,
                                                            alignment: Alignment.center,
                                                            child: Text(
                                                              name,
                                                              style: TextStyle(
                                                                  fontFamily: "Manrope",
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 16,
                                                                  color: Colors.white),
                                                            )),
                                                        Text(
                                                            (snapshot.data as Weather)
                                                                .temperature
                                                                .floor()
                                                                .toString() +
                                                                tempType,
                                                            style: TextStyle(
                                                                fontFamily: "Manrope",
                                                                fontWeight: FontWeight.w600,
                                                                fontSize:
                                                                MediaQuery.of(context).size.width *
                                                                    0.2,
                                                                color: Colors.white)),

                                                      ],
                                                    ),
                                                  );
                                                }
                                                else return Container(
                                                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          (snapshot.data as Weather)
                                                              .temperature
                                                              .floor()
                                                              .toString() +
                                                              tempType,
                                                          style: TextStyle(
                                                              fontFamily: "Manrope",
                                                              fontWeight: FontWeight.w600,
                                                              fontSize:
                                                              MediaQuery.of(context).size.width *
                                                                  0.2,
                                                              color: Colors.white)),
                                                      Text(currentDate(),
                                                          style: TextStyle(
                                                              fontFamily: "Manrope",
                                                              fontWeight: FontWeight.w300,
                                                              fontSize:
                                                              MediaQuery.of(context).size.width *
                                                                  0.05,
                                                              color: Colors.white)),

                                                    ],
                                                  ),
                                                );
                                              }
                                            ),
                                            NeumorphicButton(
                                                margin: EdgeInsets.fromLTRB(0, 20, 21, 0),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14, horizontal: 7.5),
                                                style: NeumorphicStyle(
                                                    lightSource: LightSource.topLeft,
                                                    depth: 1,
                                                    shape: NeumorphicShape.convex,
                                                    boxShape: NeumorphicBoxShape.circle(),
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .button!
                                                        .color),
                                                onPressed: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Search(
                                                            callback: (lat, lon,name) =>
                                                                _updateCity(lat, lon,name)))),
                                                child: Icon(Icons.add_circle_outline,
                                                    size: 30, color: Colors.white)),
                                          ]),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        );
                      }
                    ),
                  ),
                  drawer: Container(
                      width: 225,
                      child: Drawer(
                        child: Container(
                            color: Theme.of(context).backgroundColor,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.fromLTRB(10, 32, 0, 40),
                                      child: Text("Weather App",
                                          style: TextStyle(
                                              fontFamily: "Manrope",
                                              fontWeight: FontWeight.w800,
                                              fontSize: 23,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color))),
                                  TextButton.icon(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Settings())).then((_) => setState(()=>_flagChange())),
                                      icon: Icon(Icons.settings_outlined,
                                          size: 20,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color),
                                      label: Text("Настройки",
                                          style: TextStyle(
                                              fontFamily: "Manrope",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color))),
                                  TextButton.icon(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Favorites())),
                                      icon: Icon(Icons.favorite_border_outlined,
                                          size: 20,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color),
                                      label: Text("Избранное",
                                          style: TextStyle(
                                              fontFamily: "Manrope",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color))),
                                  TextButton.icon(
                                      onPressed: null,
                                      icon: Icon(Icons.person,
                                          size: 20,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color),
                                      label: Text("О приложении",
                                          style: TextStyle(
                                              fontFamily: "Manrope",
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color))),
                                ])),
                      )),
                );
            }
          }
          return Container();
        });
  }
}
