import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeChartWidget extends StatefulWidget {
  GaugeChartWidget({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData);
}

class _ScreenState extends State<GaugeChartWidget> {
  _ScreenState({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  Widget build(BuildContext context) {
    List<GaugeRange> gaugeRange = [];


    if (templateJson != null) {
      for (int i = 0; i < listData.length; i++) {
        gaugeRange.add(GaugeRange(
            startValue: listData[i]["start"] * 1.0,
            endValue: listData[i]["end"] * 1.0,
            startWidth: 0.265,
            sizeUnit: GaugeSizeUnit.factor,
            endWidth: 0.265,
            color: Constants_data.hexToColor(listData[i]["color"])));
      }
    }

    bool isShowTitle = false;
    if (templateJson["isShowTitle"] == "Y") {
      isShowTitle = true;
    }
    return SfRadialGauge(
      title: isShowTitle ? GaugeTitle(text:templateJson["title"]) : null,
      animationDuration: 3500,
      enableLoadingAnimation: true,
      axes: <RadialAxis>[
        RadialAxis(
            startAngle: 130,
            endAngle: 50,
            minimum: templateJson["min_value"] * 1.0,
            maximum: templateJson["max_value"] * 1.0,
            interval: templateJson["interval"] * 1.0,
            minorTicksPerInterval: 9,
            showAxisLine: false,
            radiusFactor: 0.8,
            labelOffset: 8,
            ranges: gaugeRange,
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.35,
                  widget: Container(
                      child: Text("${templateJson["gauge_title"]}", style: TextStyle(color: Color(0xFFF8B195), fontSize: 16)))),
              GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.8,
                  widget: Container(
                    child: Text(
                      "  ${templateJson["pointer_value"]}  ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ))
            ],
            pointers: <GaugePointer>[
              NeedlePointer(
                value: templateJson["pointer_value"] * 1.0,
                needleLength: 0.6,
                lengthUnit: GaugeSizeUnit.factor,
                needleStartWidth: 0,
                needleEndWidth: 5,
                animationType: AnimationType.easeOutBack,
                enableAnimation: true,
                animationDuration: 1200,
                knobStyle: KnobStyle(
                    knobRadius: 0.06,
                    sizeUnit: GaugeSizeUnit.factor,
                    borderColor: const Color(0xFFF8B195),
                    color: AppColors.white_color,
                    borderWidth: 0.035),
                tailStyle:
                TailStyle(color: const Color(0xFFF8B195), width: 4, lengthUnit: GaugeSizeUnit.factor, length: 0.15),
                needleColor: const Color(0xFFF8B195),
              )
            ],
            axisLabelStyle: GaugeTextStyle(fontSize: 10),
            majorTickStyle: MajorTickStyle(length: 0.25, lengthUnit: GaugeSizeUnit.factor, thickness: 1.5),
            minorTickStyle: MinorTickStyle(length: 0.13, lengthUnit: GaugeSizeUnit.factor, thickness: 1))
      ],
    );
  }


}
