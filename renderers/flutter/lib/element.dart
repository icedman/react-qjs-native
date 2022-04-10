import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_js/flutter_js.dart';

import './components/component.dart';
import './components/view.dart';
import './components/scrollview.dart';
import './components/text.dart';
import './components/textinput.dart';
import './components/button.dart';
import './components/flatlist.dart';
import './components/icon.dart';

class Element extends Object {
  String id = '';
  String type = '';
  String parent = '';
  List<String> children = [];
  StateProvider state = StateProvider();

  Widget builder(BuildContext context) {
    return ElementWidget(element: this);
  }

  @override
  String toString() {
    return 'Element: ${state.raw()}';
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

    if (element.state.raw().containsKey('key')) {
      id = element.state.raw()['key'];
    }
    if (element.state.raw().containsKey('type')) {
      type = element.state.raw()['type'];
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
          e.state.raw().contains('type') &&
          e.state.raw()['type'] == type) {
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
    celm?.parent = elm?.id ?? '';
  }

  void removeChild(String parent, String child) {
    if (!elements.containsKey(parent)) return;
    Element? elm = elements[parent];
    elm?.children.removeWhere((element) => element == child);
    elm?.state.notifyListeners();
  }
}

class ElementWidget extends StatelessWidget with Component {
  ElementWidget({Element? this.element});
  Element? element;

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);

    // extract children
    List<Widget> cc = (element?.children ?? [])
        .map(
          (c) {
            Element? elm = Registry.instance().element(c);
            return MultiProvider(providers: [
            if (elm.state.style().keys.isNotEmpty) ...[
              ChangeNotifierProvider(
                  create: (context) => StyleProvider(elm.state.style())),
            ],
            ChangeNotifierProvider(
                create: (context) => StateProvider(state: elm.state))
          ], child: elm.builder(context));
          },
        )
        .toList();

    // extract attributes
    String? textContent;
    textContent = state.attributes()['textContent'];

    // extract events
    bool hasEvents = false;
    if (state.raw()['events'] != null) {
      final events = state.raw()['events'];
      if (events['onClick'] != null) {
        hasEvents = true;
      }
    }

    Widget? child;

    // factory
    if ((element?.type ?? '') == 'textinput') {
      child =
          TextInputElement(element: element);
    }
    if ((element?.type ?? '') == 'button') {
      child =
          ButtonElement(element: element, children: cc);
    }
    if ((element?.type ?? '') == 'text') {
      child =
          TextElement(element: element, children: cc, textContent: textContent);
    }
    if ((element?.type ?? '') == 'scrollview') {
      child =
          ScrollElement(element: element, children: cc, textContent: textContent);
    }
    if ((element?.type ?? '') == 'flatlist') {
      child =
          FlatList(element: element, children: cc, textContent: textContent);
    }
    if ((element?.type ?? '') == 'icon') {
      child =
          IconElement(element: element);
    }

    // fallback to View
    if (child == null) {
      child =
          ViewElement(element: element, children: cc, textContent: textContent);
    }

    if (hasEvents) {
      child = GestureDetector(
          onTapDown: (details) {
            try {
              final script = 'onEvent("${element?.id}", "onClick")';
              JsEvalResult? jsResult = Registry.instance().js?.evaluate(script);
            } catch (err, msg) {
              print(err);
            }
          },
          child: child);
    }
    return expand(child, state.style());
  }
}
