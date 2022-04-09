import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import '../element.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class Component {
  TextStyle textStyle(dynamic style) {
    Color? color;
    if (style['color'] != null) {
      color = hexToColor(style['color'] ?? '#000000');
    }
    return TextStyle(color: color);
  }

  BoxDecoration boxStyle(dynamic style) {
    Color? color;
    if (style['color'] != null) {
      color = hexToColor(style['color'] ?? '#000000');
    }
    return BoxDecoration(color: color);
  }

  Widget expand(Widget widget) {
    return Expanded(child: widget);
  }

  Widget decorate(Widget widget, dynamic style) {
    return Container(child: widget, decoration: boxStyle(style));
  }

  List<Widget> expandEach(List<Widget> widgets) {
    List<Widget> res = [];
    for (final c in widgets) {
      res.add(expand(c));
    }
    return res;
  }

  List<Widget> decorateEach(List<Widget> widgets, dynamic style) {
    List<Widget> res = [];
    for (final c in widgets) {
      res.add(decorate(c, style));
    }
    return res;
  }
}

class StateProvider extends ChangeNotifier {
  dynamic json = jsonDecode('{}');
  dynamic _attributes = {};
  dynamic _style = {};

  void setState(String s) {
    var newState = jsonDecode(s); // merge
    for (var k in newState.keys) {
      if (k == 'attributes') {
        dynamic obj = newState[k];
        for (var okey in obj.keys) {
          if (okey == 'style') {
          dynamic style = obj[okey];
            for (var skey in style.keys) {
              _style[skey] = style[skey];
            }
          } else {
            _attributes[okey] = obj[okey];
          }
        }
      }
      json[k] = newState[k];
    }
    notifyListeners();
  }

  dynamic attributes() {
    return _attributes;
  }

  dynamic style() {
    return _style;
  }
}
