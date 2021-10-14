
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'city_parse.dart';

class Favorites extends StatefulWidget{


  @override
  State<StatefulWidget> createState()=>_FavState();
}
class _FavState extends State<Favorites>{
  bool flag=false;
  Future<void> _removeFav(City city) async {
    await City.removeFavorite(city);
    setState(() {
      flag=!flag;
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor:Theme.of(context).backgroundColor ,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:Theme.of(context).backgroundColor ,
        leading: IconButton(
          onPressed: () => {
            Navigator.pop(context),
          },
          iconSize: 20,
          icon: Icon(Icons.arrow_back_ios_outlined),
          color: Theme.of(context).textTheme.bodyText1!.color,
        ),
        title: Text("Избранные",
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1!.color,
                fontFamily: "Manrope",
                fontWeight: FontWeight.w600,
                fontSize: 20)),
        actions: [],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: SafeArea(
          child: FutureBuilder(
            future:City.getFavorites(),
            builder: (context,AsyncSnapshot<List<City>> snapshot) {
              if(snapshot.connectionState==ConnectionState.done){
                  return SizedBox(
                    height: MediaQuery.of(context).size.height*0.8,
                    child: ListView(
                        children: List.generate(
                      snapshot.data!.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                        children: [
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth:-3,
                              color:Theme.of(context).backgroundColor
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      snapshot.data![index].name!,
                                      style: TextStyle(
                                          fontFamily: "Manrope",
                                          fontSize:
                                              MediaQuery.of(context).size.height * 0.027,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color),
                                    ),
                                    Neumorphic(
                                      style:NeumorphicStyle(

                                        depth:3,
                                        color: Theme.of(context).textTheme.button!.color,
                                      ),
                                      child: IconButton(
                                          onPressed: () =>
                                              _removeFav(snapshot.data![index]),
                                          icon: Icon(
                                            Icons.close,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1!
                                                .color,
                                          )),
                                    )
                                  ]),
                            ),
                          ),
                          Divider(color: Color.fromRGBO(0, 0, 0, 0.15))
                        ],
                      )),
                    )),
                  );
                }
                return LinearProgressIndicator();
              }
          ),
        ),
      ),
    );
  }

}