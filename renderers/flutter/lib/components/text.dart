import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import '../element.dart' as React;

class TextElement extends StatelessWidget with Component {
  TextElement({React.Element? this.element, String this.textContent = ''});
  React.Element? element;
  String textContent = '';

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    return Text(textContent);
  }
}
