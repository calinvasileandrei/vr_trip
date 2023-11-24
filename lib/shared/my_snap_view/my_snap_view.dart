import 'package:flutter/material.dart';

class MySnapView extends StatelessWidget {
  final List<Widget> children;

  const MySnapView({super.key,required this.children});

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return Expanded(
      child: PageView(

        /// [PageView.scrollDirection] defaults to [Axis.horizontal].
        /// Use [Axis.vertical] to scroll vertically.
        controller: controller,
        children: children,
      ),
    );
  }
}
