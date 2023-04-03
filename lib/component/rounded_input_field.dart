import 'package:book_mingle_ui/component/text_field_container.dart';
import 'package:flutter/material.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData iconData;
  final String? errorText;
  // final ValueChanged<String> onChanged;
  final FormFieldSetter<String> onSaved;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    this.iconData = Icons.person,
    this.errorText,
    required this.onSaved,
    // required this.onChanged,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextFormField(
        onSaved: onSaved,
        // onChanged: onChanged,
        decoration: InputDecoration(
          errorText: errorText,
          hintText: hintText,
          icon: Icon(iconData),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
