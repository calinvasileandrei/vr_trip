import 'package:flutter/material.dart';

class KeepAlivePage extends StatefulWidget {
  final Widget _child;
  final bool _keepPageAlive;

  const KeepAlivePage({
    super.key,
    required Widget child,
    required bool keepPageAlive,
  }) : _child = child, _keepPageAlive = keepPageAlive;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState(_child,_keepPageAlive);
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  final Widget _child;
  final bool _keepPageAlive;

  _KeepAlivePageState(this._child,this._keepPageAlive);

  @override
  Widget build(BuildContext context) {
    /// Dont't forget this
    super.build(context);

    return _child;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => _keepPageAlive;
}
