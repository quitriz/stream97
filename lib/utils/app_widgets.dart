import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_flutter/utils/resources/colors.dart';
import 'package:streamit_flutter/utils/resources/size.dart';

Widget itemTitle(BuildContext context, String titleText, {double fontSize = ts_normal, int? maxLine, TextAlign? textAlign}) {
  return Marquee(
    animationDuration: Duration(milliseconds: 500),
    child: Text(
      titleText,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: <Shadow>[
          Shadow(
            blurRadius: 5.0,
            color: Colors.black,
          ),
        ],
      ),
      textAlign: textAlign ?? TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLine ?? 1,
    ),
  );
}

Widget itemSubTitle(BuildContext context, String titleText, {double fontSize = ts_normal, Color? textColor, isLongText = true}) {
  return Text(
    titleText,
    style: TextStyle(
      fontSize: fontSize,
      color: textColor ?? textPrimaryColorGlobal,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 5.0,
          color: Colors.black,
        ),
      ],
    ),
  );
}

Widget headingWidViewAll(BuildContext context, var titleText, {VoidCallback? callback, bool showViewMore = true, EdgeInsets? padding}) {
  return Padding(
    padding: padding ?? EdgeInsets.only(left: 16, right: 0, top: 16, bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titleText, style: primaryTextStyle(size: 18), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
        if (showViewMore)
          IconButton(
            onPressed: callback,
            icon: Icon(Icons.arrow_forward_ios, size: 14, color: context.iconColor),
          ),
      ],
    ),
  );
}

InputDecoration inputDecoration({String? hint, IconData? suffixIcon}) {
  return InputDecoration(
    labelText: hint,
    labelStyle: primaryTextStyle(color: Colors.white),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    border: OutlineInputBorder(borderSide: BorderSide(color: colorPrimary)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
    disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade500)),
    suffixIcon: Icon(suffixIcon, color: colorPrimary),
  );
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/images/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/images/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/images/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/images/flag/ic_france.png'),
  ];
}

String userProfileImage() {
  Random random = Random();
  return 'assets/images/smile_${random.nextInt(4)}.png';
}

class SettingWidget extends StatelessWidget {
  final String title;
  final double? width;
  final String? subTitle;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final Function? onTap;
  final EdgeInsets? padding;
  final int paddingAfterLeading;
  final int paddingBeforeTrailing;
  final Color? titleTextColor;
  final Color? subTitleTextColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;
  final Decoration? decoration;
  final double? borderRadius;
  final BorderRadius? radius;
  final CrossAxisAlignment crossAxisAlignment;

  SettingWidget(
      {required this.title,
      this.onTap,
      this.width,
      this.subTitle = '',
      this.leading,
      this.trailing,
      this.titleTextStyle,
      this.subTitleTextStyle,
      this.padding,
      this.paddingAfterLeading = 16,
      this.paddingBeforeTrailing = 16,
      this.titleTextColor,
      this.subTitleTextColor,
      this.decoration,
      this.borderRadius,
      this.hoverColor,
      this.splashColor,
      this.highlightColor,
      this.radius,
      Key? key,
      this.crossAxisAlignment = CrossAxisAlignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: decoration ?? BoxDecoration(),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          leading ?? SizedBox(),
          if (leading != null) paddingAfterLeading.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title.validate(),
                style: titleTextStyle ?? boldTextStyle(color: titleTextColor ?? textPrimaryColorGlobal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              4.height.visible(subTitle.validate().isNotEmpty),
              if (subTitle.validate().isNotEmpty)
                Text(
                  subTitle!,
                  style: subTitleTextStyle ??
                      secondaryTextStyle(
                        color: subTitleTextColor ?? textSecondaryColorGlobal,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ).expand(),
          if (trailing != null) paddingBeforeTrailing.width,
          trailing ?? SizedBox(),
        ],
      ),
    ).onTap(
      onTap,
      borderRadius: radius ?? (BorderRadius.circular(borderRadius.validate())),
      hoverColor: hoverColor ?? colorPrimary.withValues(alpha: 0.2),
      splashColor: splashColor ?? colorPrimary.withValues(alpha:0.2),
      highlightColor: highlightColor ?? colorPrimary.withValues(alpha:0.2),
    );
  }
}

