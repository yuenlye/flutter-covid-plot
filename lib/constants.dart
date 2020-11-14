import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_covid_plot/model/month_label.dart';

class Constants {
  static final Color backgroundColor = const Color(0xFF000020);
  static final Color timelineLineColor = Color(0x60FFFFFF);
  static final Color milestoneColor = Color(0x40FFFFFF);
  static final Color milestoneTimelineColor = Colors.white;

  static final List<MonthLabel> monthLabels = [
    MonthLabel(1, "Jan 2020"),
    MonthLabel(32, "Feb 2020"),
    MonthLabel(61, "Mar 2020"),
    MonthLabel(92, "Apr 2020"),
    MonthLabel(122, "May 2020"),
    MonthLabel(153, "Jun 2020"),
    MonthLabel(183, "Jul 2020"),
    MonthLabel(214, "Aug 2020"),
    MonthLabel(245, "Sep 2020"),
    MonthLabel(275, "Oct 2020"),
    MonthLabel(306, "Nov 2020"),
    // MonthLabel(336, "Dec 2020"),
  ];
}
