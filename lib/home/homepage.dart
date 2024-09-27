import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:chenron/responsible_design/breakpoints.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatelessWidget {
  final double padding;
  const HomePage({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Align(
            alignment: const AlignmentDirectional(0, -1),
            child: Wrap(
                spacing: 0,
                runSpacing: 0,
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                runAlignment: WrapAlignment.start,
                verticalDirection: VerticalDirection.down,
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0, 0),
                    child: Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 10),
                            child: Container(
                              width: Breakpoints.responsiveHeight(context),
                              height: MediaQuery.sizeOf(context).height * 0.3,
                              decoration:
                                  const BoxDecoration(color: Colors.red),
                              child: CircularPercentIndicator(
                                percent: 0.5,
                                radius: 60,
                                lineWidth: 12,
                                animation: true,
                                animateFromLastPercent: true,
                                progressColor: Colors.green,
                                backgroundColor: Colors.grey,
                                center: const Text(
                                  '50%',
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: Breakpoints.responsiveWidth(context),
                            height: MediaQuery.sizeOf(context).height * 0.3,
                            decoration: const BoxDecoration(color: Colors.blue),
                            child: SizedBox(
                                width: 370,
                                height: 230,
                                child: LineChart(
                                  LineChartData(
                                      // read about it in the LineChartData section
                                      ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])));
  }
}
