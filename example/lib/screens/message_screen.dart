/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2017 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class MessageScreen extends StatelessWidget {

  MessageScreen({@required this.message, this.color = const Color(0xFFFFFFFF)});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: this.color,
      child: new Center(
        child: new Text(
          message,
          style: new TextStyle(
            fontFamily: "Lazer84",
          ),
        )
      ),
    );
  }
}