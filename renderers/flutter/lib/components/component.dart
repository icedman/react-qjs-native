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
    TextDecoration decor = TextDecoration.none;
    if (style['strikethrough'] == "true") {
      decor = TextDecoration.lineThrough;
    }
    if (style['underline'] == "true") {
      decor = TextDecoration.underline;
    }
    FontWeight fontWeight = FontWeight.normal;
    if (style['bold'] == "true") {
      fontWeight = FontWeight.bold;
    }
    FontStyle fontStyle = FontStyle.normal;
    if (style['italic'] == "true") {
      fontStyle = FontStyle.italic;
    }
    return TextStyle(fontSize: 18, color: color, decoration: decor, fontWeight: fontWeight, fontStyle: fontStyle);
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
    String align = style['align'] ?? '';
    Alignment alignment = Alignment.center;
    switch(align) {
      case 'left':
        alignment: Alignment.centerLeft;
        break;
      case 'right':
        alignment: Alignment.centerRight;
        break;
    }
    int flex = style['flex'] ?? 1;
    return Expanded(flex: flex, child: Align(alignment: alignment, child: widget));
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
      proxy?._json = raw();
      proxy?._attributes = attributes();
      proxy?._style = style();
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
