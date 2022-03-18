import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_js/flutter_js.dart';

import './components/component.dart';
import './components/text.dart';
import './components/view.dart';
import './components/textinput.dart';

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

Registry theRegistry = Registry();

class Registry {
  JavascriptRuntime? js;

  static Registry instance() {
    return theRegistry;
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
                create: (context) => Registry.instance().element(c).state),
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

    if ((element?.type ?? '') == 'textinput') {
      child =
          TextInputElement(element: element, textContent: textContent ?? '');
    }

    if (child == null && cc.length == 0 && textContent != null) {
      child = TextElement(element: element, textContent: textContent);
    }

    if (child == null) {
      child =
          ViewElement(element: element, children: cc, textContent: textContent);
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
          child: child);
    }
    return child;
  }
}
