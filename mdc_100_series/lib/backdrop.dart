import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'model/product.dart';

const double _kFlingVelocity = 2.0;

class Backdrop extends StatefulWidget {

  final Category currentCategory;
  final Widget frontPanel;
  final Widget backPanel;
  final Widget frontTitle;
  final Widget backTitle;


  Backdrop({
    @required this.currentCategory,
    @required this.frontPanel,
    @required this.backPanel,
    @required this.frontTitle,
    @required this.backTitle,
  })
      : assert(currentCategory != null),
        assert(frontPanel != null),
        assert(backPanel != null),
        assert(frontTitle != null),
        assert(backTitle != null);

  @override
  _BackdropState createState() => _BackdropState();

}

class _BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {

  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      value: 1.0,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      brightness: Brightness.light,
      title: Text("Shrine"),
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: _toggleBackdropPanelVisibility,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.tune),
          onPressed: () {},
        ),
      ],

    );

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraint) {
    const double panelTitleHeight = 48.0;
    final Size panelSize = constraint.biggest;
    final double panelTop = panelSize.height - panelTitleHeight;

    Animation<RelativeRect> panelAnimation = RelativeRectTween(
      begin: RelativeRect.fromLTRB(0.0, panelTop, 0.0, panelTop - panelSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_animationController.view);

    return Container(
      key: _backdropKey,
      child: Stack(
        children: <Widget>[
          widget.backPanel,
          PositionedTransition(
            rect: panelAnimation,
            child: _BackdropPanel(child: widget.frontPanel),
          ),
        ],
      ),
    );
  }

  bool get _backdropPanelVisible {
    final AnimationStatus status = _animationController.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropPanelVisibility() {
    _animationController.fling(
      velocity: _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity
    );
  }
}

class _BackdropPanel extends StatelessWidget {

  final Widget child;

  const _BackdropPanel({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(46.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: child),
        ],
      ),
    );
  }

}
