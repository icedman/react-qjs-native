import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import './view.dart';
import '../element.dart' as React;

class IconElement extends ViewElement {
    IconElement(
      {React.Element? element,
      String? textContent = '',
      List<Widget>? children}) : super(element: element, textContent: textContent, children: children);

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    int code = state.attributes()['data'];
    return Icon(IconData(code, fontFamily: "MaterialIcons"));
  }
}