class NavBar extends StatefulWidget {
  const NavBar({
    Key? key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onTabChange,
    this.gap = 0,
    this.padding = const EdgeInsets.all(25),
    this.activeColor,
    this.color,
    this.rippleColor = Colors.transparent,
    this.hoverColor = Colors.transparent,
    this.backgroundColor = Colors.transparent,
    this.tabBackgroundColor = Colors.transparent,
    this.tabBorderRadius = 100.0,
    this.iconSize,
    this.textStyle,
    this.curve = Curves.easeInCubic,
    this.tabMargin = EdgeInsets.zero,
    this.debug = false,
    this.duration = const Duration(milliseconds: 500),
    this.tabBorder,
    this.tabActiveBorder,
    this.tabShadow,
    this.haptic = true,
    this.tabBackgroundGradient,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.textSize,
  }) : super(key: key);

  final List<GButton> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChange;
  final double gap;
  final double tabBorderRadius;
  final double? iconSize;
  final Color? activeColor;
  final Color backgroundColor;
  final Color tabBackgroundColor;
  final Color? color;
  final Color rippleColor;
  final Color hoverColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry tabMargin;
  final TextStyle? textStyle;
  final Duration duration;
  final Curve curve;
  final bool debug;
  final bool haptic;
  final Border? tabBorder;
  final Border? tabActiveBorder;
  final List<BoxShadow>? tabShadow;
  final Gradient? tabBackgroundGradient;
  final MainAxisAlignment mainAxisAlignment;
  final double? textSize;

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int selectedIndex;
  bool clickable = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
       color: Theme.of(context).splashColor,
        boxShadow: [
          BoxShadow(
            color: Colors.white10,
            offset: Offset.fromDirection(2, 1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
          mainAxisAlignment: widget.mainAxisAlignment,
          children: widget.tabs
              .map((t) => GButton(
                    textSize: widget.textSize,
                    key: t.key,
                    border: t.border ?? widget.tabBorder,
                    activeBorder: t.activeBorder ?? widget.tabActiveBorder,
                    shadow: t.shadow ?? widget.tabShadow,
                    borderRadius: t.borderRadius ??
                        BorderRadius.all(
                          Radius.circular(widget.tabBorderRadius),
                        ),
                    debug: widget.debug,
                    margin: t.margin ?? widget.tabMargin,
                    active: selectedIndex == widget.tabs.indexOf(t),
                    gap: t.gap ?? widget.gap,
                    iconActiveColor: t.iconActiveColor ?? widget.activeColor,
                    iconColor: t.iconColor ?? widget.color,
                    iconSize: t.iconSize ?? widget.iconSize,
                    textColor: t.textColor ?? widget.activeColor,
                    rippleColor: t.rippleColor ?? widget.rippleColor,
                    hoverColor: t.hoverColor ?? widget.hoverColor,
                    padding: t.padding ?? widget.padding,
                    textStyle: t.textStyle ?? widget.textStyle,
                    text: t.text,
                    icon: t.icon,
                    haptic: widget.haptic,
                    leading: t.leading,
                    curve: widget.curve,
                    backgroundGradient: t.backgroundGradient ?? widget.tabBackgroundGradient,
                    backgroundColor: t.backgroundColor ?? widget.tabBackgroundColor,
                    duration: widget.duration,
                    onPressed: () {
                      if (!clickable) return;
                      t.onPressed?.call();
                      widget.onTabChange?.call(widget.tabs.indexOf(t));

                      Future.delayed(widget.duration, () {
                        setState(() {
                          clickable = true;
                        });
                      });
                    },
                  ))
              .toList()),
    );
  }
}

class GButton extends StatefulWidget {
  final bool? active;
  final bool? debug;
  final bool? haptic;
  final double? gap;
  final Color? iconColor;
  final Color? rippleColor;
  final Color? hoverColor;
  final Color? iconActiveColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final TextStyle? textStyle;
  final double? iconSize;
  final Function? onPressed;
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Duration? duration;
  final Curve? curve;
  final Gradient? backgroundGradient;
  final Widget? leading;
  final BorderRadius? borderRadius;
  final Border? border;
  final Border? activeBorder;
  final List<BoxShadow>? shadow;
  final String? semanticLabel;
  final double? textSize;

  const GButton({
    Key? key,
    this.active,
    this.haptic,
    this.backgroundColor,
    this.icon,
    this.iconColor,
    this.rippleColor,
    this.hoverColor,
    this.iconActiveColor,
    this.text = '',
    this.textColor,
    this.padding,
    this.margin,
    this.duration,
    this.debug,
    this.gap,
    this.curve,
    this.textStyle,
    this.iconSize,
    this.leading,
    this.onPressed,
    this.backgroundGradient,
    this.borderRadius,
    this.border,
    this.activeBorder,
    this.shadow,
    this.semanticLabel,
    this.textSize,
  }) : super(key: key);

