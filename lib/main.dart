import 'package:flutter/rendering.dart';
import 'package:flutter_covid_plot/footer.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_covid_plot/constants.dart';
import 'package:flutter_covid_plot/model/data_series.dart';
import 'package:flutter_covid_plot/model/daily_stat.dart';
import 'package:flutter_covid_plot/layered_chart.dart';
import 'package:flutter_covid_plot/mathutils.dart';
import 'package:flutter_covid_plot/timeline.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  AnimationController _animation;
  List<DailyStat> ausStat;
  List<DailyStat> mysStat;
  List<DailyStat> nzlStat;

  static final double earlyInterpolatorFraction = 0.8;
  static final EarlyInterpolator interpolator =
      EarlyInterpolator(earlyInterpolatorFraction);
  double animationValue = 1.0;
  double interpolatedAnimationValue = 1.0;
  bool timelineOverride = false;

  @override
  void initState() {
    super.initState();

    createAnimation(0);
    loadData();
  }

  void createAnimation(double startValue) {
    _animation?.dispose();
    _animation = AnimationController(
      value: startValue,
      duration: const Duration(milliseconds: 14400),
      vsync: this,
    )..repeat();
    _animation.addListener(() {
      setState(() {
        if (!timelineOverride) {
          animationValue = _animation.value;
          interpolatedAnimationValue = interpolator.get(animationValue);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DataSeries> dataToPlot = List();

    if (nzlStat != null) {
      dataToPlot.add(
          DataSeries("New Zealand", nzlStat.map((e) => e.totalCases).toList()));
    }
    if (ausStat != null) {
      dataToPlot.add(
          DataSeries("Australia", ausStat.map((e) => e.totalCases).toList()));
    }
    if (mysStat != null) {
      dataToPlot.add(
          DataSeries("Malaysia", mysStat.map((e) => e.totalCases).toList()));
    }

    LayeredChart layeredChart = LayeredChart(
        dataToPlot, Constants.monthLabels, interpolatedAnimationValue);

    const double timelinePadding = 60.0;

    var timeline = Timeline(
      days: dataToPlot != null && dataToPlot.length > 0
          ? dataToPlot.last.series.length
          : 0,
      animationValue: interpolatedAnimationValue,
      monthLabels: Constants.monthLabels,
      mouseDownCallback: (double xFraction) {
        setState(() {
          _animation.stop();
          interpolatedAnimationValue = xFraction;
        });
      },
      mouseMoveCallback: (double xFraction) {
        setState(() {
          interpolatedAnimationValue = xFraction;
        });
      },
      mouseUpCallback: () {
        if (!timelineOverride) {
          setState(() {
            createAnimation(
                interpolatedAnimationValue * earlyInterpolatorFraction);
          });
        }
      },
    );

    DateTime currentDate = DateTime.now();

    if (nzlStat != null && nzlStat.length > 0) {
      int max = nzlStat.length;
      int index = (interpolatedAnimationValue * max).toInt();
      index = index >= max ? max - 1 : index;
      currentDate = nzlStat[index].date;
    }

    Column mainColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 50),
        ),
        Text(
          'Cumulative COVID-19 cases',
          style: TextStyle(
            fontSize: 36,
          ),
        ),
        Text(
          "${intl.DateFormat.yMMMd('en-US').format(currentDate)}",
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: !timelineOverride,
                onChanged: (value) {
                  setState(() {
                    timelineOverride = !value;

                    if (timelineOverride) {
                      _animation.stop();
                    } else {
                      createAnimation(interpolatedAnimationValue *
                          earlyInterpolatorFraction);
                    }
                  });
                },
              ),
              Text('Autoplay'),
            ],
          ),
        ),
        Expanded(child: layeredChart),
        Padding(
          padding: const EdgeInsets.only(
              left: timelinePadding, right: timelinePadding, bottom: 40),
          child: timeline,
        ),
        Footer(),
      ],
    );

    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(
            color: Colors.white,
          ),
          bodyText2: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: Scaffold(
        body: Center(
          child: Container(
            color: Constants.backgroundColor,
            child: Directionality(
                textDirection: TextDirection.ltr, child: mainColumn),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future loadData() async {
    String ausStatStr = (await http.get("assets/data/Australia.tsv")).body;
    List<DailyStat> ausStatLoaded = summarizeStatsFromTSV(ausStatStr);

    String mysStatStr = (await http.get("assets/data/Malaysia.tsv")).body;
    List<DailyStat> mysStatLoaded = summarizeStatsFromTSV(mysStatStr);

    String nzlStatStr = (await http.get("assets/data/New_Zealand.tsv")).body;
    List<DailyStat> nzlStatLoaded = summarizeStatsFromTSV(nzlStatStr);

    setState(() {
      this.ausStat = ausStatLoaded;
      this.mysStat = mysStatLoaded;
      this.nzlStat = nzlStatLoaded;
    });
  }

  List<DailyStat> summarizeStatsFromTSV(String statByWeekStr) {
    List<DailyStat> loadedStats = List();
    statByWeekStr.split("\n").forEach((s) {
      List<String> split = s.split("\t");
      if (split.length == 2) {
        DateTime date = DateTime.parse(split[0]);
        DailyStat stat = DailyStat(date, int.parse(split[1]));
        loadedStats.add(stat);
      }
    });

    return loadedStats;
  }
}

void main() {
  runApp(Center(child: MainLayout()));
}
