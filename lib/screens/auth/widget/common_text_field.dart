import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;
  final bool obscureText; // Whether to show toggle (but default is visible)

  const CommonTextField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
    this.obscureText = false, // default false (text visible)
  }) : super(key: key);

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText; // default value is false (visible)
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 10),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscure = !_obscure;
                });
              },
            )
                : null,
          ),
          style: GoogleFonts.poppins(fontSize: 14),
          validator: widget.validator,
        ),
      ],
    );
  }
}
