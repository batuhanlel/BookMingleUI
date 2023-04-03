import 'package:book_mingle_ui/constant.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final void Function()? press;
  final Color color, textColor;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: size.width * 0.8,
        height: size.height * 0.08,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: TextButton(
            onPressed: press,
            style: TextButton.styleFrom(backgroundColor: Colors.lightBlue),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.015,
                horizontal: size.width * 0.1,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: size.width * 0.04,
                ),
              ),
            ),
          ),
        ));
  }
}
