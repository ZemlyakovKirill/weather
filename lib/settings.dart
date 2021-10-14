import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/main.dart';

class Settings extends StatefulWidget {
  Settings({Key? key}) :
        super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int temperature = 1;
  int wind=0;
  int pressure=0;
  int theme=0;

  void setTemperatureSelection(int value) async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      temperature = value;
    });
    prefs.setBool('temperature', value>0?true:false);
  }

  void setPressureSelection(int value) async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      pressure = value;
    });
    prefs.setBool('pressure', value>0?true:false);
  }

  void setThemeSelection(int value) async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      theme=value;
    });
    prefs.setInt('themeMode', value);
    themeController.add(true);
  }
  void setWindSelection(int value)async {
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      wind = value;
    });
    prefs.setBool('windSpeed', value>0?true:false);
  }

  @override
  void initState(){
    WidgetsBinding.instance!.addPostFrameCallback((_){
      _asyncMethod();
    });
  }
  Future<void> _asyncMethod()async{
    final prefs=await SharedPreferences.getInstance();
      setState((){
        temperature=prefs.containsKey('temperature')?(prefs.getBool('temperature')!?1:0):1;
        wind=prefs.containsKey('windSpeed')?(prefs.getBool('windSpeed')!?1:0):0;
        pressure=prefs.containsKey('pressure')?(prefs.getBool('pressure')!?1:0):0;
        theme=prefs.containsKey('themeMode')?prefs.getInt('themeMode')!:0;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => {
            Navigator.pop(context),
          },
          iconSize: 20,
          icon: Icon(Icons.arrow_back_ios_outlined),
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text("Настройки",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color,
                fontFamily: "Manrope",
                fontWeight: FontWeight.w600,
                fontSize: 20)),
        actions: [],
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text("Eдиницы измерения",
                      style: TextStyle(
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          color: Color.fromRGBO(130, 130, 130, 1)))),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 8,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                  color: Theme.of(context).backgroundColor,
                ),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Температура",
                                style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: MediaQuery.of(context).size.width*0.04,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color)),
                            NeumorphicToggle(
                              width: MediaQuery.of(context).size.width*0.4,
                              height: MediaQuery.of(context).size.width*0.1,
                              selectedIndex: temperature,
                              style: NeumorphicToggleStyle(
                                backgroundColor:
                                    Color.fromRGBO(226, 235, 255, 1),
                              ),
                              thumb: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.convex,
                                  depth: 8,
                                  color: Theme.of(context)
                                      .textTheme.button!.color,
                                ),
                              ),
                              children: [
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("˚F",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("˚F",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  background: Center(
                                    child: Text("˚C",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ),
                                  foreground: Center(
                                    child: Text("˚C",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                )
                              ],
                              onChanged: (value) {
                                setTemperatureSelection(value);
                              },
                            )
                          ]),
                    ),
                    Divider(),
                    Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Сила ветра",
                                style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: MediaQuery.of(context).size.width*0.04,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color)),
                            NeumorphicToggle(
                              width: MediaQuery.of(context).size.width*0.4,
                              height: MediaQuery.of(context).size.width*0.1,
                              selectedIndex: wind,
                              style: NeumorphicToggleStyle(
                                backgroundColor:
                                Color.fromRGBO(226, 235, 255, 1),
                              ),
                              thumb: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.convex,
                                  depth: 8,
                                  color: Theme.of(context)
                                      .textTheme.button!.color,
                                ),
                              ),
                              children: [
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("м/с",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("м/с",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  background: Center(
                                    child: Text("км/ч",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ),
                                  foreground: Center(
                                    child: Text("км/ч",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                )
                              ],
                              onChanged: (value) {
                                setWindSelection(value);
                              },
                            )
                          ]),
                    ),
                    Divider(),
                    Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Давление",
                                style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: MediaQuery.of(context).size.width*0.04,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color)),
                            NeumorphicToggle(
                              width: MediaQuery.of(context).size.width*0.4,
                              height: MediaQuery.of(context).size.width*0.1,
                              selectedIndex: pressure,
                              style: NeumorphicToggleStyle(
                                backgroundColor:
                                Color.fromRGBO(226, 235, 255, 1),
                              ),
                              thumb: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.convex,
                                  depth: 8,
                                  color: Theme.of(context)
                                      .textTheme.button!.color,
                                ),
                              ),
                              children: [
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("мм.рт.ст.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("мм.рт.ст.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  background: Center(
                                    child: Text("гПа",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ),
                                  foreground: Center(
                                    child: Text("гПа",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                )
                              ],
                              onChanged: (value) {
                                setPressureSelection(value);
                              },
                            )

                          ]),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                  child: Text("Интерфейс",
                      style: TextStyle(
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w600,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                          color: Color.fromRGBO(130, 130, 130, 1)))),
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 8,
                  boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                  color: Theme.of(context).backgroundColor,
                ),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Column(
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Тема",
                                style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color)),
                            NeumorphicToggle(
                              width: MediaQuery.of(context).size.width*0.6,
                              height: MediaQuery.of(context).size.width*0.1,
                              selectedIndex: theme,
                              style: NeumorphicToggleStyle(
                                backgroundColor:
                                Color.fromRGBO(226, 235, 255, 1),
                              ),
                              thumb: Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.convex,
                                  depth: 8,
                                  color: Theme.of(context)
                                      .textTheme.button!.color,
                                ),
                              ),
                              children: [
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("System",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("System",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("Time",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("Time",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  foreground: Center(
                                    child: Text("Light",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                  background: Center(
                                    child: Text("Light",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ),
                                ToggleElement(
                                  background: Center(
                                    child: Text("Dark",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.black)),
                                  ),
                                  foreground: Center(
                                    child: Text("Dark",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white)),
                                  ),
                                )
                              ],
                              onChanged: (value) {
                                setThemeSelection(value);
                              },
                            )
                          ]),
                    )]))
            ]),
      ),
    );
  }
}
