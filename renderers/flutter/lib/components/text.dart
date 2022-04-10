import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import './view.dart';
import '../element.dart' as React;

class TextElement extends ViewElement {
    TextElement(
      {React.Element? element,
      String? textContent = '',
      List<Widget>? children}) : super(element: element, textContent: textContent, children: children);

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    StyleProvider styleProvider = Provider.of<StyleProvider>(context);
    dynamic style = styleProvider.style;

    String flexDirection = 'column';
    flexDirection = style['flexDirection'] ?? flexDirection;

    List<Widget> ct = [];
    if (textContent != null) {
      ct.add(expand(Text(textContent ?? '', style: textStyle(style)), {}));
    }

    if (flexDirection == 'column') {
      return decorate(Column(children: ([...ct, ...children ?? []])), state.style());
    } else {
      return decorate(Row(children: ([...ct, ...children ?? []])), state.style());
    }
  }
}

