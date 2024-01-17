import 'package:flutter/material.dart';

class KeepAlivePage extends StatefulWidget {
  final Widget _child;

  const KeepAlivePage({
    super.key,
    required Widget child,
  }) : _child = child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState(_child);
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  final Widget _child;

  _KeepAlivePageState(this._child);

  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return _child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
