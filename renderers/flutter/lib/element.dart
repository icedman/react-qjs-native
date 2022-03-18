import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_js/flutter_js.dart';

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

Registry gRegistry = Registry();

class Registry {
  JavascriptRuntime? js;

  static Registry instance() {
    return gRegistry;
  }

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

  Element element(String id) {
    return findById(id) ?? Element();
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

class StateProvider extends ChangeNotifier {
  var json = jsonDecode('{}');

  void setState(String s) {
    var newState = jsonDecode(s); // merge
    for (var k in newState.keys) {
      json[k] = newState[k];
    }
    notifyListeners();
  }
}

class ElementUtils {
  List<Widget> wrapExpanded(List<Widget> widgets) {
    List<Widget> res = [];
    for (final c in widgets) {
      res.add(Expanded(child: c));
    }
    return res;
  }
}

class TextElement extends StatelessWidget with ElementUtils {
  TextElement({Element? this.element, String this.textContent = ''});
  Element? element;
  String textContent = '';

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    return Text(textContent);
  }
}

class ViewElement extends StatelessWidget with ElementUtils {
  ViewElement(
      {Element? this.element,
      String? this.textContent = '',
      List<Widget>? this.children});
  Element? element;
  String? textContent = '';
  List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);

    String flexDirection = 'column';
    if (state.json['style'] != null) {
      final attribs = state.json['style'];
      if (attribs['flexDirection'] != null) {
        flexDirection = attribs['flexDirection']!;
      }
    }

    List<Widget> ct = [];
    if (textContent != null) {
      ct.add(Text(textContent ?? ''));
    }

    if (flexDirection == 'column') {
      return Column(
          children: wrapExpanded([...ct, ...this.children ?? []]));
    } else {
      return Row(children: wrapExpanded([...ct, ...this.children ?? []]));
    }
  }
}

class ElementWidget extends StatelessWidget {
  ElementWidget({Element? this.element});
  Element? element;

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    
    // extract children
    List<Widget> cc = (element?.children ?? [])
        .map(
          (c) => MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) =>
                    Registry.instance().element(c).state),
          ], child: Registry.instance().element(c).builder(context)),
        )
        .toList();

    // extract attributes
    String? textContent;
    if (state.json['attributes'] != null) {
      final attribs = state.json['attributes'];
      if (attribs['textContent'] != null) {
        textContent = attribs['textContent']!;
      }
    }

    // extract styles

    // extract events
    bool hasEvents = false;
    if (state.json['events'] != null) {
      final events = state.json['events'];
      if (events['onClick'] != null) {
        hasEvents = true;
      }
    }

    Widget? child;
    if (cc.length == 0 && textContent != null) {
      child = TextElement(element: element, textContent: textContent);
    }

    if (child == null) {
      child = ViewElement(
        element: element, children: cc, textContent: textContent);
    }

    if (hasEvents) {
      return GestureDetector(
        onTapDown: (details) {
          print('tap! ${details}');

          try {
      final script = 'onEvent("${element?.id}", "onClick")';
      JsEvalResult? jsResult = Registry.instance().js?.evaluate(script);
    } catch (err, msg) {
      print(err);
    }

        },
        child: child
      );
    }
    return child;
  }
}
