import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import '../element.dart' as React;

class ViewElement extends StatelessWidget with Component {
  ViewElement(
      {React.Element? this.element,
      String? this.textContent = '',
      List<Widget>? this.children});
  React.Element? element;
  String? textContent = '';
  List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);

    String flexDirection = 'column';
    if (state.json['style'] != null) {
      final attribs = state.json['style'];
      if (attribs['flexDirection'] != null) {
        flexDirection = attribs['flexDirection']!;
      }
    }

    List<Widget> ct = [];
    if (textContent != null) {
      ct.add(Text(textContent ?? ''));
    }

    if (flexDirection == 'column') {
      return Column(children: wrapExpanded([...ct, ...this.children ?? []]));
    } else {
      return Row(children: wrapExpanded([...ct, ...this.children ?? []]));
    }
  }
}
