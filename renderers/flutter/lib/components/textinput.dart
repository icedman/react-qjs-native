import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:provider/provider.dart';

import './component.dart';
import '../element.dart' as React;

class TextInputElement extends StatefulWidget {
  TextInputElement({React.Element? this.element, String this.textContent = ''});
  React.Element? element;
  String textContent = '';

  @override
  _TextInputElement createState() => _TextInputElement();
}

class _TextInputElement extends State<TextInputElement> with Component {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StateProvider state = Provider.of<StateProvider>(context);
    return TextField(
        controller: controller,
        onChanged: (v) {
          try {
            final script =
                'onEvent("${widget.element?.id}", "onChangeText", "$v")';
            JsEvalResult? jsResult =
                React.Registry.instance().js?.evaluate(script);
          } catch (err, msg) {
            print(err);
          }
        });
  }
}
