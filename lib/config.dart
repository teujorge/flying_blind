import 'package:flutter/material.dart';

class Config {
  static double power(double n1, double n2) {
    double power = 1;
    for (double i = 0; i < n2; i++) {
      power *= n1;
    }
    return power;
  }
}

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  final EdgeInsets? padding = const EdgeInsets.all(8);

  const Button({
    Key? key,
    this.onPressed,
    this.onLongPress,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: ElevatedButton(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => Colors.black,
          ),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) => Colors.white,
          ),
          padding: MaterialStateProperty.resolveWith(
            (states) => const EdgeInsets.all(8),
          ),
          alignment: Alignment.center,
        ),
        child: child,
      ),
    );
  }
}

class BabaText extends Text {
  BabaText(String data, {Key? key, TextStyle? style})
      : super(
          data,
          key: key,
          style: null,
          // style != null
          //     ? style.copyWith(fontFamily: 'BABA')
          //     : const TextStyle(fontFamily: 'BABA'),
        );
}
