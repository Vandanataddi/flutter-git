
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class PDFViewerMain extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<PDFViewerMain> {
  // PDFDocument document;

  @override
  void initState() {
    super.initState();
  }

  loadPDF(String args) async {
    print("Loading doc : ${args}");
    // document = await PDFDocument.fromURL(args);
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Map<String, String> args = ModalRoute.of(context).settings.arguments;
//    String args = "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf";
    String title = "";
    if (args["title"] != null) {
      title = args["title"];
    }
    return MaterialApp(
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
          leading: IconButton(
            icon: Icon(
              PlatformIcons(context).back,
              color: Theme.of(context).primaryColorLight,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: new Text("${title}"),
        ),
        body: Center(
            child: args != null && args["url"] != null
                ? FutureBuilder<dynamic>(
                    future: loadPDF(args["url"]),
                    // future: loadPDF("http://conorlastowka.com/book/CitationNeededBook-Sample.pdf"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(child: Text("UnComment below line"));
                        // return PDFViewer(document: document,pickerButtonColor: Theme.of(context).cardColor);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : new Text("Error in loading")),
      ),
    );
  }
}
