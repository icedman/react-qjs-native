import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import './view.dart';
import '../element.dart' as React;

class ScrollElement extends ViewElement {
    ScrollElement(
      {React.Element? element,
      String? textContent = '',
      List<Widget>? children}) : super(element: element, textContent: textContent, children: children);

  @override
  Widget build(BuildContext context) {
    double itemHeight = 32;
    double height = itemHeight * (children?.length ?? 0);
    return SingleChildScrollView(child: Container(height: height, child: Column(mainAxisSize: MainAxisSize.min, children: children ?? [])));
  }
}
