import 'package:flutter/material.dart';
import '../custom_elements.dart';

class CustomButton extends StatelessWidget {
  double? fontSize;
  Color? fontColor;
  EdgeInsets? padding;
  double? radius;
  Function onTap;
  Color bgColor;
  double elevation;
  Color fgColor;
  Color? pressedColor;
  String title;
  double borderWidth;
  Color borderColor;
  Size? size;
  bool shrink;
  ButtonStyle? btnStyle;

  CustomButton(
      {super.key, required this.title,
      this.radius,
        this.borderWidth = 0,
      this.borderColor = Colors.transparent,
      this.fontColor,
      this.padding,
      this.fontSize,
      required this.onTap,
      this.bgColor = CustomColors.primary,
      this.elevation = 4,
      this.pressedColor,
      this.size,
        this.shrink = false,
      this.fgColor = CustomColors.white,
      this.btnStyle});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onTap(),
      clipBehavior: Clip.antiAlias,
      style: btnStyle ?? ButtonStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        foregroundColor: WidgetStateProperty.all(fgColor),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: WidgetStateProperty.all(BorderSide(color: borderColor,style: BorderStyle.solid,width: borderWidth)),
        elevation: WidgetStateProperty.all(elevation),
        shadowColor: WidgetStateProperty.all(bgColor),
        padding: WidgetStateProperty.all(padding ?? const EdgeInsets.symmetric(horizontal: 10,vertical: 5)),
        overlayColor: WidgetStateProperty.all(pressedColor ?? CustomColors.white.withOpacity(0.3)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 10))),
        animationDuration: const Duration(milliseconds: 500),
        mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
        maximumSize: shrink ? null : WidgetStateProperty.all(size ?? (Size(SizerUtil.deviceType == DeviceType.mobile ? 90.w : 400, 50)) ),
        minimumSize: shrink ? null : WidgetStateProperty.all(size ?? (Size(SizerUtil.deviceType == DeviceType.mobile ? 90.w : 400, 50))),
        visualDensity: VisualDensity.standard,
          // padding: WidgetStateProperty.all(EdgeInsets.all(20)),
          // surfaceTintColor:  WidgetStateProperty.all(Colors.greenAccent)
      ),
      child: Text(title,style: CustomStyles.textStyle(fontSize:  fontSize ?? 18,fontColor: fontColor,fontWeight: FontWeight.bold),),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1 - _animationController.value;
    return GestureDetector(
      onTapUp: _onTapUp,
      onTapDown: _onTapDown,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 300,
          height: 75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(38.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0.0, 2.0),
                blurRadius: 5.0,
                spreadRadius: 0.25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }
}