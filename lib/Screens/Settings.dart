import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flexi_profiler/Constants/AppColors.dart';
import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Constants/StateManager.dart';
import 'package:flexi_profiler/DBClasses/ApiBaseHelper.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<Settings> {
  double deviceHeight;
  double deviceWidth;
  final formKey = GlobalKey<FormState>();

  TextEditingController cnt_old_pass = new TextEditingController();
  TextEditingController cnt_pass = new TextEditingController();
  TextEditingController cnt_cpass = new TextEditingController();
  TextEditingController cnt_phone = new TextEditingController();

  bool isPhoneEditable = false;
  bool isImageSelected = false;
  File _image;
  var currentUser;
  bool isImageUploading = false;
  bool isLoaded = false;
  String phone;
  FocusNode myFocusNode;
  ApiBaseHelper _helper = ApiBaseHelper();


  File _selectedFile;


  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    isSwitched = themeChange.darkTheme;

    return Scaffold(
        appBar: AppBar(
          flexibleSpace: Constants_data.getFlexibleAppBar(
              themeChange.darkTheme),
          title: Text("Settings"),
        ),
        body: !isLoaded
            ? FutureBuilder<dynamic>(
          future: getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return getView();
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        )
            : getView());
  }

  getView() {
    return Container(
      height: deviceHeight,
      width: deviceWidth,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: !themeChange.darkTheme
                  ? BoxDecoration(
                image: themeChange.darkTheme
                    ? DecorationImage(
                  image: AssetImage("assets/images/menu_bg_dark.png"),
                  fit: BoxFit.cover,
                )
                    : DecorationImage(
                  image: AssetImage("assets/images/menu_bg.png"),
                  fit: BoxFit.cover,
                ),
              )
                  : null,
              color: themeChange.darkTheme ? themeData.cardColor : null,
              height: 250,
              width: deviceWidth,
              alignment: Alignment.center,
              child: Container(
                height: 150,
                width: 150,
                child: Stack(
                  clipBehavior: Clip.none, children: <Widget>[
                  Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: themeData.primaryColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(75),
                        ),
                      ),
                      padding: EdgeInsets.all(3),
                      child: ClipOval(
                          child: Container(
                              child: isImageSelected
                                  ? Image.file(
                                _image,
                                fit: BoxFit.cover,
                              )
                                  : (Constants_data.ProfilePicURL ==
                                  "$_baseprofileUrl/content/ProfilePic/null" ||
                                  Constants_data.ProfilePicURL == "null" ||
                                  Constants_data.ProfilePicURL
                                      .isEmpty) // : Constants_data.ProfilePicURL == null || Constants_data.ProfilePicURL == ""
                                  ? Image.asset(
                                "assets/images/default_user.png",
                                fit: BoxFit.cover,
                              )
                                  : Image.network(
                                Constants_data.ProfilePicURL,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (BuildContext context, Widget child,
                                    ImageChunkEvent loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                          .expectedTotalBytes != null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes
                                          : null,
                                    ),
                                  );
                                },
                              )))),
                  isImageUploading
                      ? Container(
                    width: 150,
                    height: 150,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : SizedBox(),
                  Positioned(
                      bottom: 10,
                      right: -5,
                      child: InkWell(
                          onTap: () {
                            openFileChooser();
                          },
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0)),
                              color: themeData.accentColor,
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  )))))
                ],
                ),
              ),
            ),
            Container(
              height: 60,
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Icon(
                              Icons.supervised_user_circle,
                              color: AppColors.grey_color,
                            ),
                          )),
                      Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Username",
                                style: TextStyle(
                                    color: AppColors.grey_color, fontSize: 12),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: currentUser["RepId"] != null &&
                                    currentUser["RepId"]
                                        .toString()
                                        .isNotEmpty
                                    ? Text(
                                  "${Uri.decodeComponent(
                                      currentUser["RepId"].toString())}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                )
                                    : Container(), // Empty container if Rep_Id is null or empty
                              ),
                              // Container(
                              //   margin: EdgeInsets.only(top: 5),
                              //   child: Text(
                              //     "${Uri.decodeComponent(currentUser["Rep_Id"].toString())}",
                              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              //   ),
                              // )
                            ],
                          ))
                    ],
                  )),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
            Container(
              height: 60,
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Icon(
                              Icons.verified_user,
                              color: AppColors.grey_color,
                            ),
                          )),
                      Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Full Name",
                                style: TextStyle(
                                    color: AppColors.grey_color, fontSize: 12),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: (currentUser["first_name"] != null &&
                                    currentUser["first_name"].isNotEmpty) ||
                                    (currentUser["last_name"] != null &&
                                        currentUser["last_name"].isNotEmpty)
                                    ? Text(
                                  "${currentUser["first_name"]} ${currentUser["last_name"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                )
                                    : Container(), // Empty container if first_name or last_name is null or empty
                              )
                              // Container(
                              //   margin: EdgeInsets.only(top: 5),
                              //   child: Text("${currentUser["first_name"]} ${currentUser["last_name"]} ",
                              //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              // )
                            ],
                          ))
                    ],
                  )),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
            Container(
              height: 60,
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Icon(
                              Icons.email,
                              color: AppColors.grey_color,
                            ),
                          )),
                      Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Email Address",
                                style: TextStyle(
                                    color: AppColors.grey_color, fontSize: 12),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: currentUser["Email"] != null &&
                                    currentUser["Email"].isNotEmpty
                                    ? Text(
                                  "${currentUser["Email"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                )
                                    : Container(), // Empty container if email is null or empty
                              )

                              // Container(
                              //   margin: EdgeInsets.only(top: 5),
                              //   child: Text("${currentUser["email"]}",
                              //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              // )
                            ],
                          ))
                    ],
                  )),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
            Container(
              height: 60,
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              color: AppColors.grey_color,
                            ),
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Password",
                                style: TextStyle(
                                    color: AppColors.grey_color, fontSize: 12),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text("**********", style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                              )
                            ],
                          )),
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.edit,
                                  color: AppColors.grey_color),
                              onPressed: () {
                                openDialog();
                              },
                            ),
                          ))
                    ],
                  )),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
            Container(
              height: 60,
              child: Row(
                children: <Widget>[
                  Expanded(
                      flex: 2,
                      child: Center(
                        child: Icon(
                          Icons.phone,
                          color: AppColors.grey_color,
                        ),
                      )),
                  Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Phone Number",
                            style: TextStyle(color: AppColors.grey_color,
                                fontSize: 12),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text("$phone", style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                          )
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Center(
                        child: IconButton(
                          icon: Icon(Icons.edit, color: AppColors.grey_color),
                          onPressed: () async {
                            await openDialogMobileNumber();
                            this.setState(() {});
                          },
                        ),
                      ))
                ],
              ),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
            Container(
              height: 60,
              child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: Icon(
                              themeChange.darkTheme
                                  ? Icons.wb_twighlight
                                  : Icons.nightlight_round,
                              color: AppColors.grey_color,
                            ),
                          )),
                      Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "Theme",
                                style: TextStyle(
                                    color: AppColors.grey_color, fontSize: 12),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                child: Text("${themeChange.darkTheme
                                    ? "Dark Mode"
                                    : "Light Mode"}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                              )
                            ],
                          )),
                      Container(
                          child: Switch(
                            onChanged: toggleSwitch,
                            value: isSwitched,
                            activeTrackColor: AppColors.main_color,
                            inactiveTrackColor: Colors.grey,
                          ))
                    ],
                  )),
            ),
            Container(
              height: 1,
              width: deviceWidth,
              color: AppColors.grey_color.withOpacity(0.3),
              margin: EdgeInsets.only(left: 15, right: 15),
            ),
          ],
        ),
      ),
    );
  }

  bool isSwitched;

  void toggleSwitch(bool value) {
    setState(() {
      isSwitched = !isSwitched;
      themeChange.darkTheme = isSwitched;
      Constants_data.isThemeBlack = themeChange.darkTheme;
      Constants_data.setupThemeColors();
    });
  }

  void openFileChoosers() async {
    final XFile image = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (image != null) {
      print("Selected Image URL ${image.path}");
      setState(() {
        isImageSelected = true;
        _image = File(image.path); // Convert XFile to File
      });
      Upload(_image);
    } else {
      print("No image selected");
    }
  }

  Upload(File image) async {
    this.setState(() {
      isImageUploading = true;
    });
    final bytes = image.readAsBytesSync();
    String img64 = base64Encode(bytes);
    print("Selected Image base64: $img64");

    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      Map<String, dynamic> map = new HashMap();
      // map["ImageName"] = currentUser["Rep_Id"];
      map["ImageName"] = "${DateTime
          .now()
          .millisecondsSinceEpoch}";
      map["Base64"] = img64;

      try {
        String url = "/UploadProfilePicture?RepId=${currentUser["RepId"]}";
        var data = await _helper.post(url, map, true);
        if (data["Status"] == 1) {
          currentUser["ProfilePicURL"] =
          data["dt_ReturnedTables"][0]["ProfilPicURL"];
          // Constants_data.ProfilePicURL = data["dt_ReturnedTables"][0]["ProfilPicURL"];
          StateManager.loginUser(currentUser);
          Constants_data.toastNormal("${data["Message"]}");
        } else {
          Constants_data.toastError("${data["Message"]}");
        }
      } on Exception catch (err) {
        print("Error in UploadProfilePicture : $err");
        //  Constants_data.toastError("$err");
      }
    } else {
      //   Constants_data.toastError("You can't upload image, while offline");
    }
    this.setState(() {
      isImageUploading = false;
    });
  }

  Future<void> openFileChooser() async {
    _selectedFile = null;
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      _selectedFile = File(result.files.single.path);
      setState(() {});
      await uploadImage(_selectedFile);
      //await Upload(_selectedFile);
    } else {
      print('No file selected.');
    }
  }

  final String _baseprofileUrl = Constants_data.profileUrl;

  Future<void> uploadImage(File image) async {
    bool isNetworkAvailable = await Constants_data.checkNetworkConnectivity();
    if (isNetworkAvailable) {
      setState(() {
        isImageUploading = true;
      });

      // Define the URL for uploading the profile picture
      String url = "/Profiler/UploadProfilePicture";

      // Define the fields for the multipart request
      Map<String, String> fields = {
        'RepId': currentUser["RepId"].toString(),
      };

      // Check if the image file is available and not empty
      if (image != null && await image.length() > 0) {
        try {
          // Call the postMultipart method from ApiBaseHelper
          final response = await _helper.postMultipart(
            url,
            fields,
            image,
            'uploadedFile',
          );

          // Handle the response
          if (response["Status"] == 1) {
            String img = response["dt_ReturnedTables"]["ProfilPic"];
            String imageUrl = "$_baseprofileUrl/content/ProfilePic/$img";

            setState(() {
              currentUser["ProfilePic"] = imageUrl;
              StateManager.loginUser(currentUser);
              Constants_data.ProfilePicURL = imageUrl;
            });

            // Update user profile in StateManager
            StateManager.loginUser(currentUser);
            Constants_data.toastNormal("${response["Message"]}");
            print("Profile picture updated successfully.");
          } else {
            print("Failed to update profile picture: ${response["Message"]}");
          }
        } catch (e) {
          print("Error in UploadProfilePicture: $e");
          Constants_data.toastError("Error uploading image.");
        }
      } else {
        print('No file selected or file is empty.');
        Constants_data.toastError("You can't upload image while offline");
      }

      setState(() {
        isImageUploading = false;
      });
    } else {
      await Constants_data.openDialogNoInternetConection(context);
    }
  }

  getSectionName(String str) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 7, 7, 7),
      width: deviceWidth,
      child: Text(
        "${str.toUpperCase()}",
        style: TextStyle(
            color: AppColors.main_color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<Null> openDialog() async {
    bool _isShowPassword = false;
    bool _isShowNewPassword = false;
    bool _isShowCPassword = false;
    bool isLoading = false;
    cnt_pass.clear();
    cnt_old_pass.clear();
    cnt_cpass.clear();
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      color: themeChange.darkTheme
                          ? AppColors.dark_grey_color
                          : AppColors.main_color,
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: deviceWidth * 0.7,
                      height: 98.0,
                      child: isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.white_color,
                        ),
                      )
                          : Column(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.lock,
                              size: 30.0,
                              color: AppColors.white_color,
                            ),
                            margin: EdgeInsets.only(bottom: 10.0),
                          ),
                          Text(
                            'Change Password',
                            style:
                            TextStyle(color: AppColors.white_color,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextFormField(
                                  controller: cnt_old_pass,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Old Password can't be blank";
                                    }
                                    return null;
                                  },
                                  obscureText: !_isShowPassword,
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          bottom: 0),
                                      labelText: "Old Passsword",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _isShowPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _isShowPassword = !_isShowPassword;
                                          });
                                        },
                                      ))),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextFormField(
                                  controller: cnt_pass,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Password can't be blank";
                                    } else if (str.length < 5) {
                                      return 'Password length must be 5 Character long';
                                    }
                                    return null;
                                  },
                                  obscureText: !_isShowNewPassword,
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          bottom: 0),
                                      labelText: "New Passsword",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _isShowNewPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _isShowNewPassword =
                                            !_isShowNewPassword;
                                          });
                                        },
                                      ))),
                            ),
                            Container(
                              margin: EdgeInsets.all(10),
                              child: TextFormField(
                                  controller: cnt_cpass,
                                  validator: (str1) {
                                    if (str1.isEmpty) {
                                      return "Confirm Password can't be blank";
                                    } else if (str1.length < 5) {
                                      return 'CPassword length must be 5 Character long';
                                    } else if (cnt_pass.text != str1) {
                                      return 'Password and Confirm password not match';
                                    }
                                    return null;
                                  },
                                  obscureText: !_isShowCPassword,
                                  decoration: new InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          bottom: 0),
                                      labelText: "Confirm Passsword",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          // Based on passwordVisible state choose the icon
                                          _isShowCPassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Theme
                                              .of(context)
                                              .primaryColorDark,
                                        ),
                                        onPressed: () {
                                          // Update the state i.e. toogle the state of passwordVisible variable
                                          setState(() {
                                            _isShowCPassword =
                                            !_isShowCPassword;
                                          });
                                        },
                                      ))),
                            )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () {
                                Navigator.pop(context, 0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var dataUser;
                                  if (Constants_data.app_user == null) {
                                    dataUser =
                                    await StateManager.getLoginUser();
                                  } else {
                                    dataUser = Constants_data.app_user;
                                  }
                                  bool isNetworkAvailable = await Constants_data
                                      .checkNetworkConnectivity();

                                  if (isNetworkAvailable) {
                                    try {
                                      // Construct the URL
                                      final String url = '/Profiler/UpdatePassword';
                                      print("Request URL: $url");

                                      // Prepare the request body
                                      var passwordUpdation = {
                                        "RepId": dataUser["RepId"],
                                        "NewPassword": cnt_pass.text,
                                        "OldPassword": cnt_old_pass.text,
                                      };

                                      // Print the request body for debugging
                                      print("Request Body: ${jsonEncode(
                                          passwordUpdation)}");
                                      // Send the POST request
                                      final mainData = await _helper.postMethod(
                                          url, passwordUpdation, true);
                                      // Debug: print the response
                                      print("Response Data: $mainData");

                                      // Handle the response data
                                      if (mainData["Status"] == 1) {
                                        // Success
                                        Constants_data.toastNormal(
                                            mainData["Message"].toString());
                                        Navigator.pop(context, 1);
                                      } else {
                                        // Failure: show error message
                                        Constants_data.toastError(
                                            mainData["Message"].toString());
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    } on Exception catch (err) {
                                      // Handle errors
                                      Constants_data.toastError("$err");
                                      print("Error in ChangePassword: $err");
                                    }
                                  }
                                  else {
                                    await Constants_data
                                        .openDialogNoInternetConection(context);
                                  }
                                }
                              },
                              child: Row(
                                children: <Widget>[
//                          Container(
//                            child: Icon(
//                              Icons.check_circle,
//                              color: primaryColor,
//                            ),
//                            margin: EdgeInsets.only(right: 10.0),
//                          ),
                                  Text(
                                    'CHANGE',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ))
                  ],
                );
              });
        })) {
      case 0:
        break;
      case 1:
        print("password changed");
        break;
    }
  }

  static final validCharacters = RegExp(r'^[0-9]+$');

  Future<Null> openDialogMobileNumber() async {
    bool isLoading = false;
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SimpleDialog(
                  contentPadding: EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                  children: <Widget>[
                    Container(
                      color: themeChange.darkTheme
                          ? AppColors.dark_grey_color
                          : AppColors.main_color,
                      margin: EdgeInsets.all(0.0),
                      padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                      width: deviceWidth * 0.7,
                      height: 98.0,
                      child: isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: AppColors.white_color,
                        ),
                      )
                          : Column(
                        children: <Widget>[
                          Container(
                            child: Icon(
                              Icons.phone_android,
                              size: 30.0,
                              color: AppColors.white_color,
                            ),
                            margin: EdgeInsets.only(bottom: 10.0),
                          ),
                          Text(
                            'Update Phone Number',
                            style:
                            TextStyle(color: AppColors.white_color,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  top: 25, bottom: 10, left: 10, right: 10),
                              child: TextFormField(
                                  maxLength: 15,
                                  keyboardType: TextInputType.phone,
                                  controller: cnt_phone,
                                  validator: (str) {
                                    if (str.isEmpty) {
                                      return "Phone number can't be blank";
                                    } else if (!validCharacters.hasMatch(str)) {
                                      return "Phone number can't contain white space or special character";
                                    }
                                    return null;
                                  },
                                  obscureText: false,
                                  decoration: new InputDecoration(
                                    labelText: "Enter Phone number",
                                    contentPadding: EdgeInsets.only(bottom: 0),
                                  )),
                            )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () {
                                cnt_phone.text = phone;
                                Navigator.pop(context, 0);
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'CANCEL',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SimpleDialogOption(
                              onPressed: () async {
                                if (formKey.currentState.validate()) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isLoading = true;
                                  });
                                  var dataUser;
                                  if (Constants_data.app_user == null) {
                                    dataUser =
                                    await StateManager.getLoginUser();
                                  } else {
                                    dataUser = Constants_data.app_user;
                                  }

                                  bool isNetworkAvailable = await Constants_data
                                      .checkNetworkConnectivity();
                                  if (isNetworkAvailable) {
                                    try {
                                      // Construct the URL
                                      final String url =
                                          '/Profiler/UpdateMobileNumber';

                                      // Create the request body as a Map
                                      var mobileNumberUpdation = {
                                        "RepId": dataUser["RepId"],
                                        "mobile_no": cnt_phone.text,
                                      };

                                      // Call the helper class's post method
                                      final response = await _helper.postMethod(
                                        url,
                                        mobileNumberUpdation,
                                        true, // Indicates JSON serialization is required
                                      );

                                      if (response["statusCode"] == 200 ||
                                          response["Status"] == 1) {
                                        // Handle success case
                                        Constants_data.toastNormal(
                                            response["Message"].toString());

                                        currentUser["MobileNo"] =
                                            cnt_phone.text;
                                        StateManager.loginUser(currentUser);

                                        setState(() {
                                          phone = cnt_phone.text;
                                        });

                                        Navigator.pop(context, 1);
                                      } else {
                                        // Handle the error returned by the API
                                        Constants_data.toastError(
                                            response["Message"].toString());
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    } on Exception catch (err) {
                                      Constants_data.toastError("Error: $err");
                                      print(
                                          "Error in UpdateMobileNumber: $err");
                                    }
                                  }
                                  else {
                                    await Constants_data
                                        .openDialogNoInternetConection(context);
                                  }
                                }
                              },
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'CHANGE',
                                    style: TextStyle(
                                        color: AppColors.main_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                );
              });
        })) {
      case 0:
        break;
      case 1:
        print("password changed");
        break;
    }
  }

  Future<Null> getUser() async {
    if (Constants_data.app_user != null) {
      currentUser = Constants_data.app_user;
    } else {
      currentUser = await StateManager.getLoginUser();
    }
    print("Current User : $currentUser");
    cnt_phone.text = currentUser["MobileNo"].toString();
    phone = currentUser["MobileNo"].toString();
    isLoaded = true;
  }
}
