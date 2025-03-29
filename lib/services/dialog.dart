// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fraud_detection/widgets/my_widgets.dart';
import 'package:lottie/lottie.dart';


Future dialog(BuildContext context, String text) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          elevation: 6,
          title: Text(
            'ALERT',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.grey[200],
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.network(
                    'https://lottie.host/638835a4-bf05-4cb7-af6f-928e4bfc11cf/jTMpHI8DVd.json',
                    height: 100),
                Text(
                  text,
                  style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                my_button(
                    text: 'O K A Y',
                    ontap: () {
                      Navigator.pop(context);
                    })
              ],
            )
          ],
        );
      });
}