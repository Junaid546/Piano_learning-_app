import 'package:flutter/material.dart';

class KeyboardDismissibleWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardDismissibleWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
