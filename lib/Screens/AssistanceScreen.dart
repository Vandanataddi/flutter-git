import 'dart:collection';

import 'package:flexi_profiler/Constants/Constants_data.dart';
import 'package:flexi_profiler/Theme/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AssistanceScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyAppState extends State<AssistanceScreen> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    initSpeechState();
    // initTTP();
  }

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  initTTP() async {
    flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-IN");
    await flutterTts.setSpeechRate(1.0);
    flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        ttsState = TtsState.playing;
      });
    });
    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    // if (hasSpeech) {
    //   _localeNames = await speech.locales();
    //
    //   var systemLocale = await speech.systemLocale();
    //   _currentLocaleId = systemLocale.localeId;
    // }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
      listWordToSpeak = [];
    });
    addInitialMessage();
  }

  addInitialMessage() async {
    Map<String, dynamic> map = new HashMap();
    map["msg"] = "Hey ${Constants_data.username},\nHow can I help you?";
    map["isQue"] = false;
    listWordToSpeak.add(map);

    map = new HashMap();
    map["msg"] = "Select one of the option";
    map["isQue"] = false;
    map["type"] = "chip";
    map["data"] = [
      {"name": "Sales", "id": "101"},
      {"name": "Stoke", "id": "102"},
      {"name": "Return", "id": "103"}
    ];
    listWordToSpeak.add(map);
    // var result_data = await flutterTts.speak("${map["msg"]}");
    // if (result_data == 1) setState(() => ttsState = TtsState.playing);
    this.setState(() {});
  }

  List<dynamic> listWordToSpeak = [];
  final _controller = ScrollController();
  String speaking_txt = '';

  DarkThemeProvider themeChange;
  ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    Constants_data.currentScreenContext = context;
    themeChange = Provider.of<DarkThemeProvider>(context);
    themeData = Theme.of(context);
    Timer(
      Duration(milliseconds: 100),
      () => _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        // leading: IconButton(
        //     icon: Icon(
        //       PlatformIcons(context).back,
        //       color: AppColors.white_color,
        //       size: 30,
        //     ),
        //     onPressed: () {
        //       Navigator.pop(context);
        //     }),
        flexibleSpace: Constants_data.getFlexibleAppBar(themeChange.darkTheme),
        title: const Text('Profiler Chat Bot'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    controller: _controller,
                    // reverse: true,
                    itemCount: listWordToSpeak.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(
                            left: listWordToSpeak[index]["isQue"] ? 50 : 0,
                            right: listWordToSpeak[index]["isQue"] ? 0 : 50),
                        alignment: listWordToSpeak[index]["isQue"]
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                            child: Container(
                                margin: EdgeInsets.all(10),
                                child: createViewList(listWordToSpeak[index]))),
                      );
                    },
                  ))),
          Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width,
            child: Text(
              "${speaking_txt}",

              style:
                  TextStyle(fontSize: Constants_data.getFontSize(context, 12)),
              // textAlign: TextAlign.justify,
            ),
          ),
          Container(
              margin: EdgeInsets.only(bottom: 10),
              child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  onPressed: !_hasSpeech || speech.isListening
                      ? () {}
                      : startListening,
                  child: !_hasSpeech || speech.isListening
                      ? Container(
                          height: 60,
                          width: 160,
                          child: Lottie.asset(
                              'assets/Lotti/google-voice-assist.json'),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: Colors.black,
                            ),
                            onPressed: !_hasSpeech || speech.isListening
                                ? null
                                : startListening,
                          ),
                        ))),
        ],
      ),
    );
  }

  createViewList(data) {
    if (data["type"] == "chip") {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "${data["msg"]}",
          style: TextStyle(fontSize: Constants_data.getFontSize(context, 12)),
          // textAlign: TextAlign.justify,
        ),
        SizedBox(height: 10),
        for (int i = 0; i < data["data"].length; i++)
          InkWell(
              onTap: () {
                print("Tap : ${data["data"][i]}");
                this.setState(() {
                  Map<String, dynamic> map = new HashMap();
                  map["msg"] = "Showing the data regarding the ${data["data"][i]["name"]}";
                  map["isQue"] = true;
                  listWordToSpeak.add(map);
                });
              },
              child: Chip(
                label: Text("${data["data"][i]["name"]}"),
                elevation: 3,
              ))
      ]);
    } else {
      return Text(
        "${data["msg"]}",
        style: TextStyle(fontSize: Constants_data.getFontSize(context, 12)),
        // textAlign: TextAlign.justify,
      );
    }
  }

  Widget createChipSet() {}

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  bool check_finish = true;

  void resultListener(SpeechRecognitionResult result) async {
    if (result.finalResult) {
      check_finish = true;
      speaking_txt = '';
      print("Final Text: ${result.recognizedWords}");
      Map<String, dynamic> map = new HashMap();
      map["msg"] = result.recognizedWords;
      map["isQue"] = true;
      // listWordToSpeak.removeAt(listWordToSpeak.length - 1);
      listWordToSpeak.add(map);

      if (result.recognizedWords.contains("sales")) {
        map = new HashMap();
        var arr = result.recognizedWords.split("sales");
        // map["msg"] = "Sales is ₹ 5,45,200 and 5,45,200 or 545200";
        map["msg"] = "Sales${arr[1]} is\n\n₹ 5,45,200";
        map["isQue"] = false;
        listWordToSpeak.add(map);
        // var result_data = await flutterTts.speak("${map["msg"].replaceAll("₹ ","") + " Rupees."}");
        // if (result_data == 1) setState(() => ttsState = TtsState.playing);
      } else if (result.recognizedWords.contains("top")) {
        map = new HashMap();
        var arr = result.recognizedWords.split("top");
        map["msg"] =
            "Top ${arr[1]} is in under development.\nIt will be coming soon.";
        map["isQue"] = false;
        listWordToSpeak.add(map);
        // var result_data = await flutterTts.speak("${map["msg"]}");
        // if (result_data == 1) setState(() => ttsState = TtsState.playing);
      } else {
        map = new HashMap();
        map["msg"] =
            "I couldn't find anything related to \"${result.recognizedWords}\"";
        map["isQue"] = false;
        listWordToSpeak.add(map);
        // var result_data = await flutterTts.speak("${map["msg"]}");
        // if (result_data == 1) setState(() => ttsState = TtsState.playing);
      }
    } else {
      speaking_txt = result.recognizedWords;
    }

    setState(() {
      lastWords = "${result.recognizedWords}";
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    print("Error getting: ${error.errorMsg}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) async {
    setState(() {
      lastStatus = "$status";
    });
  }
}
