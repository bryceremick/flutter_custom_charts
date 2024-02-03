import 'package:example/tabs/example_1.dart';
import 'package:example/tabs/gradient_example.dart';
import 'package:flutter/material.dart';

enum ExampleType {
  exampleGradient,
  exampleChart1,
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ExampleType _exampleType = ExampleType.exampleChart1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0xFF0f0f0f),
        appBar: AppBar(
          title: Text(_exampleType.name),
          backgroundColor: Color(0xFF2c2c2c),
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Example 1'),
                onTap: () {
                  setState(() {
                    _exampleType = ExampleType.exampleChart1;
                  });
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              ListTile(
                title: Text('Gradient Example'),
                onTap: () {
                  setState(() {
                    _exampleType = ExampleType.exampleGradient;
                  });
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
            ],
          ),
        ),
        body: switch (_exampleType) {
          ExampleType.exampleGradient => const GradientExample(),
          ExampleType.exampleChart1 => const Example1(),
        },
      ),
    );
  }
}
