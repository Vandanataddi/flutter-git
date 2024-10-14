import 'package:flexi_profiler/Screens/AccountDetailsScreen.dart';
import 'package:flexi_profiler/Screens/AccountListScreen.dart';
import 'package:flexi_profiler/Screens/AllowanceScreen.dart';
import 'package:flexi_profiler/Screens/AssistanceScreen.dart';
import 'package:flexi_profiler/Screens/CalendarScreen.dart';
import 'package:flexi_profiler/Screens/CalendarScreenDefault.dart';
import 'package:flexi_profiler/Screens/CalendarScreenAll.dart';
import 'package:flexi_profiler/Screens/CalendarScreenMain.dart';
import 'package:flexi_profiler/Screens/DCREntry_new.dart';
import 'package:flexi_profiler/Screens/DCREntry_without_MTP.dart';
import 'package:flexi_profiler/Screens/DCR_Summary.dart';
import 'package:flexi_profiler/Screens/DashBoardFullScreen.dart';
import 'package:flexi_profiler/Screens/DashboardScreen.dart';
import 'package:flexi_profiler/Screens/DeviationScreen.dart';
import 'package:flexi_profiler/Screens/GlobalSearchScreen.dart';
import 'package:flexi_profiler/Screens/GoogleMapDirectionScreen.dart';
import 'package:flexi_profiler/Screens/HomeScreenRMT.dart';
import 'package:flexi_profiler/Screens/InboxDetailsScreen.dart';
import 'package:flexi_profiler/Screens/Login.dart';
import 'package:flexi_profiler/Screens/PDFViewer.dart';
import 'package:flexi_profiler/Screens/POBScreen.dart';
import 'package:flexi_profiler/Screens/POBSummaryScreen.dart';
import 'package:flexi_profiler/Screens/RMTCallScreen.dart';
import 'package:flexi_profiler/Screens/SplashScreen.dart';
import 'package:flexi_profiler/Screens/TreeViewDemo.dart';
import 'package:flexi_profiler/Screens/ZipExtrator.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Provider/provider_layout.dart';
import 'Screens/CardListScreen.dart';
import 'Screens/DCR_Entry_Details.dart';
import 'Screens/DataTableScreen1.dart';
import 'Screens/DemoScreen.dart';
import 'Screens/FGOInvoiceScreen.dart';
import 'Screens/FormControlWithTemplateJson.dart';
import 'Screens/HomeScreenNew.dart';
import 'Screens/InboxListingScreen.dart';
import 'Screens/FgoList.dart';
import 'Screens/MapActivity.dart';
import 'Screens/Settings.dart';
import 'Theme/StyleClass.dart';
import 'Screens/DataScreen.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return ChangeNotifierProvider(
      create: (_) {
        print("Called : Test");
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            initialRoute: "/SplashScreen",
            routes: <String, WidgetBuilder>{
              '/SplashScreen': (BuildContext context) => new SplashScreen(),
              '/DemoScreen': (BuildContext context) => new DemoScreen(),
              '/TreeViewDemo': (BuildContext context) => new TreeViewDemo(),
              '/POB_Screen': (BuildContext context) => new POB_Screen(),
              '/HomeScreenNew': (BuildContext context) => new HomeScreenNew(),
              '/HomeScreenRMT': (BuildContext context) => new HomeScreenRMT(),
              '/DCR_Summary': (BuildContext context) => new DCR_Summary(),
              '/FgoList': (BuildContext context) =>  FgoList(),
              '/DataTableScreen1': (BuildContext context) =>  DataTableScreen1(),
              '/FGOInvoiceScreen': (BuildContext context) =>  FGOInvoiceScreen(),
              '/CardListScreen': (BuildContext context) =>  CardListScreen(),
              '/DCR_Entry_Details': (BuildContext context) =>
                  new DCR_Entry_Details(),
              '/Login': (BuildContext context) => new LoginScreen(),
              // '/ZipExtrator': (BuildContext context) =>
              //     new DownloadAssetsDemo(),
              '/AccountListScreen': (BuildContext context) =>
                  new AccountListScreen(),
              '/AccountDetailsScreen': (BuildContext context) =>
                  new AccountDetailsScreen(),
              '/AllowanceScreen': (BuildContext context) =>
                  new AllowanceScreen(),
              // '/CalendarScreen': (BuildContext context) => new CalendarScreen(),
              '/CalendarScreenDefault': (BuildContext context) =>
                  new CalendarScreenDefault(),
              // '/CalendarScreenAll': (BuildContext context) =>
              //     new CalendarScreenAll(),
              '/CalendarScreenMain': (BuildContext context) =>
                  new CalendarScreenMain(),
              '/InboxListingScreen': (BuildContext context) =>
                  new InboxListingScreen(),
              '/InboxDetailsScreen': (BuildContext context) =>
                  new InboxDetailsScreen(),
              '/PDFViewer': (BuildContext context) => new PDFViewerMain(),
              '/DashboardScreen': (BuildContext context) => DashboardScreen(),
              '/Settings': (BuildContext context) => new Settings(),
              '/DCR_Entry': (BuildContext context) => new DCR_Entry_new(),
              '/DCREntry_without_MTP': (BuildContext context) =>
                  new DCREntry_without_MTP(),
              '/DashBoardFullScreen': (BuildContext context) =>
                  new DashBoardFullScreen(msgData: null),
              '/MapActivity': (BuildContext context) => new MapActivity(),
              '/RMTCallScreen': (BuildContext context) => new RMTCallScreen(),
              '/AssistanceScreen': (BuildContext context) =>
                  new AssistanceScreen(),
              '/GoogleMapDirectionScreen': (BuildContext context) =>
                  new GoogleMapDirectionScreen(),
              '/DeviationScreen': (BuildContext context) =>
                  new DeviationScreen(),
              '/GlobalSearchScreen': (BuildContext context) =>
                  new GlobalSearchScreen(),
              '/FormControlWithTemplateJson': (BuildContext context) =>
                  new FormControlWithTemplateJson(),
              '/POBSummaryScreen': (BuildContext context) =>
                  new POBSummaryScreen(),
              '/ProviderLayout': (BuildContext context) => new ProviderLayout(),
              '/DataScreen': (BuildContext context) => new DataScreen(),
            },
          );
        },
      ),
    );
  }
}
