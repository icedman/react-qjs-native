import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_js/flutter_js.dart';

class ElementWidget extends StatelessWidget {
  ElementWidget({Element? this.element});

  Element? element;

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    print('build ${element?.id}');
    List<Widget> cc = 
    (element?.children ?? [])
        .map(
          (c) => MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) => registry.elements[c]?.state),
          ], child: registry.elements[c]?.builder(context)),
        )
        .toList();
  
    List<Widget> mm = [];

    if (state.json['attributes'] != null) {
      final attribs = state.json['attributes'];
      if (attribs['textContent'] != null) {
        print('${attribs['textContent']}');
        mm.add(Text('${attribs['textContent']}'));
      }
    }

    return Row(children: [ Column(children: [Text('${element?.id}'), ...mm, ...cc]) ]);
  }
}

class Element {
  String id = '';
  String type = '';
  String parent = '';
  List<String> children = [];
  StateProvider state = StateProvider();

  Widget builder(BuildContext context) {
    return ElementWidget(element: this);
  }
}

class ElementRegistry {
  Map<String, Element> elements = <String, Element>{};
  Element createElement(String id, String type, {String state = '{}'}) {
    Element element = Element();
    element.state.setState(state);

    if (element.state.json.containsKey('_id')) {
      id = element.state.json['_id'];
    }
    if (element.state.json.containsKey('type')) {
      type = element.state.json['type'];
    }

    element.id = id;
    element.type = type;
    elements[id] = element;
    return element;
  }

  Element? findById(String id) {
    if (elements.containsKey(id)) {
      return elements[id];
    }
    return null;
  }

  Element? findByType(String type) {
    for (final k in elements.keys) {
      Element? e = elements[k];
      if (e != null &&
          e.state.json.contains('type') &&
          e.state.json['type'] == type) {
        return e;
      }
    }
    return null;
  }

  void removeElement(String id) {
    if (elements.containsKey(id)) {
      elements.remove(id);
    }
  }

  void updateElement(String id, String state) {
    if (!elements.containsKey(id)) return;
    Element? elm = elements[id];
    elm?.state.setState(state);
  }

  void appendChild(String parent, String child) {
    if (!elements.containsKey(parent)) return;
    Element? elm = elements[parent];
    elm?.children.add(child);
    elm?.state.notifyListeners();
    Element? celm = findById(child);
    if (celm != null) {
      celm.parent = elm?.id ?? '';
    }
  }

  void removeChild(String parent, String child) {
    if (!elements.containsKey(parent)) return;
    Element? elm = elements[parent];
    elm?.children.removeWhere((element) => element == child);
    elm?.state.notifyListeners();
  }
}

ElementRegistry registry = ElementRegistry();

class StateProvider extends ChangeNotifier {
  String state = ''; // json...
  var json = jsonDecode('{}');

  void setState(String s) {
    var newState = jsonDecode(s); // merge
    for (var k in newState.keys) {
      json[k] = newState[k];
    }
    notifyListeners();
  }
}

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
      home: MyHomePage(title: 'Hello'),
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

  int _counter = 10;

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
      print('create... ${args['_id']}');
      registry.createElement('', '', state: jsonEncode(args));
      setState(() {}); // ping
    });
    flutterJs.onMessage('onAppend', (dynamic args) {
      print('append...');
      print(args);
      registry.appendChild(args['element'], args['child']);
    });
    flutterJs.onMessage('onRemove', (dynamic args) {
      print('remove...');
      //  print(args);
    });
    flutterJs.onMessage('onUpdate', (dynamic args) {
      print('update...');
      print(args);
      registry.updateElement(args['element'], jsonEncode(args));
    });

    runScript('./dist/app.js');
  }

  void _incrementCounter() {
    // registry.createElement('elm-$_counter', 'text');
    // registry.appendChild('elm-1', 'elm-$_counter');
    // registry.updateElement('elm-1', '{ "color": "yellow" }');

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    Element root = Element();
    // if (registry.elements.isNotEmpty ) {
    //   root = registry.elements[0] ?? Element();
    //   print('root: ${registry.elements.length} [${root.id}]');
    // }

    for (final k in registry.elements.keys) {
      Element? e = registry.elements[k];
      if (e == null) continue;
      if (e.type == 'document') {
        root = e;
        break;
      }
      // print('${e?.id} ${e?.type}');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: MultiProvider(providers: [
        ChangeNotifierProvider(create: (context) => root.state),
      ], child: root.builder(context)),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
