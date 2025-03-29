// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class my_button extends StatelessWidget {
  final String text;
  VoidCallback ontap;
  my_button({
    super.key,
    required this.text,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[400],
              border: Border.all(
                  width: 2, color: Colors.black, style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
          height: 55,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Align(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}