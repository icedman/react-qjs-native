import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import './view.dart';
import '../element.dart' as React;

class FlatList extends ViewElement {
    FlatList(
      {React.Element? element,
      String? textContent = '',
      List<Widget>? children}) : super(element: element, textContent: textContent, children: children);

  @override
  Widget build(BuildContext context) {
    List<Widget> items = children ?? [];
    return ListView.builder(
      itemBuilder: (context, index) {
        return items[index];
      },
      itemCount: items.length,
    );
  }
}
