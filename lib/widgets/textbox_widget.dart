import 'package:flutter/material.dart';

class CustomTextBox extends StatelessWidget {
  final String label;
  final double height;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode; // Add this parameter

  const CustomTextBox({
    Key? key,
    required this.label,
    this.height = 50,
    required this.controller,
    this.keyboardType,
    this.focusNode, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 21),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color(0xFFEBEBEB),
          ),
          child: TextField(
            keyboardType: keyboardType ?? TextInputType.text,
            controller: controller,
            focusNode: focusNode, // Pass the focus node to TextField
            decoration: InputDecoration(
              border: InputBorder.none, // Removes default underline
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
