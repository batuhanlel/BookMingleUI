import 'package:book_mingle_ui/component/text_field_container.dart';
import 'package:flutter/material.dart';

class RoundedPasswordField extends StatelessWidget {
  // final ValueChanged<String> onChanged;
  final FormFieldSetter<String> onSaved;
  final Widget suffixIcon;
  final bool obscureText;
  final String? errorText;

  const RoundedPasswordField({
    Key? key,
    // required this.onChanged,
    required this.onSaved,
    required this.suffixIcon,
    required this.obscureText,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        // onChanged: onChanged,
        onSaved: onSaved,
        obscureText: obscureText,
        decoration: InputDecoration(
          errorText: errorText,
          icon: const Icon(
            Icons.lock,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          hintText: "Password",
        ),
      ),
    );
  }
}
