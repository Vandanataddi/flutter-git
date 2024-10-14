import 'dart:collection';
import 'dart:convert';

import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_treeview/tree_view.dart';

class TreeViewDemo extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<TreeViewDemo> {
  // List<Node> nodes;
  bool docsOpen = true;
  // TreeViewController _treeViewController;
  List<dynamic> data = [];

  List<dynamic> dataGeo = [
    {"Id": "101", "Description": "India", "Type": "Main", "ParentId": "root"},
    {"Id": "102", "Description": "Gujarat", "Type": "Zone", "ParentId": "101"},
    {"Id": "103", "Description": "Ahmedabad", "Type": "HQ", "ParentId": "102"},
    {"Id": "104", "Description": "Rajkot", "Type": "HQ", "ParentId": "102"},
    {
      "Id": "105",
      "Description": "Abad-East",
      "Type": "Area",
      "ParentId": "103"
    },
    {
      "Id": "106",
      "Description": "Abad-West",
      "Type": "Area",
      "ParentId": "103"
    },
    {"Id": "107", "Description": "Delhi", "Type": "HQ", "ParentId": "101"}
  ];

  List<dynamic> dataTime = [
    {"Id": "101", "Description": "All", "Type": "Main", "ParentId": "root"},
    {
      "Id": "102",
      "Description": "Last Year",
      "Type": "Year",
      "ParentId": "101"
    },
    {
      "Id": "103",
      "Description": "Last Quarter",
      "Type": "Quarter",
      "ParentId": "101"
    },
    {
      "Id": "104",
      "Description": "Last Month",
      "Type": "Month",
      "ParentId": "101"
    },
    {"Id": "105", "Description": "Last Week", "Type": "Week", "ParentId": "101"}
  ];

  List<dynamic> dataProduct = [
    {
      "Id": "100",
      "Description": "All Products",
      "Type": "Main",
      "ParentId": "root"
    },
    {
      "Id": "101",
      "Description": "ANTI ALLERGICS",
      "Type": "DRUG",
      "ParentId": "100"
    },
    {
      "Id": "102",
      "Description": "RAPIDON EYE DROPS",
      "Type": "Product",
      "ParentId": "101"
    },
    {
      "Id": "103",
      "Description": "BESIBACT EYE DROPS",
      "Type": "Product",
      "ParentId": "101"
    },
    {
      "Id": "104",
      "Description": "MOXIGRAM EYE DROPS",
      "Type": "Product",
      "ParentId": "101"
    },
    {
      "Id": "105",
      "Description": "ANTIBIOTICS",
      "Type": "DRUG",
      "ParentId": "100"
    },
    {
      "Id": "106",
      "Description": "MISOPT EYE DROPS",
      "Type": "Product",
      "ParentId": "105"
    },
    {
      "Id": "107",
      "Description": "BETAFREE EYE DROPS",
      "Type": "Product",
      "ParentId": "105"
    },
    {
      "Id": "108",
      "Description": "DILATE EYE DROPS",
      "Type": "Product",
      "ParentId": "105"
    },
    {
      "Id": "109",
      "Description": "MULTI VITAMINS",
      "Type": "DRUG",
      "ParentId": "100"
    },
    {
      "Id": "110",
      "Description": "LUTIVIT CAPSULES",
      "Type": "Product",
      "ParentId": "109"
    },
    {
      "Id": "111",
      "Description": "NEXTANE",
      "Type": "Product",
      "ParentId": "109"
    },
    {
      "Id": "112",
      "Description": "ACETAMIDE-250MG TABLETS",
      "Type": "Product",
      "ParentId": "109"
    },
    {
      "Id": "113",
      "Description": "MOXIGRAM LX",
      "Type": "Product",
      "ParentId": "109"
    },
    {
      "Id": "114",
      "Description": "EYE OINTMENTS",
      "Type": "DRUG",
      "ParentId": "100"
    },
    {
      "Id": "115",
      "Description": "CORNIGEL EYE OINTMENT",
      "Type": "Product",
      "ParentId": "114"
    },
    {
      "Id": "116",
      "Description": "HARPERAX EYE OINTMENT",
      "Type": "Product",
      "ParentId": "114"
    },
    {"Id": "117", "Description": "GLAUCOMA", "Type": "DRUG", "ParentId": "100"},
    {
      "Id": "118",
      "Description": "ALCAFT EYE DROPS",
      "Type": "Product",
      "ParentId": "117"
    },
    {
      "Id": "119",
      "Description": "PREDACE EYE DROPS",
      "Type": "Product",
      "ParentId": "117"
    },
    {"Id": "120", "Description": "MOXIGRAM", "Type": "DRUG", "ParentId": "100"}
  ];

  int selected = 0;
  bool isDataLoaded = false;
  ThemeData themeData;

