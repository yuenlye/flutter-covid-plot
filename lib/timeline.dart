import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_covid_plot/constants.dart';
import 'package:flutter_covid_plot/model/month_label.dart';
import 'package:flutter_covid_plot/mathutils.dart';

typedef MouseDownCallback = void Function(double xFraction);
typedef MouseMoveCallback = void Function(double xFraction);
typedef MouseUpCallback = void Function();

class Timeline extends StatefulWidget {
  final int days;
  final double animationValue;
  final List<MonthLabel> monthLabels;

  final MouseDownCallback mouseDownCallback;
  final MouseMoveCallback mouseMoveCallback;
  final MouseUpCallback mouseUpCallback;

  Timeline(
      {@required this.days,
      @required this.animationValue,
      @required this.monthLabels,
      this.mouseDownCallback,
      this.mouseMoveCallback,
      this.mouseUpCallback});

  @override
  State<StatefulWidget> createState() {
    return TimelineState();
  }
}

class TimelineState extends State<Timeline> {
  HashMap<String, TextPainter> labelPainters = HashMap();

  @override
  void initState() {
    super.initState();

    widget.monthLabels.forEach((MonthLabel monthLabel) {
      labelPainters[monthLabel.label] =
          _makeTextPainter(Constants.milestoneTimelineColor, monthLabel.label);
      labelPainters[monthLabel.label + "_red"] =
          _makeTextPainter(Colors.redAccent, monthLabel.label);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragDown: (DragDownDetails details) {
        if (widget.mouseDownCallback != null) {
          widget.mouseDownCallback(
              _getClampedXFractionLocalCoords(context, details.globalPosition));
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (widget.mouseUpCallback != null) {
          widget.mouseUpCallback();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (widget.mouseMoveCallback != null) {
          widget.mouseMoveCallback(
              _getClampedXFractionLocalCoords(context, details.globalPosition));
        }
      },
      child: CustomPaint(
          foregroundPainter: TimelinePainter(
              this, widget.days, widget.animationValue, widget.monthLabels),
          child: Container(
            height: 200,
          )),
    );
  }

  TextPainter _makeTextPainter(Color color, String label) {
    TextSpan span =
        TextSpan(style: TextStyle(color: color, fontSize: 12), text: label);
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    return tp;
  }

  double _getClampedXFractionLocalCoords(
      BuildContext context, Offset globalOffset) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(globalOffset);
    return MathUtils.clamp(localOffset.dx / context.size.width, 0, 1);
  }
}

class TimelinePainter extends CustomPainter {
  TimelineState state;

  Paint mainLinePaint;
  Paint milestoneLinePaint;

  Color lineColor = Colors.white;

  int days;
  double animationValue;

  List<MonthLabel> monthLabels;
  List<int> monthDuration;

  final DateTime initialDay = DateTime.utc(2019, 12, 31);
  DateTime endDay;

  TimelinePainter(
      this.state, this.days, this.animationValue, this.monthLabels) {
    mainLinePaint = Paint();
    mainLinePaint.style = PaintingStyle.stroke;
    mainLinePaint.color = Constants.timelineLineColor;
    milestoneLinePaint = Paint();
    milestoneLinePaint.style = PaintingStyle.stroke;
    milestoneLinePaint.color = Constants.milestoneTimelineColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double labelHeight = 20;
    double labelHeightDoubled = labelHeight * 2;

    double mainLineY = size.height / 2;
    canvas.drawLine(
        Offset(0, mainLineY), Offset(size.width, mainLineY), mainLinePaint);

    double currTimeX = size.width * animationValue;
    canvas.drawLine(
        Offset(currTimeX, labelHeightDoubled),
        Offset(currTimeX, size.height - labelHeightDoubled),
        milestoneLinePaint);

    {
      DateTime currentDay = initialDay;

      for (int day = 0; day < days; day++) {
        double lineHeight = size.height / 32;

        if (currentDay.day == 1) {
          lineHeight = size.height / 32;
        }

        double currX = (day / days.toDouble()) * size.width;
        if (lineHeight > 0) {
          double margin = (size.height - lineHeight) / 2;
          double currTimeXDiff = (currTimeX - currX) / size.width;
          if (currTimeXDiff > 0) {
            var mappedValue =
                MathUtils.clampedMap(currTimeXDiff, 0, 0.025, 0, 1);
            var lerpedColor = Color.lerp(Constants.milestoneTimelineColor,
                Constants.timelineLineColor, mappedValue);
            mainLinePaint.color = lerpedColor;
          } else {
            mainLinePaint.color = Constants.timelineLineColor;
          }
          canvas.drawLine(Offset(currX, margin),
              Offset(currX, size.height - margin), mainLinePaint);
        }

        currentDay = currentDay.add(Duration(days: 1));
      }
    }

    {
      for (int i = 0; i < monthLabels.length; i++) {
        MonthLabel monthLabel = monthLabels[i];
        double currX = (monthLabel.weekNum / days.toDouble()) * size.width;
        var timelineXDiff = (currTimeX - currX) / size.width;
        double maxTimelineDiff = 0.08;
        TextPainter textPainter = state.labelPainters[monthLabel.label];
        if (timelineXDiff > 0 &&
            timelineXDiff < maxTimelineDiff &&
            animationValue < 1) {
          var mappedValue =
              MathUtils.clampedMap(timelineXDiff, 0, maxTimelineDiff, 0, 1);
          var lerpedColor = Color.lerp(
              Colors.redAccent, Constants.milestoneTimelineColor, mappedValue);
          milestoneLinePaint.strokeWidth =
              MathUtils.clampedMap(timelineXDiff, 0, maxTimelineDiff, 6, 1);
          milestoneLinePaint.color = lerpedColor;
        } else {
          milestoneLinePaint.strokeWidth = 1;
          milestoneLinePaint.color = Constants.milestoneTimelineColor;
        }

        double lineHeight = size.height / 2;
        double margin = (size.height - lineHeight) / 2;
        canvas.drawLine(Offset(currX, margin),
            Offset(currX, size.height - margin), milestoneLinePaint);

        if (textPainter != null) {
          textPainter.paint(
              canvas,
              Offset(currX - (size.width * 0.015),
                  size.height - labelHeightDoubled));
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
