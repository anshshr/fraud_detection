// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  TextEditingController controller;
  String hintText;
  TextInputType? inputType;
  IconButton? suffisuxicon;
  CustomTextfield({
    Key? key,
    required this.controller,
    required this.hintText,
    this.inputType,
    this.suffisuxicon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,

      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.black, width: 1),
        ),

        contentPadding: EdgeInsets.all(13),
        suffixIcon: suffisuxicon,
      ),
    );
  }
}
