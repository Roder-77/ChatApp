import 'package:flutter/material.dart';

class HintPage extends StatelessWidget {
  const HintPage({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Material(
        child: Text(
          hintText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
