import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class About extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPage();
}

class _AboutPage extends State<About> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          onPressed: () => {
            Navigator.pop(context),
          },
          iconSize: 20,
          icon: Icon(Icons.arrow_back_ios_outlined),
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text("О приложении",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color,
                fontFamily: "Manrope",
                fontWeight: FontWeight.w600,
                fontSize: 20)),
        actions: [],
      ),
      body: SafeArea(
          child: Container(
            height:MediaQuery.of(context).size.height*0.08,
            width: MediaQuery.of(context).size.width*0.6,
            margin: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width*0.2,
                MediaQuery.of(context).size.width*0.3,
                MediaQuery.of(context).size.width*0.2, 0),
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.01),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Neumorphic(
              style: NeumorphicStyle(
                  depth: -3,
                  color: Theme.of(context).backgroundColor,
                  shadowLightColor: Theme.of(context).shadowColor,
                  lightSource: LightSource.top,
              ),
              child: Center(
                  child: Text("Weather App",
                      style: TextStyle(
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w800,
                          fontSize:
                              MediaQuery.of(context).size.height * 0.039,
                          color:
                              Theme.of(context).textTheme.bodyText1!.color))),
            ),
          )),
      bottomSheet: Container(
        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height*0.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top:Radius.circular(30)),
            color: Theme.of(context).backgroundColor
        ),
        child: Neumorphic(
          style: NeumorphicStyle(
              depth: 5,
              lightSource: LightSource.top,
              color: Theme.of(context).backgroundColor
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:[
              Container(
                  margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.03),
                  child: Text("by ITMO University",
                    style:TextStyle(
                      fontFamily: "Manrope",
                      fontSize: MediaQuery.of(context).size.height*0.02,
                      fontWeight: FontWeight.w800,
                      color:Theme.of(context).textTheme.bodyText1!.color
                    )
                  )),
              Text("Версия 1.0",
              style: TextStyle(
                fontFamily:"Manrope",
                fontSize: MediaQuery.of(context).size.height*0.015,
                fontWeight: FontWeight.w600,
                  color:Theme.of(context).textTheme.bodyText1!.color
              ),),
              Text("от 30 сентября 2021",
                style: TextStyle(
                    fontFamily:"Manrope",
                    fontSize: MediaQuery.of(context).size.height*0.015,
                    fontWeight: FontWeight.w600,
                    color:Theme.of(context).textTheme.bodyText1!.color
                ),),
              Expanded(
                child:Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Text("2021",
                      style: TextStyle(
                          fontFamily:"Manrope",
                          fontSize: MediaQuery.of(context).size.height*0.015,
                          fontWeight: FontWeight.w600,
                          color:Theme.of(context).textTheme.bodyText1!.color
                      ),),
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
}
