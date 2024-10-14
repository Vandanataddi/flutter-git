import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class GlobalSearchScreen extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<GlobalSearchScreen> {
  TextEditingController cntSearch = new TextEditingController();

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        centerTitle: true,
        title: Text("Search"),
        actions: [
          MaterialButton(
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: TextFormField(
                style: TextStyle(color: themeData.primaryColorLight),
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    contentPadding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                    labelText: "Search",
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                      ),
                    ),
                    prefixIcon: Container(
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        print("Filter");
                      },
                    )),
                keyboardType: TextInputType.text,
              ),
            ),
            Expanded(
                child: Container(
              color: Colors.black12,
            ))
          ],
        ),
      ),
    );
  }
}
