import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'city_parse.dart';

class Search extends StatefulWidget {
  void Function(double, double,String) callback;

  Search({Key? key, required void Function(double, double,String) callback})
      : callback = callback,
        super(key: key);

  @override
  State<Search> createState() => _SearchPage(callback);
}

class _SearchPage extends State<Search> {
  _SearchPage(void Function(double, double,String) cb) : callback = cb;
  final TextEditingController _cityText = TextEditingController();
  final void Function(double, double,String) callback;
  bool flag = false;
  String city = "";

  void cityUpdate(String value) {
    setState(() {
      city = value;
    });
  }

  void flagchange() {
    setState(() {
      flag = !flag;
    });
  }
  ScrollController favController=ScrollController(initialScrollOffset: 0);
  ScrollController srchController=ScrollController(initialScrollOffset: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            iconSize: MediaQuery.of(context).size.width * 0.07,
            icon: Icon(Icons.arrow_back_ios_outlined),
            color: Theme.of(context).textTheme.bodyText1!.color,
          ),
          actions: [
            StatefulBuilder(
              builder: (context,StateSetter sState) {
                bool localFlag=false;
                return Row(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.60,
                            height: MediaQuery.of(context).size.width * 0.1,
                            child: TextField(
                                controller: _cityText,
                                style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).textTheme.bodyText1!.color),
                                onSubmitted: (val) => {cityUpdate(val)},
                                onChanged: (_)=>sState(() {
                                  localFlag=!localFlag;
                                }),
                                maxLines: 1,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Введите наименование города...",
                                    hintStyle: TextStyle(
                                        color: Color.fromRGBO(130, 130, 130, 1))))),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        if(_cityText.text.isNotEmpty) {
                          return IconButton(
                            icon: Icon(Icons.cancel_outlined,
                                size: MediaQuery.of(context).size.width * 0.07,
                                color: Theme.of(context).textTheme.bodyText1!.color),
                            onPressed: () => sState(()=>_cityText.text = ""),
                          );
                        }
                        else
                          return Container(
                            width:MediaQuery.of(context).size.width * 0.1,
                          );
                    }
                    ),
                  ],
                );
              }
            ),
          ],
        ),
        body: Column(
          children: [
            FutureBuilder<List<City>>(
              future: City.getFavorites(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final cities = snapshot.data as List<City>;
                  return SizedBox(
                    height:MediaQuery.of(context).size.height*0.8,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      controller: favController,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: MediaQuery.of(context).size.width * 0.06,
                              horizontal: MediaQuery.of(context).size.width * 0.08),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[...(cities)
                                    .map((e) => e.getCityAsContainer(
                                        context, callback, () {}))
                                    .toList(),
                                FutureBuilder<List<City>>(
                                  future: City.getCitiesByName(city),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      return Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children:(snapshot.data as List<City>)
                                                      .map((e) => e.getCityAsContainer(
                                                      context, callback, () async {
                                                    await City.addFavorite(e);
                                                    flagchange();
                                                  }))
                                                      .toList());
                                    } else if (snapshot.hasError) {
                                      return Text("Ничего не найдено");
                                    }
                                    return Container(
                                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                                        child: LinearProgressIndicator(
                                          color: Theme.of(context).textTheme.bodyText1!.color,
                                        ));
                                  },
                                ),
                              ]),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: LinearProgressIndicator(
                      color: Theme.of(context).textTheme.bodyText1!.color,
                    ));
              },
            ),
          ],
        ));
  }
}
