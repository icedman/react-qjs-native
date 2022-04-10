import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter/services.dart' show rootBundle;

import './components/component.dart';
import './element.dart' as React;

React.Registry registry = React.Registry.instance();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Hello React'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late JavascriptRuntime flutterJs;

  void runScriptAsset(path) async {
    final contents = await rootBundle.loadString(path);
    try {
      JsEvalResult jsResult = flutterJs.evaluate(contents);
    } catch (err, msg) {}
  }

  void runScript(path) async {
    File f = await File(path);
    try {
      final contents = await f.readAsString();
      JsEvalResult jsResult = flutterJs.evaluate(contents);
    } catch (err, msg) {}
  }

  @override
  void initState() {
    super.initState();

    flutterJs = getJavascriptRuntime();
    flutterJs.onMessage('log', (dynamic args) {
      print(args);
    });
    flutterJs.onMessage('onCreate', (dynamic args) {
      registry.createElement('', '', state: jsonEncode(args));
      setState(() {}); // ping
    });
    flutterJs.onMessage('onAppend', (dynamic args) {
      registry.appendChild(args['element'], args['child']);
    });
    flutterJs.onMessage('onRemove', (dynamic args) {
      registry.removeChild(args['element'], args['child']);
    });
    flutterJs.onMessage('onUpdate', (dynamic args) {
      registry.updateElement(args['element'], jsonEncode(args));
    });

    React.Registry.instance().js = flutterJs;

    runScriptAsset('scripts/app.js');
    // runScript('../../dist/app.js');
  }

  @override
  Widget build(BuildContext context) {
    React.Element root = React.Element();

    // find root
    for (final k in registry.elements.keys) {
      React.Element? e = registry.elements[k];
      if (e == null) continue;
      if (e.type == 'document') {
        root = e;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => StyleProvider({})),
        ChangeNotifierProvider(create: (context) => root.state),
      ], child: Column(children: [root.builder(context)])),
    );
  }
}