  final Map<int, Widget> dt = <int, Widget>{
    0: new Container(padding: EdgeInsets.all(5), child: Text("Products")),
    1: new Container(padding: EdgeInsets.all(5), child: Text("Geography")),
    2: new Container(padding: EdgeInsets.all(5), child: Text("Time")),
  };

  @override
  void initState() {
    super.initState();
    dataProduct = modifyData(dataProduct);
    dataTime = modifyData(dataTime);
    dataGeo = modifyData(dataGeo);
    data = dataProduct;
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    if (!isDataLoaded) {
      isDataLoaded = true;
      Map<String, dynamic> result = ModalRoute.of(context).settings.arguments;
      print("Argument received : $result");
      if (result != null) {
        dataGeo = result["Geography"];
        dataTime = result["Time"];
        dataProduct = result["Product"];
        data = dataProduct;
      }
    }

    var rootNode;
    // Node root;
//     for (int i = 0; i < data.length; i++) {
//       if (data[i]["ParentId"] == "root") {
//         rootNode = data[i];
//         root = Node(
//             expanded: true,
//             key: data[i]["Id"],
//             label: "${data[i]["Description"]} (${data[i]["Type"]})");
//       }
//     }
//     var mainMapData = getDataNode(root.key, root, rootNode);
//     if (nodes != null)
//       nodes.clear();
//     else
//       nodes = [];
//     nodes.add(mainMapData);
//     _treeViewController = TreeViewController(children: nodes);
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: AppColors.white_color,
//         appBar: AppBar(
//           title: Text("Filter"),
//           actions: <Widget>[
//             ElevatedButton.icon(
//                 onPressed: () {
//                   dataProduct = modifyData(dataProduct);
//                   dataTime = modifyData(dataTime);
//                   dataGeo = modifyData(dataGeo);
//                   if (selected == 0) {
//                     data = dataProduct;
//                   } else if (selected == 1) {
//                     data = dataGeo;
//                   } else if (selected == 2) {
//                     data = dataTime;
//                   }
//                   this.setState(() {});
//                 },
//                 icon: Icon(
//                   Icons.clear,
//                   color: AppColors.white_color,
//                 ),
//                 label: Text(
//                   "Clear",
//                   style: TextStyle(color: AppColors.white_color),
//                 )),
//             ElevatedButton.icon(
//                 onPressed: () {
//                   bool isSingleSelected = false;
//                   for (int i = 0; i < dataProduct.length; i++) {
//                     if (dataProduct[i]["selected"] == "true") {
//                       isSingleSelected = true;
//                       break;
//                     }
//                   }
//
//                   if (!isSingleSelected) {
//                     for (int i = 0; i < dataTime.length; i++) {
//                       if (dataTime[i]["selected"] == "true") {
//                         isSingleSelected = true;
//                         break;
//                       }
//                     }
//                   }
//
//                   if (!isSingleSelected) {
//                     for (int i = 0; i < dataGeo.length; i++) {
//                       if (dataGeo[i]["selected"] == "true") {
//                         isSingleSelected = true;
//                         break;
//                       }
//                     }
//                   }
//
//                   Map<String, dynamic> result = new HashMap();
//                   result["Geography"] = dataGeo;
//                   result["Time"] = dataTime;
//                   result["Product"] = dataProduct;
//                   Navigator.pop(context, isSingleSelected ? result : null);
//                 },
//                 icon: Icon(
//                   Icons.check_circle,
//                   color: AppColors.white_color,
//                 ),
//                 label: Text(
//                   "Apply",
//                   style: TextStyle(color: AppColors.white_color),
//                 ))
//           ],
//         ),
//         body: Column(
//           children: <Widget>[
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 10),
//               child: CupertinoSegmentedControl<int>(
//                 unselectedColor: themeData.primaryColor,
//                 selectedColor: themeData.accentColor,
//                 borderColor: Colors.grey,
//                 children: dt,
//                 onValueChanged: (int val) {
//                   selected = val;
//                   if (selected == 0) {
//                     data = dataProduct;
//                   } else if (selected == 1) {
//                     data = dataGeo;
//                   } else if (selected == 2) {
//                     data = dataTime;
//                   }
//                   this.setState(() {});
//                 },
//                 groupValue: selected,
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 child: TreeView(
//                   controller: _treeViewController,
//                   allowParentSelect: true,
//                   supportParentDoubleTap: false,
//                   onNodeTap: (key) {
// //              Node selectedNode = _treeViewController.getNode(key);
// //              List<Node> childNodes = selectedNode.children;
// //              print("childNodes:${childNodes.length}");
//
//                     var nodeData;
//                     print("key:$key");
//                     for (int i = 0; i < data.length; i++) {
//                       if (data[i]["Id"] == key) {
//                         data[i]["selected"] =
//                             data[i]["selected"] == "true" ? "false" : "true";
//                         nodeData = data[i];
//                       }
//                     }
//                     selectChild(nodeData);
//                     if (nodeData["selected"] == "false")
//                       deselectParent(nodeData);
//                     else {
//                       selectParent(nodeData);
//                     }
//                     setState(() {});
//                   },
// //              theme: treeViewTheme
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
  return Container();
  }

