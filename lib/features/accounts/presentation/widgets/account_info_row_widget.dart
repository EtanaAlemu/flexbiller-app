import 'package:flutter/material.dart';

class AccountInfoRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const AccountInfoRowWidget({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
