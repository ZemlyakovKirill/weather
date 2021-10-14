import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:untitled/weatherparse.dart';

Container bottomSheet(
    {required BuildContext context,
    required String date,
    required Weather wth,
    required String tempStr,
    required String windStr,
    required String pressureStr,
    required bool isClosed,
    required double lat,
    required double lon,
    required List<SimpleWeather> listTimeWth}) {
  if (!isClosed) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            shape: BoxShape.rectangle),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(
              child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Theme.of(context).textTheme.bodyText2!.color,
            ),
          )),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 25),
              child: Text(date,
                  style: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                4,
                                (index) => Neumorphic(
                                    style: NeumorphicStyle(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        depth: 1),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7, horizontal: 11),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat("H:mm").format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    (listTimeWth)[
                                                                index]
                                                            .dt *
                                                        1000)),
                                            style: TextStyle(
                                                fontFamily: "Manrope",
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .color),
                                          ),
                                          SvgPicture.asset((listTimeWth)[
                                          index].desc,
                                            height: MediaQuery.of(context).size.width*0.1,
                                            width:MediaQuery.of(context).size.width*0.1,
                                            allowDrawingOutsideViewBox: true,),
                                          Text(
                                            (listTimeWth)[index]
                                                    .temp
                                                    .floor()
                                                    .toString() +
                                                tempStr,
                                            style: TextStyle(
                                                fontFamily: "Manrope",
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .color),
                                          ),
                                        ],
                                      ),
                                    )))),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 2),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                        depth: 1, color: Theme.of(context).backgroundColor),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.thermostat_rounded,
                                color: Color.fromRGBO(177, 177, 177, 1),
                                size: MediaQuery.of(context).size.height * 0.04,
                              ),
                              Text(wth.feelsLike.floor().toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  )),
                              Text(tempStr,
                                  style: TextStyle(
                                    color: Color.fromRGBO(177, 177, 177, 1),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ))
                            ])),
                  ),
                  Neumorphic(
                    style: NeumorphicStyle(
                        depth: 1, color: Theme.of(context).backgroundColor),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.water_outlined,
                                color: Color.fromRGBO(177, 177, 177, 1),
                                size: MediaQuery.of(context).size.height * 0.04,
                              ),
                              Text(wth.humidity.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  )),
                              Text("%",
                                  style: TextStyle(
                                    color: Color.fromRGBO(177, 177, 177, 1),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ))
                            ])),
                  ),
                ],
              )
            ]),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 2),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Neumorphic(
                    style: NeumorphicStyle(
                      depth: 1,
                      lightSource: LightSource.topLeft,
                      color: Theme.of(context).backgroundColor,
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.air_outlined,
                                color: Color.fromRGBO(177, 177, 177, 1),
                                size: MediaQuery.of(context).size.height * 0.04,
                              ),
                              Text(wth.windSpeed.floor().toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  )),
                              Text(windStr,
                                  style: TextStyle(
                                    color: Color.fromRGBO(177, 177, 177, 1),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ))
                            ])),
                  ),
                  Neumorphic(
                    style: NeumorphicStyle(
                        depth: 1, color: Theme.of(context).backgroundColor),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.compress_outlined,
                                color: Color.fromRGBO(177, 177, 177, 1),
                                size: MediaQuery.of(context).size.height * 0.04,
                              ),
                              Text(wth.pressure.floor().toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  )),
                              Text(pressureStr,
                                  style: TextStyle(
                                    color: Color.fromRGBO(177, 177, 177, 1),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ))
                            ])),
                  ),
                ],
              )
            ]),
          )
        ]));
  } else {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            shape: BoxShape.rectangle),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Center(
              child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              color: Theme.of(context).textTheme.bodyText2!.color,
            ),
          )),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child:Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                                4,
                                (index) => Neumorphic(
                                    style: NeumorphicStyle(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        depth: 1),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 7, horizontal: 11),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).backgroundColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat("H:mm",).format(DateTime
                                                .fromMillisecondsSinceEpoch(
                                                    (listTimeWth)[
                                                                index]
                                                            .dt *
                                                        1000)),
                                            style: TextStyle(
                                                fontFamily: "Manrope",
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .color),
                                          ),
                                          SvgPicture.asset((listTimeWth)[
                                          index].desc,
                                          height: MediaQuery.of(context).size.width*0.1,
                                          width:MediaQuery.of(context).size.width*0.1,
                                            allowDrawingOutsideViewBox: true,),
                                          Text(
                                            (listTimeWth)[index]
                                                    .temp
                                                    .floor()
                                                    .toString() +
                                                tempStr,
                                            style: TextStyle(
                                                fontFamily: "Manrope",
                                                fontSize: 17,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .color),
                                          ),
                                        ],
                                      ),
                                    )))),
          ),
          Container(
              margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .color!)))),
                  onPressed: null,
                  child: Text("Прогноз на неделю",
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyText2!.color,
                      ))))
        ]));
  }
}