  modifyData(List data) {
    for (int i = 0; i < data.length; i++) {
      Map<String, dynamic> dt = data[i];

      dt["selected"] = "false";
      String hasChild = "false";
      List<String> listChilds = [];
      List<String> siblings = [];
      for (int j = 0; j < data.length; j++) {
        if (data[i]["Id"] == data[j]["ParentId"]) {
          hasChild = "true";
          listChilds.add(data[j]["Id"]);
        }
        if (data[i]["ParentId"] == data[j]["ParentId"]) {
          siblings.add(data[j]["Id"]);
        }
      }
      dt["hasChild"] = hasChild;
      dt["children"] = listChilds.toString();
      dt["sibling"] = siblings.toString();
      data[i] = dt;
    }
    return data;
    //print("Data Modified : $data");
  }

//  checkAllChild(nodeData) {
//    if (nodeData["hasChild"] == "true") {
//      List<dynamic> child = jsonDecode(nodeData["children"].toString());
//      for (int i = 0; i < child.length; i++) {
//        for (int j = 0; j < data.length; j++) {
//          if (child[i].toString() == data[j]["Id"] && data[j]["selected"] == "false") {
//            return "false";
//          }
//        }
//      }
//    } else {
//      return "false";
//    }
//    return "true";
//  }

  selectChild(nodeData) {
    if (nodeData["hasChild"] == "true") {
      List<dynamic> child = jsonDecode(nodeData["children"].toString());
      for (int i = 0; i < child.length; i++) {
        for (int j = 0; j < data.length; j++) {
          if (child[i].toString() == data[j]["Id"]) {
            data[j]["selected"] = nodeData["selected"];
            selectChild(data[j]);
          }
        }
      }
    }
  }

  deselectParent(nodeData) {
    for (int i = 0; i < data.length; i++) {
      if (data[i]["Id"] == nodeData["ParentId"]) {
        data[i]["selected"] = "false";
        deselectParent(data[i]);
      }
    }
  }

  selectParent(nodeData) {
    List<dynamic> sibling = jsonDecode(nodeData["sibling"].toString());
    bool allSelected = true;
    for (int i = 0; i < sibling.length; i++) {
      for (int j = 0; j < data.length; j++) {
        if (sibling[i].toString() == data[j]["Id"] &&
            data[j]["selected"] == "false") {
          allSelected = false;
          break;
        }
      }
      if (!allSelected) break;
    }
    if (allSelected) {
      for (int i = 0; i < data.length; i++) {
        if (data[i]["Id"] == nodeData["ParentId"]) {
          data[i]["selected"] = "true";
          selectParent(data[i]);
        }
      }
    }
  }

  getData(String master, var node) {
    //Map<String, dynamic> dt = new HashMap();
    try {
      List<dynamic> list = [];
      for (int i = 0; i < data.length; i++) {
        if (data[i]["ParentId"] == master) {
          list.add(getData(data[i]["Id"], data[i]));
        }
      }
      if (list.isNotEmpty) {
        print(list);
        node["children"] = list;
      } else {
        node["children"] = null;
      }
      //dt[master] = list;
      //list.isEmpty ? list.add("End Node") : list;
    } on Exception catch (err) {
      print(node);
    }
    return node;
  }

  // getDataNode(String master, Node node, var rootNode) {
  //   List<Node> list = [];
  //   //Node nd;
  //   for (int i = 0; i < data.length; i++) {
  //     if (data[i]["ParentId"] == master) {
  //       list.add(getDataNode(
  //           data[i]["Id"],
  //           Node(
  //               expanded: true,
  //               key: data[i]["Id"],
  //               label: "${data[i]["Description"]} (${data[i]["Type"]})",
  //               icon: NodeIcon(
  //                   codePoint: Icons.check_box.codePoint,
  //                   color: data[i]["selected"] == "true" ? "blue" : "grey")),
  //           data[i]));
  //     }
  //   }
  //   if (list.isNotEmpty) {
  //     //print("RootNode = ${rootNode}");
  //     node = new Node(
  //         expanded: true,
  //         key: node.key,
  //         label: node.label,
  //         icon: NodeIcon(
  //             codePoint: Icons.check_box.codePoint,
  //             color: rootNode["selected"] == "true" ? "blue" : "grey"),
  //         children: list);
  //     //node.children = list;
  //   }
  //   return node;
  // }
}
