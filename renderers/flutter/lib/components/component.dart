import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import '../element.dart';

class Component {
  List<Widget> wrapExpanded(List<Widget> widgets) {
    List<Widget> res = [];
    for (final c in widgets) {
      res.add(Expanded(child: c));
    }
    return res;
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
