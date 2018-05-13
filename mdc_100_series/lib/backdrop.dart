import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'model/product.dart';

import 'login.dart';

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
      title: _BackdropTitle(
        listenable: _animationController.view,
        frontTitle: widget.frontTitle,
        backTitle: widget.backTitle,
      ),
      elevation: 0.0,
      leading: IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.close_menu,
          progress: _animationController.view,
        ),
        onPressed: _toggleBackdropPanelVisibility,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _goToLogin(context),
        ),
        IconButton(
          icon: Icon(Icons.tune),
          onPressed: () => _goToLogin(context),
        ),
      ],

    );

    return Scaffold(
      appBar: appBar,
      body: LayoutBuilder(builder: _buildStack),
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()));
  }

  @override
  void didUpdateWidget(Backdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentCategory != oldWidget.currentCategory) {
      setState(() {
        _animationController.fling(velocity:
        _backdropPanelVisible ? -_kFlingVelocity : _kFlingVelocity);
      });
    } else if (!_backdropPanelVisible) {
      setState(() {
        _animationController.fling(velocity: _kFlingVelocity);
      });
    }
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
      begin: RelativeRect.fromLTRB(
          0.0, panelTop, 0.0, panelTop - panelSize.height),
      end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(_animationController.view);

    return Container(
      key: _backdropKey,
      child: Stack(
        children: <Widget>[
          widget.backPanel,
          PositionedTransition(
            rect: panelAnimation,
            child: _BackdropPanel(
              child: widget.frontPanel,
              onTap: _toggleBackdropPanelVisibility,
            ),
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
  final VoidCallback onTap;

  const _BackdropPanel({
    Key key,
    this.child,
    this.onTap,
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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              height: 40.0,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BackdropTitle extends AnimatedWidget {

  final Widget frontTitle;
  final Widget backTitle;

  const _BackdropTitle({
    Key key,
    Listenable listenable,
    this.frontTitle,
    this.backTitle,
  }) : super(key: key, listenable: listenable);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.listenable;

    return DefaultTextStyle(
      style: Theme.of(context).primaryTextTheme.title,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: CurvedAnimation(
              parent: ReverseAnimation(animation),
              curve: Interval(0.0, 1.0),
            ).value,
            child: backTitle,
          ),
          Opacity(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Interval(0.0, 1.0),
            ).value,
            child: frontTitle,
          ),
        ],
      ),
    );
  }

}
