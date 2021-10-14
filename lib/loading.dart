
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Scaffold loading(context) =>
 Scaffold(
    appBar:null,
    body:Container(
      color: Theme.of(context).backgroundColor,
      constraints: BoxConstraints.expand(),
      child:
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 100, 0, 100),
          child: Text("Weather App",
              style: TextStyle(
                  fontFamily: "Manrope",
                  fontWeight: FontWeight.w600,
                  fontSize: 35,
                  color: Theme.of(context).textTheme.bodyText1!.color)
              )
          ),
          CircularProgressIndicator(
            color: Theme.of(context).textTheme.bodyText1!.color,
          )
    ]
)));

