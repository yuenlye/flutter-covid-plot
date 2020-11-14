import 'package:flutter/material.dart';
import 'package:flutter_covid_plot/hyperlink.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Data sourced from "),
              Hyperlink("Our World In Data",
                  "https://github.com/owid/covid-19-data/tree/master/public/data"),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
              ),
              Text("Inspired by "),
              Hyperlink("Flutter Data Visualization sample",
                  "https://github.com/flutter/samples/tree/master/web/github_dataviz"),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Created with Flutter Web by "),
              Hyperlink("Yuen Lye Yeap", "https://github.com/yuenlye"),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
          ),
        ],
      ),
    );
  }
}
