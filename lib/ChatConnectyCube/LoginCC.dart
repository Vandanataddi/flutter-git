// import 'package:flexi_profiler/ChatConnectyCube/pref_util.dart';
// import 'package:flexi_profiler/ChatConnectyCube/select_dialog_screen.dart';
// import 'package:flexi_profiler/Constants/Constants_data.dart';
// import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
// import 'package:flutter/material.dart';
//
// import 'package:connectycube_sdk/connectycube_sdk.dart';
// import 'package:provider/provider.dart';
//
// import 'api_utils.dart';
//
// class LoginCC extends StatelessWidget {
//   DarkThemeProvider themeChange;
//   ThemeData themeData;
//
//   @override
//   Widget build(BuildContext context) {
//     themeChange = Provider.of<DarkThemeProvider>(context);
//     themeData = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(
//           flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
//           automaticallyImplyLeading: false,
//           title: Text('Chat')),
//       body: LoginPage(),
//     );
//   }
// }
//
// class LoginPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => new LoginPageState();
// }
//
// class LoginPageState extends State<LoginPage> {
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       body: SingleChildScrollView(
//         child: new Container(
//           padding: EdgeInsets.all(16.0),
//           child: new Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: <Widget>[_buildLogoField(), _initLoginWidgets()],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogoField() {
//     return Container(
//       child: Align(
//         alignment: FractionalOffset.center,
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.all(40.0),
//               child: Image.asset('assets/images/profiler_logo_new.png'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   _initLoginWidgets() {
//     return FutureBuilder<Widget>(
//         future: getFilterChipsWidgets(),
//         builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
//           if (snapshot.hasData) {
//             return snapshot.data;
//           }
//           return SizedBox.shrink();
//         });
//   }
//
//   Future<Widget> getFilterChipsWidgets() async {
//     await SharedPrefs.instance.init();
//     CubeUser user = SharedPrefs.instance.getUser();
//     if (user != null) {
//       _loginToCC(context, user);
//       return SizedBox.shrink();
//     } else
//       _loginPressed();
//     return SizedBox.shrink();
//   }
//
//   void _loginPressed() {
//     print('login with ${Constants_data.demoUserCC} and ${Constants_data.demoPassCC}');
//     CubeUser user = CubeUser(login: Constants_data.demoUserCC, password: Constants_data.demoPassCC);
//     print("User: ${user.toJson()}");
//     _loginToCC(context, user, saveUser: true);
//   }
//
//   _loginToCC(BuildContext context, CubeUser user, {bool saveUser = false}) {
//     createSession(user).then((cubeSession) async {
//       var tempUser = user;
//       user = cubeSession.user..password = tempUser.password;
//       if (saveUser) SharedPrefs.instance.saveNewUser(user);
//       _loginToCubeChat(context, user);
//     }).catchError((err) {
//       print("Error in CreateSession : ${err.toString()}");
//     });
//   }
//
//   _loginToCubeChat(BuildContext context, CubeUser user) {
//     print("_loginToCubeChat user $user");
//     CubeChatConnection.instance.login(user).then((cubeUser) {
//       _goDialogScreen(context, cubeUser);
//     }).catchError(_processLoginError);
//   }
//
//   void _processLoginError(exception) {
//     log("Login error $exception", "Profiler");
//     showDialogError(exception, context);
//   }
//
//   void _goDialogScreen(BuildContext context, CubeUser cubeUser) async {
//     print("Task Executed");
//
//     Constants_data.cubeUser = cubeUser;
//
//     // bool refresh = await Navigator.push(
//     //   context,
//     //   MaterialPageRoute(
//     //     settings: RouteSettings(name: "/SelectDialogScreen"),
//     //     builder: (context) => SelectDialogScreen(cubeUser),
//     //   ),
//     // );
//   }
// }
