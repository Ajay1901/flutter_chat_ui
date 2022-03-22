import 'package:flutter/material.dart';

class SelectedTickMarkIcon extends StatelessWidget {
  const SelectedTickMarkIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding:  EdgeInsets.only(left:10),
      child:  CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFF595FDD),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
