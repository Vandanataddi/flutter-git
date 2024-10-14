import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MyModel>(create: (context) => MyModel()),
        ChangeNotifierProvider<AnotherModel>(create: (context) => AnotherModel()),
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('My App')),
          body: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.green[200],
                      child: Consumer<MyModel>(
                        builder: (context, myModel, child) {
                          return MaterialButton(
                            child: Text('Do something'),
                            onPressed: () {
                              // We have access to the model.
                              myModel.doSomething();
                            },
                          );
                        },
                      )),
                  Container(
                    padding: const EdgeInsets.all(35),
                    color: Colors.blue[200],
                    child: Consumer<MyModel>(
                      builder: (context, myModel, child) {
                        return Text(myModel.someValue);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.red[200],
                      child: Consumer<AnotherModel>(
                        builder: (context, myModel, child) {
                          return MaterialButton(
                            child: Text('Do something'),
                            onPressed: () {
                              myModel.doSomething();
                            },
                          );
                        },
                      )),
                  Container(
                    padding: const EdgeInsets.all(35),
                    color: Colors.yellow[200],
                    child: Consumer<AnotherModel>(
                      builder: (context, anotherModel, child) {
                        return Text('${anotherModel.someValue}');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyModel with ChangeNotifier {
  String someValue = 'Hello';

  void doSomething() {
    someValue = 'Goodbye';
    print(someValue);
    notifyListeners();
  }
}

class AnotherModel with ChangeNotifier {
  int someValue = 0;

  void doSomething() {
    someValue = 5;
    print(someValue);
    notifyListeners();
  }
}

class ValueListenableProviderProviderLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<MyModelValueListenableProvider>(
      create: (context) => MyModelValueListenableProvider(),
      child: Consumer<MyModelValueListenableProvider>(//                           <--- MyModel Consumer
          builder: (context, myModel, child) {
        return ValueListenableProvider<String>.value(
          value: myModel.someValue,
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: Text('My App')),
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.green[200],
                      child: Consumer<MyModelValueListenableProvider>(
                        builder: (context, myModel, child) {
                          return MaterialButton(
                            child: Text('Do something'),
                            onPressed: () {
                              myModel.doSomething();
                            },
                          );
                        },
                      )),
                  Container(
                    padding: const EdgeInsets.all(35),
                    color: Colors.blue[200],
                    child: Consumer<String>(
                      builder: (context, myValue, child) {
                        return Text(myValue);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class MyModelValueListenableProvider {
  ValueNotifier<String> someValue = ValueNotifier('Hello');

  void doSomething() {
    someValue.value = 'Goodbye';
    print(someValue.value);
  }
}

class StreamProviderProviderLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<MyModelStreamProvider>(
      initialData: MyModelStreamProvider(someValue: 'default value'),
      create: (context) => getStreamOfMyModel(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('My App')),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.green[200],
                  child: Consumer<MyModelStreamProvider>(
                    builder: (context, myModel, child) {
                      return MaterialButton(
                        child: Text('Do something'),
                        onPressed: () {
                          myModel.doSomething();
                        },
                      );
                    },
                  )),
              Container(
                padding: const EdgeInsets.all(35),
                color: Colors.blue[200],
                child: Consumer<MyModelStreamProvider>(
                  builder: (context, myModel, child) {
                    return Text(myModel.someValue);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Stream<MyModelStreamProvider> getStreamOfMyModel() {
  return Stream<MyModelStreamProvider>.periodic(Duration(seconds: 1), (x) => MyModelStreamProvider(someValue: '$x'))
      .take(10);
}

class MyModelStreamProvider {
  MyModelStreamProvider({this.someValue});

  String someValue = 'Hello';

  void doSomething() {
    someValue = 'Goodbye';
    print(someValue);
  }
}

class FutureProviderProviderLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider<MyModelFutureProvider>(
      initialData: MyModelFutureProvider(someValue: 'default value'),
      create: (context) => someAsyncFunctionToGetMyModel(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('My App')),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.green[200],
                  child: Consumer<MyModelFutureProvider>(
                    builder: (context, myModel, child) {
                      return MaterialButton(
                        child: Text('Do something'),
                        onPressed: () {
                          myModel.doSomething();
                        },
                      );
                    },
                  )),
              Container(
                padding: const EdgeInsets.all(35),
                color: Colors.blue[200],
                child: Consumer<MyModelFutureProvider>(
                  builder: (context, myModel, child) {
                    return Text(myModel.someValue);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<MyModelFutureProvider> someAsyncFunctionToGetMyModel() async {
  await Future.delayed(Duration(seconds: 3));
  return MyModelFutureProvider(someValue: 'new data');
}

class MyModelFutureProvider {
  MyModelFutureProvider({this.someValue});

  String someValue = 'Hello';

  Future<void> doSomething() async {
    await Future.delayed(Duration(seconds: 2));
    someValue = 'Goodbye';
    print(someValue);
  }
}

class ChangeNotifierProviderLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Re-Create the Screen");
    return ChangeNotifierProvider<MyModelChangeNotifier>(
      create: (context) => MyModelChangeNotifier(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('My App')),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.green[200],
                  child: Consumer<MyModelChangeNotifier>(
                    builder: (context, myModel, child) {
                      return MaterialButton(
                        child: Text('Do something'),
                        onPressed: () {
                          myModel.doSomething();
                        },
                      );
                    },
                  )),
              Container(
                padding: const EdgeInsets.all(35),
                color: Colors.blue[200],
                child: Consumer<MyModelChangeNotifier>(
                  builder: (context, myModel, child) {
                    return Text(myModel.someValue);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyModelChangeNotifier with ChangeNotifier {
  String someValue = 'Hello';

  void doSomething() {
    someValue = 'Goodbye';
    print(someValue);
    notifyListeners();
  }
}