  @override
  _GButtonState createState() => _GButtonState();
}

class _GButtonState extends State<GButton> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      child: Button(
        textSize: widget.textSize,
        borderRadius: widget.borderRadius,
        border: widget.border,
        activeBorder: widget.activeBorder,
        shadow: widget.shadow,
        debug: widget.debug,
        duration: widget.duration,
        iconSize: widget.iconSize,
        active: widget.active,
        onPressed: () {
          if (widget.haptic!) HapticFeedback.selectionClick();
          widget.onPressed?.call();
        },
        padding: widget.padding,
        margin: widget.margin,
        gap: widget.gap,
        color: widget.backgroundColor,
        rippleColor: widget.rippleColor,
        hoverColor: widget.hoverColor,
        gradient: widget.backgroundGradient,
        curve: widget.curve,
        leading: widget.leading,
        iconActiveColor: widget.iconActiveColor,
        iconColor: widget.iconColor,
        icon: widget.icon,
        text: Text(
          widget.text,
          maxLines: 1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          style: widget.textStyle ??
              TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.textColor,
              ),
        ),
      ),
    );
  }
}

class Button extends StatefulWidget {
  const Button({
    Key? key,
    this.icon,
    this.iconSize,
    this.leading,
    this.iconActiveColor,
    this.iconColor,
    this.text,
    this.gap,
    this.color,
    this.rippleColor,
    this.hoverColor,
    required this.onPressed,
    this.duration,
    this.curve,
    this.padding,
    this.margin,
    required this.active,
    this.debug,
    this.gradient,
    this.borderRadius,
    this.border,
    this.activeBorder,
    this.shadow,
    this.textSize,
  }) : super(key: key);

  final IconData? icon;
  final double? iconSize;
  final Text? text;
  final Widget? leading;
  final Color? iconActiveColor;
  final Color? iconColor;
  final Color? color;
  final Color? rippleColor;
  final Color? hoverColor;
  final double? gap;
  final bool? active;
  final bool? debug;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration? duration;
  final Curve? curve;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Border? border;
  final Border? activeBorder;
  final List<BoxShadow>? shadow;
  final double? textSize;

  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> with TickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController expandController;

  @override
  void initState() {
    super.initState();
    _expanded = widget.active!;

    expandController = AnimationController(vsync: this, duration: widget.duration)..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    expandController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var curveValue = expandController.drive(CurveTween(curve: _expanded ? widget.curve! : widget.curve!.flipped)).value;
    var _colorTween = ColorTween(begin: widget.iconColor, end: widget.iconActiveColor);
    var _colorTweenAnimation = _colorTween.animate(CurvedAnimation(parent: expandController, curve: _expanded ? Curves.easeInExpo : Curves.easeOutCirc));

    _expanded = !widget.active!;
    if (_expanded)
      expandController.reverse();
    else
      expandController.forward();

    Widget icon = widget.leading ?? Icon(widget.icon, color: _colorTweenAnimation.value, size: widget.iconSize);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: widget.margin,
          child: AnimatedContainer(
            curve: Curves.easeOut,
            padding: widget.padding,
            duration: widget.duration!,
            decoration: BoxDecoration(
              boxShadow: widget.shadow,
              border: widget.active! ? (widget.activeBorder ?? widget.border) : widget.border,
              gradient: widget.gradient,
              color: _expanded
                  ? widget.color!.withValues(alpha:0)
                  : widget.debug!
                      ? Colors.red
                      : widget.gradient != null
                          ? Colors.white
                          : widget.color,
              borderRadius: widget.borderRadius,
            ),
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Builder(
                builder: (_) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (widget.text!.data != '')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: icon,
                            ),
                            Container(
                              child: Container(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  widthFactor: curveValue,
                                  child: Container(
                                    child: Opacity(
                                      opacity: _expanded ? pow(expandController.value, 13) as double : expandController.drive(CurveTween(curve: Curves.easeIn)).value,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: widget.gap! + 8 - (8 * expandController.drive(CurveTween(curve: Curves.easeOutSine)).value), right: 8 * expandController.drive(CurveTween(curve: Curves.easeOutSine)).value),
                                        child: widget.text,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      icon,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}