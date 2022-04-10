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
    Border? border;
    if (style['color'] != null) {
      color = hexToColor(style['background'] ?? '#ffffff');
    }
    if (style['borderColor'] != null) {
      Color borderColor = hexToColor(style['borderColor'] ?? '#ffffff');
      border = Border.all(color: borderColor);
    }
    return BoxDecoration(color: color, border: border);
  }

  Widget expand(Widget widget, dynamic style) {
    String height = style['height'] ?? '';
    if (height != '') {
      int px = height.indexOf('px');
      if (px != -1) {
        height = height.substring(0, px);
      }
      return Container(height: int.parse(height).toDouble(), child: widget);
    }
    String width = style['width'] ?? '';
    if (width != '') {
      int px = width.indexOf('px');
      if (px != -1) {
        width = width.substring(0, px);
      }
      return Container(width: int.parse(width).toDouble(), child: widget);
    }
    int flex = style['flex'] ?? 1;
    return Expanded(flex: flex, child: Align(alignment: Alignment.center, child: widget));
  }

  Widget decorate(Widget widget, dynamic style) {
    return Container(child: widget, decoration: boxStyle(style));
  }

  List<Widget> expandEach(List<Widget> widgets, dynamic style) {
    List<Widget> res = [];
    for (final c in widgets) {
      res.add(expand(c, style));
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

class StyleProvider extends ChangeNotifier {
  StyleProvider(this.style);
  dynamic style;
}

class StateProvider extends ChangeNotifier {
  StateProvider({StateProvider? state}) : super() {
    if (state != null) {
      state.proxy = this;
      _json = state.raw();
      _attributes = state.attributes();
      _style = state.style();
    }
  }

  @override
  void notifyListeners() {
    if (proxy != null) {
      proxy?.notifyListeners();
      return;
    }
    super.notifyListeners();
  }

  StateProvider? proxy;

  dynamic _json = jsonDecode('{}');
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
      _json[k] = newState[k];
    }
    notifyListeners();
  }

  dynamic attributes() {
    return _attributes;
  }

  dynamic style() {
    return _style;
  }

  dynamic raw() {
    return _json;
  }
}
