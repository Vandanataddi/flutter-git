import 'package:data_table_2/data_table_2.dart';
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:horizontal_data_table/horizontal_data_table.dart';


class TableWidget extends StatefulWidget {
  TableWidget({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;

  @override
  _ScreenState createState() => _ScreenState(templateJson: templateJson, listData: listData);
}

class _ScreenState extends State<TableWidget> {
  _ScreenState({@required this.templateJson, @required this.listData});

  Map<String, dynamic> templateJson;
  List<dynamic> listData;
  int freezColumns;
  String header_bg_color = "#d3d3d3";
  String header_text_color = "#000000";
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {

    // Check if listData is null or empty
    if (listData[0] == null || listData[0].isEmpty) {
      return Center(
        child: Text('No data available'),
      );
    }


    themeData = Theme.of(context);
    freezColumns = templateJson["FreezColumn"] == null || templateJson["FreezColumn"].toString() == "" ? 0 : int.parse(templateJson["FreezColumn"].toString());

    double freezColumn = freezColumns * 1.0;
    List<dynamic> columns = getColumnsFromJson(listData[0]);
    List<dynamic> rows = getRowsFromJson(listData);
    List<dynamic> displayColumns = templateJson["DisplayColumnList"].toString().split(",");
    // header_bg_color = templateJson["header_bg_color"].toString();
    // header_text_color = templateJson["header_text_color"].toString();
    double singleBlockWidth = Constants_data.getWidth(context, 100);
    double freezColumnWidth = freezColumn * singleBlockWidth;
    double normalColumnWidth = (columns.length - freezColumn) * singleBlockWidth;
    print("normalColumnWidth : ${normalColumnWidth}");
    double leftSideWidth;
    double rightSideWidth;


    if (columns.length == 4) {
      double mainWidth = (MediaQuery.of(context).size.width - 15) / 4;

      if (freezColumn == 0) {
        leftSideWidth = 0;
        rightSideWidth = mainWidth * 4;
      }
      else if (freezColumn == 1) {
        leftSideWidth = mainWidth;
        rightSideWidth = mainWidth * 3;
      }
      else if (freezColumn == 2) {
        leftSideWidth = mainWidth * 2;
        rightSideWidth = mainWidth * 2;
      }
      else if (freezColumn == 3) {
        leftSideWidth = mainWidth * 3;
        rightSideWidth = mainWidth;
      }
      else if (freezColumn == 4) {
        leftSideWidth = mainWidth * 4;
        rightSideWidth = 0;
      }
    }
    else if (columns.length == 3) {
      double mainWidth = (MediaQuery.of(context).size.width - 15) / 3;
      if (freezColumn == 0) {
        leftSideWidth = 0;
        rightSideWidth = mainWidth * 3;
      }
      else if (freezColumn == 1) {
        leftSideWidth = mainWidth;
        rightSideWidth = mainWidth * 2;
      }
      else if (freezColumn == 2) {
        leftSideWidth = mainWidth * 2;
        rightSideWidth = mainWidth;
      }
      else if (freezColumn == 3) {
        leftSideWidth = mainWidth * 3;
        rightSideWidth = 0;
      }
    }
    else if (columns.length == 2) {
      double mainWidth = (MediaQuery.of(context).size.width - 15) / 2;
      if (freezColumn == 0) {
        leftSideWidth = 0;
        rightSideWidth = mainWidth * 2;
      }
      else if (freezColumn == 1) {
        leftSideWidth = mainWidth;
        rightSideWidth = mainWidth;
      }
      else if (freezColumn == 2) {
        leftSideWidth = mainWidth * 2;
        rightSideWidth = 0;
      }
    }
    else {
      leftSideWidth = freezColumnWidth;
      rightSideWidth = normalColumnWidth;
    }

    double totalHeight = MediaQuery.of(context).size.height - Constants_data.getHeight(context, 200);
    double singleBlockHeight = Constants_data.getHeight(context, 52);
    double viewHeight = totalHeight;

    if ((singleBlockHeight * listData.length) + Constants_data.getHeight(context, 52) < totalHeight) {
      viewHeight = (singleBlockHeight * listData.length) + Constants_data.getHeight(context, 52);
    }

    return Container(
      // margin: EdgeInsets.only(bottom: Constants_data.getHeight(context, 10)),
      // child: Stack(
      //   children: [
      //     Positioned.fill(
      //       top: Constants_data.getFontSize(context, -25),
      //       left: 0,
      //       right: 0,
      //
      //       child: HorizontalDataTable(
      //         leftHandSideColumnWidth: leftSideWidth,
      //         rightHandSideColumnWidth: rightSideWidth,
      //         isFixedHeader: true,
      //         headerWidgets: _getTitleWidget(freezColumn, displayColumns, freezColumnWidth, singleBlockWidth, context),
      //         leftSideItemBuilder: (BuildContext context, int index) {
      //           return _generateFirstColumnRow(context, index, columns, freezColumn, listData, singleBlockWidth);
      //         },
      //         rightSideItemBuilder: (BuildContext context, int index) {
      //           return _generateRightHandSideColumnRow(
      //               context, index, columns, freezColumn, listData, singleBlockWidth);
      //         },
      //         itemCount: listData.length,
      //         enablePullToRefresh: false,
      //         enablePullToLoadNewData: false,
      //       ),
      //     )
      //   ],
      // ),
      // height: viewHeight + Constants_data.getHeight(context, 13),
      margin: EdgeInsets.only(bottom: Constants_data.getHeight(context, 10)),
      child: Stack(
        children: [
          Positioned.fill(
            // top: Constants_data.getFontSize(context, -25),
            left: 0,
            right: 0,

            child:
            DataTable2(
              border: TableBorder.all(color: AppColors.light_grey_color),
              columnSpacing: 2,
                horizontalMargin: 2,
                fixedLeftColumns: freezColumns,
                headingTextStyle: TextStyle(color: Constants_data.hexToColor(header_text_color)),
                headingRowColor: MaterialStateProperty.all(Constants_data.hexToColor(header_bg_color)),
                dataRowHeight: singleBlockHeight,
                // decoration: BoxDecoration(),
                // columnSpacing: 12,
                // horizontalMargin: 12,
                minWidth:500,
                columns: displayColumns.map(

                  ((dynamic element) => DataColumn(
                    label: Center(child: Container(width: 800,child: Text("$element",maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center, style: TextStyle(fontSize: Constants_data.getFontSize(context, 12)),),))
                  )),
                ).toList(),
                // [ DataColumn2(
                //   label: Text('Column A'),
                //   size: ColumnSize.L,
                // ),
                //   DataColumn(
                //     label: Text('Column B'),
                //   ),
                //   DataColumn(
                //     label: Text('Column C'),
                //   ),
                //   DataColumn(
                //     label: Text('Column D'),
                //   ),
                //   DataColumn(
                //     label: Text('Column NUMBERS'),
                //     numeric: true,
                //   ),],
                rows:
                rows.map((dynamic e) {
                  return DataRow(
                      cells: e.map<DataCell>((dynamic e) =>
                          DataCell(Container(width: 800,child: Center(child:
                          Text(e.trim(),textAlign: TextAlign.center,))),)).toList());}).toList(),

                // listData[0].map((name) => return DataRow(
                //     cells:  [name].map<DataCell>((e) => DataCell(Text(e)))
                //         .toList())
                //   )
                // ).toList()
                // List<DataRow>.generate(
                //     100,
                //         (index) => DataRow(cells: [
                //       DataCell(Text('A' * (10 - index % 10))),
                //       DataCell(Text('B' * (10 - (index + 5) % 10))),
                //       DataCell(Text('C' * (15 - (index + 5) % 10))),
                //     ]))

            )

            // HorizontalDataTable(
            //   leftHandSideColumnWidth: leftSideWidth,
            //   rightHandSideColumnWidth: rightSideWidth,
            //   isFixedHeader: true,
            //   headerWidgets: _getTitleWidget(freezColumn, displayColumns, freezColumnWidth, singleBlockWidth, context),
            //   leftSideItemBuilder: (BuildContext context, int index) {
            //     return _generateFirstColumnRow(context, index, columns, freezColumn, listData, singleBlockWidth);
            //   },
            //   rightSideItemBuilder: (BuildContext context, int index) {
            //     return _generateRightHandSideColumnRow(
            //         context, index, columns, freezColumn, listData, singleBlockWidth);
            //   },
            //   itemCount: listData.length,
            //   enablePullToRefresh: false,
            //   enablePullToLoadNewData: false,
            // ),
          )
        ],
      ),
      height: viewHeight + Constants_data.getHeight(context, 13),

    );
  }

  List<Widget> _getTitleWidget(freezColumn, columns, freezColumnWidth, singleBlockWidth, context) {
    List<Widget> lstWidget = [];
    if (freezColumn != 0) {
      String fc = "";
      for (int i = 0; i < freezColumn; i++) {
        fc += columns[i] + "~";
      }
      fc = fc.substring(0, fc.length - 1);
      print("FreezColumn : ${fc}");

      for (int i = 0; i < columns.length; i++) {
        if (i == freezColumn - 1) {
          print("add here ${i}");
          lstWidget.add(_getTitleItemWidget(fc, freezColumnWidth, columns.length, context));
        } else if (i < freezColumn) {
          print("Nothing do here ${i}");
        } else {
          lstWidget.add(_getTitleItemWidget(columns[i], singleBlockWidth, columns.length, context));
        }
      }
    } else {
      for (int i = 0; i < columns.length; i++) {
        if (i == 0) {
          lstWidget.add(_getTitleItemWidget(columns[i], singleBlockWidth, columns.length, context));
        }
        lstWidget.add(_getTitleItemWidget(columns[i], singleBlockWidth, columns.length, context));
      }
    }
    return lstWidget;
  }

  Widget _getTitleItemWidget(String label, double width, int columnSize, context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    final bool useMobileLayout = shortestSide < 600;
    List<Widget> rows = [];
    List<String> names = label.split("~");
    double singleWidth = width / names.length;
    for (int i = 0; i < names.length; i++) {
      if (columnSize > 4) {
        rows.add(Container(
          padding: EdgeInsets.only(top: useMobileLayout ? 0 : 20),
          color: Constants_data.hexToColor(header_bg_color),
          child: Text(names[i].trim(),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: Constants_data.getFontSize(context, 12),
                  fontWeight: FontWeight.bold,
                  color: Constants_data.hexToColor(header_text_color))),
          width: singleWidth,
          height: Constants_data.getHeight(context, 52),
          alignment: Alignment.center,
        ));
      } else {
        rows.add(Container(
          padding: EdgeInsets.only(top: useMobileLayout ? 0 : 20),
          color: Constants_data.hexToColor(header_bg_color),
          child: Center(
              child: Text(names[i].trim(),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: Constants_data.getFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                      color: Constants_data.hexToColor(header_text_color)))),
          width: (MediaQuery.of(context).size.width - 15) / columnSize,
          height: Constants_data.getHeight(context, 52),
          alignment: Alignment.center,
        ));
      }
    }
    return new Row(
      children: rows,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index, columns, freezColumn, mainData, singleBlockWidth) {
    List<Widget> row = [];
    for (int i = 0; i < columns.length; i++) {
      if (i < freezColumn) {
        if (columns.length > 4) {
          row.add(Container(
            decoration: BoxDecoration(
                color: themeData.cardColor,
                border: Border.all(
                  width: 0.5,
                  color: AppColors.black_color26,
                )),
            child: Align(
                alignment: FractionalOffset.center,
                child: Text(
                  '${mainData[index][columns[i]]}',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: Constants_data.getFontSize(context, 12),
                  ),
                  textAlign: TextAlign.center,
                )),
            width: singleBlockWidth,
            height: Constants_data.getHeight(context, 52),
            padding: EdgeInsets.fromLTRB(Constants_data.getHeight(context, 5), 0, 0, 0),
            alignment: Alignment.centerLeft,
          ));
        }
        else {
          row.add(Container(
            decoration: BoxDecoration(
                color: themeData.cardColor,
                border: Border.all(width: 0.5, color: AppColors.black_color26)
            ),
            child: Align(
                alignment: FractionalOffset.center,
                child: Text(
                  '${mainData[index][columns[i]]}',
                  maxLines: 3,
                  style: TextStyle(fontSize: Constants_data.getFontSize(context, 12)),
                  textAlign: TextAlign.center,
                )),
            width: (MediaQuery.of(context).size.width - 15) / columns.length,
            height: Constants_data.getHeight(context, 52),
            padding: EdgeInsets.fromLTRB(Constants_data.getHeight(context, 5), 0, 0, 0),
            alignment: Alignment.centerLeft,
          ));
        }
      }
    }

    return new Row(
      children: row,
    );
  }

  Widget _generateRightHandSideColumnRow(
      BuildContext context, int index, columns, freezColumn, mainData, singleBlockWidth) {
    List<Widget> row = [];
    for (int i = 0; i < columns.length; i++) {
      if (i > freezColumn - 1) {
        if (columns.length > 4) {
          row.add(Container(
            decoration: BoxDecoration(
                color: themeData.cardColor,
                border: Border.all(
                  width: 0.5,
                  color: AppColors.black_color26,
                )),
            child: Align(
                alignment: FractionalOffset.center,
                child: Text(
                  '${mainData[index][columns[i]]}',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: Constants_data.getFontSize(context, 12),
                  ),
                  textAlign: TextAlign.center,
                )),
            width: singleBlockWidth,
            height: Constants_data.getHeight(context, 52),
            padding: EdgeInsets.fromLTRB(Constants_data.getHeight(context, 5), 0, 0, 0),
            alignment: Alignment.centerLeft,
          ));
        } else {
          row.add(Container(
            decoration: BoxDecoration(
                color: themeData.cardColor,
                border: Border.all(
                  width: 0.5,
                  color: AppColors.black_color26,
                )),
            child: Align(
                alignment: FractionalOffset.center,
                child: Text(
                  '${mainData[index][columns[i]]}',
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: Constants_data.getFontSize(context, 12),
                  ),
                  textAlign: TextAlign.center,
                )),
            width: (MediaQuery.of(context).size.width - 15) / columns.length,
            height: Constants_data.getHeight(context, 52),
            padding: EdgeInsets.fromLTRB(Constants_data.getHeight(context, 5), 0, 0, 0),
            alignment: Alignment.centerLeft,
          ));
        }
      }
    }
    return Row(children: row);
  }
  List<String> columns = [];
  getColumnsFromJson(var sampleJson) {

    Map<String, dynamic> obj = sampleJson;
    for (var colName in obj.keys) {
      columns.add(colName);
    }
    return columns;
  }

  // getRowsFromJson(var sampleJson) {
  //   // List<String> rows = [];
  //   List showCurrencyFormat = templateJson["currency_column"].toString().split(",");
  //   List<List<dynamic>> rows = [];
  //   List<dynamic> Temp =[];
  //   for(int i = 0 ; i < sampleJson.length ; i++){
  //     Map<String, dynamic> obj = sampleJson[i];
  //
  //     for(var rowName in obj.entries ) {
  //       for(int k = 0 ; k < showCurrencyFormat.length ;k++){
  //         if(rowName.key != showCurrencyFormat[k]){
  //           Temp.add(rowName.value.toString());
  //           break;
  //
  //         }
  //         // Temp.add(rowName.value.toString());
  //     if(rowName.key == showCurrencyFormat[k]){
  //           Temp.add(rowName.value.toString());
  //           break;
  //
  //         }
  //       }
  //       Temp.add(rowName.value.toString());
  //
  //     }
  //     rows.add([Temp]);
  //     // for (var rowName in obj.values) {
  //     // rows.add([ for(var rowName in obj.values ) rowName.toString() ]);
  //
  //
  //     // rows.add([ for(var rowName in obj.values )i >1 ? Text("%${rowName.toString()}") : Text("${rowName.toString()}")]);
  //     //   rows.add([ for(var rowName in obj.values ) i > 3 ? "₹${rowName.toString()}" : "${rowName.toString()}"]);
  //     //   rows.add([ for(int j = 0 ; j < obj.length ;j++) j > 3 ? "₹${obj[j].toString()}" : "${obj[j].values.toString()}"]);
  //     // }
  //   }
  //   // Map<String, dynamic> obj = sampleJson;
  //
  //
  //   return rows;
  // }

  getRowsFromJson(var sampleJson) {
    // List<String> rows = [];
    List showCurrencyFormat = templateJson["currency_column"].toString().split(",");
    List<List<dynamic>> rows = [];
    List<dynamic> rowsData =[];
    bool addCurrency = false;
    final currency_format = new NumberFormat("${templateJson["currency_formate"]}", "en_IN");
    for(int i = 0 ; i < sampleJson.length ; i++){
      Map<String, dynamic> obj = sampleJson[i];
      rowsData = [];
      for(var rowName in obj.entries ){
        for(int j = 0 ; j < showCurrencyFormat.length ; j++){
          if(rowName.key == showCurrencyFormat[j]){
            // String formatedValue = (currancy_format.format(rowName.value)).toString();
            // // withCurrency.add("${templateJson["currency_symbol"]}${currancy_format.format(int.parse(rowName.value).toString())}");
            // withCurrency.add((templateJson["currency_symbol"].toString()+formatedValue.toString()).toString());
            // break;
            addCurrency = true;
            break;
          }

        }
        addCurrency ?  rowsData.add((templateJson["currency_symbol"].toString()+(currency_format.format(rowName.value)).toString()).toString()) : rowsData.add(rowName.value.toString());
        addCurrency = false;
        // break;
      }
      rows.add(rowsData);

        // rows.add([ for(var rowName in obj.entries ) rowName.value.toString()]);
    }


    return rows;
  }

  // getRowsFromJson(var sampleJson) {
  //   // List<String> rows = [];
  //   List showCurrencyFormat = templateJson["currency_column"].toString().split(",");
  //   List<List<dynamic>> rows = [];
  //   List<dynamic> withoutCurrency =[];
  //   List<dynamic> withCurrency =[];
  //   final currancy_format = new NumberFormat("${templateJson["currency_formate"]}", "en_IN");
  //   for(int i = 0 ; i < sampleJson.length ; i++){
  //     Map<String, dynamic> obj = sampleJson[i];
  //     withCurrency = [];
  //     for(var rowName in obj.entries ){
  //       for(int j = 0 ; j < showCurrencyFormat.length ; j++){
  //         if(rowName.key.toString() == showCurrencyFormat[j].toString()){
  //           String formatedValue = (currancy_format.format(rowName.value)).toString();
  //           // withCurrency.add("${templateJson["currency_symbol"]}${currancy_format.format(int.parse(rowName.value).toString())}");
  //           withCurrency.add((templateJson["currency_symbol"].toString()+formatedValue.toString()).toString());
  //           break;
  //         }
  //         withCurrency.add(rowName.value.toString());
  //         break;
  //       }
  //     }
  //     rows.add(withCurrency);
  //
  //     // rows.add([ for(var rowName in obj.entries ) rowName.value.toString()]);
  //   }
  //
  //
  //   return rows;
  // }
}
