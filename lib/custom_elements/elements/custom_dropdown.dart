import '../custom_elements.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CustomDropdownButton extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight, buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset? offset;
  final Color? bgColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  const CustomDropdownButton({
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.valueAlignment,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset,
    this.bgColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: CustomDropdown(
        //To avoid long text overflowing.
        isExpanded: true,
        hint: Container(
          alignment: hintAlignment,
          child: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              color: textColor ?? CustomColors.transparent,
            ),
          ),
        ),
        value: value,
        items: dropdownItems
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Container(
            alignment: valueAlignment,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ))
            .toList(),
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder,
        icon: icon ?? Icon(Icons.arrow_drop_down,size: 20,color: iconColor ?? CustomColors.transparent,),
        iconSize: iconSize ?? 12,
        iconEnabledColor: iconEnabledColor,
        iconDisabledColor: iconDisabledColor,
        buttonHeight: buttonHeight ?? 50,
        buttonWidth: buttonWidth ?? 89.w,
        buttonPadding:
        buttonPadding ?? const EdgeInsets.only(left: 14, right: 14),
        buttonDecoration: buttonDecoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bgColor ?? CustomColors.transparent,
              border: Border.all(
                color: borderColor ?? CustomColors.black,
              ),
            ),
        buttonElevation: buttonElevation,
        itemHeight: itemHeight ?? 40,
        itemPadding: itemPadding ?? const EdgeInsets.only(left: 14, right: 14),
        //Max height for the dropdown menu & becoming scrollable if there are more items. If you pass Null it will take max height possible for the items.
        dropdownMaxHeight: dropdownHeight ?? 50.h,
        dropdownWidth: dropdownWidth ?? 89.w,
        dropdownPadding: dropdownPadding,
        dropdownDecoration: dropdownDecoration ??
            BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
        dropdownElevation: dropdownElevation ?? 8,
        scrollbarRadius: scrollbarRadius ?? const Radius.circular(40),
        scrollbarThickness: scrollbarThickness,
        scrollbarAlwaysShow: scrollbarAlwaysShow,
        //Null or Offset(0, 0) will open just under the button. You can edit as you want.
        offset: offset,
        dropdownOverButton: false, //Default is false to show menu below button
      ),
    );
  }
}

const Duration _kDropdownMenuDuration = Duration(milliseconds: 300);
const double _kMenuItemHeight = kMinInteractiveDimension;
const double _kDenseButtonHeight = 24.0;
const EdgeInsets _kMenuItemPadding = EdgeInsets.symmetric(horizontal: 16.0);
const EdgeInsetsGeometry _kAlignedButtonPadding =
EdgeInsetsDirectional.only(start: 16.0, end: 4.0);
const EdgeInsets _kUnalignedButtonPadding = EdgeInsets.zero;

class _DropdownMenuPainter extends CustomPainter {
  _DropdownMenuPainter({
    this.color,
    this.elevation,
    this.selectedIndex,
    required this.resize,
    required this.getSelectedItemOffset,
    required this.itemHeight,
    this.dropdownDecoration,
  })  : _painter = dropdownDecoration
      ?.copyWith(
    color: dropdownDecoration.color ?? color,
    boxShadow: dropdownDecoration.boxShadow ??
        kElevationToShadow[elevation],
  )
      .createBoxPainter() ??
      BoxDecoration(

        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(2.0)),
        boxShadow: kElevationToShadow[elevation],
      ).createBoxPainter(),
        super(repaint: resize);

  final Color? color;
  final int? elevation;
  final int? selectedIndex;
  final Animation<double> resize;
  final ValueGetter<double> getSelectedItemOffset;
  final double itemHeight;
  final BoxDecoration? dropdownDecoration;

  final BoxPainter _painter;

  @override
  void paint(Canvas canvas, Size size) {
    final double selectedItemOffset = getSelectedItemOffset();
    final Tween<double> top = Tween<double>(
      begin: selectedItemOffset.clamp(
          0.0, math.max(size.height - itemHeight, 0.0)),
      end: 0.0,
    );

    final Tween<double> bottom = Tween<double>(
      begin: (top.begin! + itemHeight)
          .clamp(math.min(itemHeight, size.height), size.height),
      end: size.height,
    );

    final Rect rect = Rect.fromLTRB(
        0.0, top.evaluate(resize), size.width, bottom.evaluate(resize));

    _painter.paint(canvas, rect.topLeft, ImageConfiguration(size: rect.size));
  }

  @override
  bool shouldRepaint(_DropdownMenuPainter oldPainter) {
    return oldPainter.color != color ||
        oldPainter.elevation != elevation ||
        oldPainter.selectedIndex != selectedIndex ||
        oldPainter.dropdownDecoration != dropdownDecoration ||
        oldPainter.itemHeight != itemHeight ||
        oldPainter.resize != resize;
  }
}

// The widget that is the button wrapping the menu items.
class _DropdownMenuItemButton<T> extends StatefulWidget {
  const _DropdownMenuItemButton({
    super.key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.itemIndex,
    required this.enableFeedback,
    this.customItemsIndexes,
    this.customItemsHeight,
  });

  final _DropdownRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final int itemIndex;
  final bool enableFeedback;
  final List<int>? customItemsIndexes;
  final double? customItemsHeight;

  @override
  _DropdownMenuItemButtonState<T> createState() =>
      _DropdownMenuItemButtonState<T>();
}

class _DropdownMenuItemButtonState<T>
    extends State<_DropdownMenuItemButton<T>> {
  void _handleFocusChange(bool focused) {
    final bool inTraditionalMode;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        inTraditionalMode = false;
        break;
      case FocusHighlightMode.traditional:
        inTraditionalMode = true;
        break;
    }

    if (focused && inTraditionalMode) {
      final _MenuLimits menuLimits = widget.route.getMenuLimits(
        widget.buttonRect,
        widget.constraints.maxHeight,
        widget.itemIndex,
      );
      widget.route.scrollController!.animateTo(
        menuLimits.scrollOffset,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  void _handleOnTap() {
    final DropdownMenuItem<T> dropdownMenuItem =
    widget.route.items[widget.itemIndex].item!;

    dropdownMenuItem.onTap?.call();

    Navigator.pop(
      context,
      _DropdownRouteResult<T>(dropdownMenuItem.value),
    );
  }

  static const Map<ShortcutActivator, Intent> _webShortcuts =
  <ShortcutActivator, Intent>{

    SingleActivator(LogicalKeyboardKey.arrowDown):
    DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp):
    DirectionalFocusIntent(TraversalDirection.up),
  };

  @override
  Widget build(BuildContext context) {
    final DropdownMenuItem<T> dropdownMenuItem =
    widget.route.items[widget.itemIndex].item!;
    final CurvedAnimation opacity;
    final double unit = 0.5 / (widget.route.items.length + 1.5);
    if (widget.itemIndex == widget.route.selectedIndex) {
      opacity = CurvedAnimation(
          parent: widget.route.animation!, curve: const Threshold(0.0));
    } else {
      final double start =
      (0.5 + (widget.itemIndex + 1) * unit).clamp(0.0, 1.0);
      final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
      opacity = CurvedAnimation(
          parent: widget.route.animation!, curve: Interval(start, end));
    }
    Widget child = Container(
      padding: widget.padding,
      height: widget.customItemsIndexes == null
          ? widget.route.itemHeight
          : widget.customItemsIndexes!.contains(widget.itemIndex)
          ? widget.customItemsHeight ?? _kMenuItemHeight
          : widget.route.itemHeight,
      child: widget.route.items[widget.itemIndex],
    );
    // An [InkWell] is added to the item only if it is enabled
    // isNoSelectedItem to avoid first item highlight when no item selected
    if (dropdownMenuItem.enabled) {
      final _isSelectedItem = !widget.route.isNoSelectedItem &&
          widget.itemIndex == widget.route.selectedIndex;
      child = InkWell(
        autofocus: _isSelectedItem,
        enableFeedback: widget.enableFeedback,
        onTap: _handleOnTap,
        onFocusChange: _handleFocusChange,
        child: Container(
          color:
          _isSelectedItem ? widget.route.selectedItemHighlightColor : null,
          child: child,
        ),
      );
    }
    child = FadeTransition(opacity: opacity, child: child);
    if (kIsWeb && dropdownMenuItem.enabled) {
      child = Shortcuts(
        shortcuts: _webShortcuts,
        child: child,
      );
    }
    return child;
  }
}

class _DropdownMenu<T> extends StatefulWidget {
  const _DropdownMenu({
    super.key,
    this.padding,
    required this.route,
    required this.buttonRect,
    required this.constraints,
    required this.enableFeedback,
    required this.itemHeight,
    this.dropdownDecoration,
    this.dropdownPadding,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    required this.offset,
    this.customItemsIndexes,
    this.customItemsHeight,
  });

  final _DropdownRoute<T> route;
  final EdgeInsets? padding;
  final Rect buttonRect;
  final BoxConstraints constraints;
  final bool enableFeedback;
  final double itemHeight;
  final BoxDecoration? dropdownDecoration;
  final EdgeInsetsGeometry? dropdownPadding;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;
  final List<int>? customItemsIndexes;
  final double? customItemsHeight;

  @override
  _DropdownMenuState<T> createState() => _DropdownMenuState<T>();
}

class _DropdownMenuState<T> extends State<_DropdownMenu<T>> {
  late CurvedAnimation _fadeOpacity;
  late CurvedAnimation _resize;

  @override
  void initState() {
    super.initState();

    _fadeOpacity = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.0, 0.25),
      reverseCurve: const Interval(0.75, 1.0),
    );
    _resize = CurvedAnimation(
      parent: widget.route.animation!,
      curve: const Interval(0.25, 0.5),
      reverseCurve: const Threshold(0.0),
    );
  }

  @override
  Widget build(BuildContext context) {

    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
    MaterialLocalizations.of(context);
    final _DropdownRoute<T> route = widget.route;
    final List<Widget> children = <Widget>[
      for (int itemIndex = 0; itemIndex < route.items.length; ++itemIndex)
        _DropdownMenuItemButton<T>(
          route: widget.route,
          padding: widget.padding,
          buttonRect: widget.buttonRect,
          constraints: widget.constraints,
          itemIndex: itemIndex,
          enableFeedback: widget.enableFeedback,
          customItemsIndexes: widget.customItemsIndexes,
          customItemsHeight: widget.customItemsHeight,
        ),
    ];

    return FadeTransition(
      opacity: _fadeOpacity,
      child: CustomPaint(
        painter: _DropdownMenuPainter(
          color: Theme.of(context).canvasColor,
          elevation: route.elevation,
          selectedIndex: route.selectedIndex,
          resize: _resize,

          getSelectedItemOffset: () => route.getItemOffset(0),

          itemHeight: widget.itemHeight,
          dropdownDecoration: widget.dropdownDecoration,
        ),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          explicitChildNodes: true,
          label: localizations.popupMenuLabel,
          child: Material(
            type: MaterialType.transparency,
            textStyle: route.style,
            //Prevent scrollbar, ripple effect & items from going beyond border boundaries when scrolling.
            clipBehavior: Clip.antiAlias,
            borderRadius: widget.dropdownDecoration?.borderRadius
                ?.resolve(Directionality.of(context)) ??
                const BorderRadius.all(Radius.circular(2.0)),
            child: ScrollConfiguration(
              // Dropdown menus should never overscroll or display an overscroll indicator.
              // Scrollbars are built-in below.
              // Platform must use Theme and ScrollPhysics must be Clamping.
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                overscroll: false,
                physics: const ClampingScrollPhysics(),
                platform: Theme.of(context).platform,
              ),
              child: PrimaryScrollController(
                controller: widget.route.scrollController!,
                child: Scrollbar(
                  radius: widget.scrollbarRadius,
                  thickness: widget.scrollbarThickness,
                  thumbVisibility: widget.scrollbarAlwaysShow,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: widget.dropdownPadding ?? kMaterialListPadding,
                    shrinkWrap: true,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuRouteLayout<T> extends SingleChildLayoutDelegate {
  _DropdownMenuRouteLayout({
    required this.buttonRect,
    required this.route,
    required this.textDirection,
    required this.itemHeight,
    this.itemWidth,
    required this.offset,
  });

  final Rect buttonRect;
  final _DropdownRoute<T> route;
  final TextDirection? textDirection;
  final double itemHeight;
  final double? itemWidth;
  final Offset offset;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {

    double maxHeight = math.max(0.0, constraints.maxHeight - 2 * itemHeight);
    if (route.menuMaxHeight != null && route.menuMaxHeight! <= maxHeight) {
      maxHeight = route.menuMaxHeight!;
    }

    final double width =
        itemWidth ?? math.min(constraints.maxWidth, buttonRect.width);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final _MenuLimits menuLimits =
    route.getMenuLimits(buttonRect, size.height, route.selectedIndex);

    assert(() {
      final Rect container = Offset.zero & size;
      if (container.intersect(buttonRect) == buttonRect) {

        assert(menuLimits.top >= 0.0);
        assert(menuLimits.top + menuLimits.height <= size.height);
      }
      return true;
    }());
    assert(textDirection != null);
    final double left;
    switch (textDirection!) {
      case TextDirection.rtl:
        left = (buttonRect.right + offset.dx).clamp(0.0, size.width) -
            childSize.width;
        break;
      case TextDirection.ltr:
        left = (buttonRect.left + offset.dx)
            .clamp(0.0, size.width - childSize.width);
        break;
    }

    return Offset(left, menuLimits.top);
  }

  @override
  bool shouldRelayout(_DropdownMenuRouteLayout<T> oldDelegate) {
    return buttonRect != oldDelegate.buttonRect ||
        textDirection != oldDelegate.textDirection;
  }
}



class _DropdownRouteResult<T> {
  const _DropdownRouteResult(this.result);

  final T? result;

  @override
  bool operator ==(Object other) {
    return other is _DropdownRouteResult<T> && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;
}

class _MenuLimits {
  const _MenuLimits(this.top, this.bottom, this.height, this.scrollOffset);

  final double top;
  final double bottom;
  final double height;
  final double scrollOffset;
}

class _DropdownRoute<T> extends PopupRoute<_DropdownRouteResult<T>> {
  _DropdownRoute({
    required this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    required this.isNoSelectedItem,
    this.selectedItemHighlightColor,
    this.elevation = 8,
    required this.capturedThemes,
    required this.style,
    this.barrierLabel,
    required this.enableFeedback,
    required this.itemHeight,
    this.itemWidth,
    this.menuMaxHeight,
    this.dropdownDecoration,
    this.dropdownPadding,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    required this.offset,
    required this.showAboveButton,
    this.customItemsIndexes,
    this.customItemsHeight,
  }) : itemHeights = List<double>.filled(items.length, itemHeight);

  final List<_MenuItem<T>> items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final bool isNoSelectedItem;
  final Color? selectedItemHighlightColor;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle style;
  final bool enableFeedback;
  final double itemHeight;
  final double? itemWidth;
  final double? menuMaxHeight;
  final BoxDecoration? dropdownDecoration;
  final EdgeInsetsGeometry? dropdownPadding;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;
  final bool showAboveButton;
  final List<int>? customItemsIndexes;
  final double? customItemsHeight;

  final List<double> itemHeights;
  ScrollController? scrollController;

  @override
  Duration get transitionDuration => _kDropdownMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String? barrierLabel;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return _DropdownRoutePage<T>(
          route: this,
          constraints: constraints,
          items: items,
          padding: padding,
          buttonRect: buttonRect,
          selectedIndex: selectedIndex,
          elevation: elevation,
          capturedThemes: capturedThemes,
          style: style,
          enableFeedback: enableFeedback,
          dropdownDecoration: dropdownDecoration,
          dropdownPadding: dropdownPadding,
          menuMaxHeight: menuMaxHeight,
          itemHeight: itemHeight,
          itemWidth: itemWidth,
          scrollbarRadius: scrollbarRadius,
          scrollbarThickness: scrollbarThickness,
          scrollbarAlwaysShow: scrollbarAlwaysShow,
          offset: offset,
          customItemsIndexes: customItemsIndexes,
          customItemsHeight: customItemsHeight,
        );
      },
    );
  }

  void _dismiss() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  double getItemOffset(int index) {
    double offset = kMaterialListPadding.top;
    if (items.isNotEmpty && index > 0) {
      assert(items.length == itemHeights.length);
      offset += itemHeights
          .sublist(0, index)
          .reduce((double total, double height) => total + height);
    }
    return offset;
  }


  _MenuLimits getMenuLimits(
      Rect buttonRect, double availableHeight, int index) {
    double computedMaxHeight = availableHeight - 2.0 * itemHeight;
    if (menuMaxHeight != null) {
      computedMaxHeight = math.min(computedMaxHeight, menuMaxHeight!);
    }
    final double buttonTop = buttonRect.top;
    final double buttonBottom = math.min(buttonRect.bottom, availableHeight);
    final double selectedItemOffset = getItemOffset(index);


    final double topLimit = math.min(itemHeight, buttonTop);
    final double bottomLimit = math.max(availableHeight, buttonBottom);
    double menuTop =
    showAboveButton ? buttonTop - offset.dy : buttonBottom - offset.dy;
    double preferredMenuHeight = dropdownPadding != null
        ? dropdownPadding!.vertical
        : kMaterialListPadding.vertical;
    if (items.isNotEmpty) {
      preferredMenuHeight +=
          itemHeights.reduce((double total, double height) => total + height);
    }

    final double menuHeight = math.min(computedMaxHeight, preferredMenuHeight);
    double menuBottom = menuTop + menuHeight;

    if (menuTop < topLimit) {
      menuTop = math.min(buttonTop, topLimit);
      menuBottom = menuTop + menuHeight;
    }

    if (menuBottom > bottomLimit) {
      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    if (menuBottom - itemHeights[selectedIndex] / 2.0 <
        buttonBottom - buttonRect.height / 2.0) {

      menuBottom = math.max(buttonBottom, bottomLimit);
      menuTop = menuBottom - menuHeight;
    }

    double scrollOffset = 0;

    if (preferredMenuHeight > computedMaxHeight) {

      scrollOffset = math.max(
          0.0,
          selectedItemOffset -
              (menuHeight / 2) +
              (itemHeights[selectedIndex] / 2));

      scrollOffset = math.min(scrollOffset, preferredMenuHeight - menuHeight);
    }

    assert((menuBottom - menuTop - menuHeight).abs() < precisionErrorTolerance);
    return _MenuLimits(menuTop, menuBottom, menuHeight, scrollOffset);
  }
}

class _DropdownRoutePage<T> extends StatelessWidget {
  const _DropdownRoutePage({
    super.key,
    required this.route,
    required this.constraints,
    this.items,
    required this.padding,
    required this.buttonRect,
    required this.selectedIndex,
    this.elevation = 8,
    required this.capturedThemes,
    this.style,
    required this.enableFeedback,
    this.dropdownDecoration,
    this.dropdownPadding,
    this.menuMaxHeight,
    required this.itemHeight,
    this.itemWidth,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    required this.offset,
    this.customItemsIndexes,
    this.customItemsHeight,
  });

  final _DropdownRoute<T> route;
  final BoxConstraints constraints;
  final List<_MenuItem<T>>? items;
  final EdgeInsetsGeometry padding;
  final Rect buttonRect;
  final int selectedIndex;
  final int elevation;
  final CapturedThemes capturedThemes;
  final TextStyle? style;
  final bool enableFeedback;
  final BoxDecoration? dropdownDecoration;
  final EdgeInsetsGeometry? dropdownPadding;
  final double? menuMaxHeight;
  final double itemHeight;
  final double? itemWidth;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;
  final List<int>? customItemsIndexes;
  final double? customItemsHeight;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    if (route.scrollController == null) {
      final _MenuLimits menuLimits =
      route.getMenuLimits(buttonRect, constraints.maxHeight, selectedIndex);
      route.scrollController =
          ScrollController(initialScrollOffset: menuLimits.scrollOffset);
    }

    final TextDirection? textDirection = Directionality.maybeOf(context);
    final Widget menu = _DropdownMenu<T>(
      route: route,
      padding: padding.resolve(textDirection),
      buttonRect: buttonRect,
      constraints: constraints,
      enableFeedback: enableFeedback,
      itemHeight: itemHeight,
      dropdownDecoration: dropdownDecoration,
      dropdownPadding: dropdownPadding,
      scrollbarRadius: scrollbarRadius,
      scrollbarThickness: scrollbarThickness,
      scrollbarAlwaysShow: scrollbarAlwaysShow,
      offset: offset,
      customItemsIndexes: customItemsIndexes,
      customItemsHeight: customItemsHeight,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _DropdownMenuRouteLayout<T>(
              buttonRect: buttonRect,
              route: route,
              textDirection: textDirection,
              itemHeight: itemHeight,
              itemWidth: itemWidth,
              offset: offset,
            ),
            child: capturedThemes.wrap(menu),
          );
        },
      ),
    );
  }
}


class _MenuItem<T> extends SingleChildRenderObjectWidget {
  const _MenuItem({
    super.key,
    required this.onLayout,
    required this.item,
  }) : super(child: item);

  final ValueChanged<Size> onLayout;
  final DropdownMenuItem<T>? item;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMenuItem(onLayout);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _RenderMenuItem renderObject) {
    renderObject.onLayout = onLayout;
  }
}

class _RenderMenuItem extends RenderProxyBox {
  _RenderMenuItem(this.onLayout, [RenderBox? child]) : super(child);

  ValueChanged<Size> onLayout;

  @override
  void performLayout() {
    super.performLayout();
    onLayout(size);
  }
}


class _DropdownMenuItemContainer extends StatelessWidget {

  const _DropdownMenuItemContainer({
    Key? key,
    this.alignment = AlignmentDirectional.centerStart,
    required this.child,
  }) : super(key: key);


  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: _kMenuItemHeight),
      alignment: alignment,
      child: child,
    );
  }
}


class CustomDropdown<T> extends StatefulWidget {
  /// Creates a DropdownButton2
  /// It's customizable DropdownButton with steady dropdown menu and many other features.
  ///
  /// The [items] must have distinct values. If [value] isn't null then it
  /// must be equal to one of the [DropdownMenuItem] values. If [items] or
  /// [onChanged] is null, the button will be disabled, the down arrow
  /// will be greyed out.
  ///
  /// If [value] is null and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  CustomDropdown({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    this.onChanged,
    this.dropdownElevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconOnClick,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.itemPadding,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.selectedItemHighlightColor,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset,
    this.customButton,
    this.customItemsIndexes,
    this.customItemsHeight,
    this.openWithLongPress = false,
    this.dropdownOverButton = false,
    this.dropdownFullScreen = false,
    this.onMenuStateChange,
    // When adding new arguments, consider adding similar arguments to
    // DropdownButtonFormField.
  })  : assert(
  items == null ||
      items.isEmpty ||
      value == null ||
      items.where((DropdownMenuItem<T> item) {
        return item.value == value;
      }).length ==
          1,
  "There should be exactly one item with [DropdownButton]'s value: "
      '$value. \n'
      'Either zero or 2 or more [DropdownMenuItem]s were detected '
      'with the same value',
  ),
        _inputDecoration = null,
        _isEmpty = false;

  CustomDropdown._formField({
    super.key,
    required this.items,
    this.selectedItemBuilder,
    this.value,
    this.hint,
    this.disabledHint,
    required this.onChanged,
    this.onMenuStateChange,
    this.dropdownElevation = 8,
    this.style,
    this.underline,
    this.icon,
    this.iconOnClick,
    this.iconDisabledColor,
    this.iconEnabledColor,
    this.iconSize = 24.0,
    this.isDense = false,
    this.isExpanded = false,
    this.itemHeight = kMinInteractiveDimension,
    this.focusColor,
    this.focusNode,
    this.autofocus = false,
    this.dropdownMaxHeight,
    this.enableFeedback,
    this.alignment = AlignmentDirectional.centerStart,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.itemPadding,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.selectedItemHighlightColor,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.offset,
    this.customButton,
    this.customItemsIndexes,
    this.customItemsHeight,
    this.openWithLongPress = false,
    this.dropdownOverButton = false,
    this.dropdownFullScreen = false,
    required InputDecoration inputDecoration,
    required bool isEmpty,
  })  : assert(
  items == null ||
      items.isEmpty ||
      value == null ||
      items.where((DropdownMenuItem<T> item) {
        return item.value == value;
      }).length ==
          1,
  "There should be exactly one item with [DropdownButtonFormField]'s value: "
      '$value. \n'
      'Either zero or 2 or more [DropdownMenuItem]s were detected '
      'with the same value',
  ),
        _inputDecoration = inputDecoration,
        _isEmpty = isEmpty;

  // Parameters added By Me

  ///The height of the button.
  final double? buttonHeight;

  ///The width of the button
  final double? buttonWidth;

  ///The inner padding of the Button
  final EdgeInsetsGeometry? buttonPadding;

  ///The decoration of the Button
  final BoxDecoration? buttonDecoration;

  ///The elevation of the Button
  final int? buttonElevation;

  ///The padding of menu items
  final EdgeInsetsGeometry? itemPadding;

  ///The width of the dropdown menu
  final double? dropdownWidth;

  ///The inner padding of the dropdown menu
  final EdgeInsetsGeometry? dropdownPadding;

  ///The decoration of the dropdown menu
  final BoxDecoration? dropdownDecoration;

  ///The highlight color of the current selected item
  final Color? selectedItemHighlightColor;

  ///The radius of the scrollbar's corners
  final Radius? scrollbarRadius;

  ///The thickness of the scrollbar
  final double? scrollbarThickness;

  ///Always show the scrollbar even when a scroll is not underway
  final bool? scrollbarAlwaysShow;

  ///Changes the position of the dropdown menu
  final Offset? offset;

  ///Uses custom widget like icon,image,etc.. instead of the default button
  final Widget? customButton;

  ///Indexes of the items you want to give different height (useful for adding dividers)
  final List<int>? customItemsIndexes;

  ///The height of the items you passed their indexes using [customItemsIndexes] parameter
  final double? customItemsHeight;

  ///Opens the dropdown menu on long-pressing instead of tapping
  final bool openWithLongPress;

  ///Opens the dropdown menu over the button instead of below it
  final bool dropdownOverButton;

  ///Opens the dropdown menu in fullscreen mode (Above AppBar & TabBar)
  final bool dropdownFullScreen;

  ///Shows different icon when dropdown menu open
  final Widget? iconOnClick;

  ///Called when the dropdown menu is opened or closed.
  final void Function(bool isOpen)? onMenuStateChange;

  /// The list of items the user can select.
  ///
  /// If the [onChanged] callback is null or the list of items is null
  /// then the dropdown button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input.
  final List<DropdownMenuItem<T>>? items;

  /// The value of the currently selected [DropdownMenuItem].
  ///
  /// If [value] is null and the button is enabled, [hint] will be displayed
  /// if it is non-null.
  ///
  /// If [value] is null and the button is disabled, [disabledHint] will be displayed
  /// if it is non-null. If [disabledHint] is null, then [hint] will be displayed
  /// if it is non-null.
  final T? value;

  /// A placeholder widget that is displayed by the dropdown button.
  ///
  /// If [value] is null and the dropdown is enabled ([items] and [onChanged] are non-null),
  /// this widget is displayed as a placeholder for the dropdown button's value.
  ///
  /// If [value] is null and the dropdown is disabled and [disabledHint] is null,
  /// this widget is used as the placeholder.
  final Widget? hint;

  /// A preferred placeholder widget that is displayed when the dropdown is disabled.
  ///
  /// If [value] is null, the dropdown is disabled ([items] or [onChanged] is null),
  /// this widget is displayed as a placeholder for the dropdown button's value.
  final Widget? disabledHint;

  /// {@template flutter.material.dropdownButton.onChanged}
  /// Called when the user selects an item.
  ///
  /// If the [onChanged] callback is null or the list of [CustomDropdown.items]
  /// is null then the dropdown button will be disabled, i.e. its arrow will be
  /// displayed in grey and it will not respond to input. A disabled button
  /// will display the [CustomDropdown.disabledHint] widget if it is non-null.
  /// If [CustomDropdown.disabledHint] is also null but [CustomDropdown.hint] is
  /// non-null, [CustomDropdown.hint] will instead be displayed.
  /// {@endtemplate}
  final ValueChanged<T?>? onChanged;

  /// A builder to customize the dropdown buttons corresponding to the
  /// [DropdownMenuItem]s in [items].
  ///
  /// When a [DropdownMenuItem] is selected, the widget that will be displayed
  /// from the list corresponds to the [DropdownMenuItem] of the same index
  /// in [items].
  ///
  /// {@tool dartpad}
  /// This sample shows a `DropdownButton` with a button with [Text] that
  /// corresponds to but is unique from [DropdownMenuItem].
  ///
  /// ** See code in examples/api/lib/material/dropdown/dropdown_button.selected_item_builder.0.dart **
  /// {@end-tool}
  ///
  /// If this callback is null, the [DropdownMenuItem] from [items]
  /// that matches [value] will be displayed.
  final DropdownButtonBuilder? selectedItemBuilder;

  /// The z-coordinate at which to place the menu when open.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12,
  /// 16, and 24. See [kElevationToShadow].
  ///
  /// Defaults to 8, the appropriate elevation for dropdown buttons.
  final int dropdownElevation;

  /// The text style to use for text in the dropdown button and the dropdown
  /// menu that appears when you tap the button.
  ///
  /// To use a separate text style for selected item when it's displayed within
  /// the dropdown button, consider using [selectedItemBuilder].
  ///
  /// {@tool dartpad}
  /// This sample shows a `DropdownButton` with a dropdown button text style
  /// that is different than its menu items.
  ///
  /// ** See code in examples/api/lib/material/dropdown/dropdown_button.style.0.dart **
  /// {@end-tool}
  ///
  /// Defaults to the [TextTheme.subtitle1] value of the current
  /// [ThemeData.textTheme] of the current [Theme].
  final TextStyle? style;

  /// The widget to use for drawing the drop-down button's underline.
  ///
  /// Defaults to a 0.0 width bottom border with color 0xFFBDBDBD.
  final Widget? underline;

  /// The widget to use for the drop-down button's icon.
  ///
  /// Defaults to an [Icon] with the [Icons.arrow_drop_down] glyph.
  final Widget? icon;

  /// The color of any [Icon] descendant of [icon] if this button is disabled,
  /// i.e. if [onChanged] is null.
  ///
  /// Defaults to [MaterialColor.shade400] of [Colors.grey] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white10] when it is [Brightness.dark]
  final Color? iconDisabledColor;

  /// The color of any [Icon] descendant of [icon] if this button is enabled,
  /// i.e. if [onChanged] is defined.
  ///
  /// Defaults to [MaterialColor.shade700] of [Colors.grey] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white70] when it is [Brightness.dark]
  final Color? iconEnabledColor;

  /// The size to use for the drop-down button's icon.
  ///
  /// Defaults to 24.0.
  final double iconSize;

  /// Reduce the button's height.
  ///
  /// By default this button's height is the same as its menu items' heights.
  /// If isDense is true, the button's height is reduced by about half. This
  /// can be useful when the button is embedded in a container that adds
  /// its own decorations, like [InputDecorator].
  final bool isDense;

  /// Set the dropdown's inner contents to horizontally fill its parent.
  ///
  /// By default this button's inner width is the minimum size of its contents.
  /// If [isExpanded] is true, the inner width is expanded to fill its
  /// surrounding container.
  final bool isExpanded;

  /// If null, then the menu item heights will vary according to each menu item's
  /// intrinsic height.
  ///
  /// The default value is [kMinInteractiveDimension], which is also the minimum
  /// height for menu items.
  ///
  /// If this value is null and there isn't enough vertical room for the menu,
  /// then the menu's initial scroll offset may not align the selected item with
  /// the dropdown button. That's because, in this case, the initial scroll
  /// offset is computed as if all of the menu item heights were
  /// [kMinInteractiveDimension].
  final double itemHeight;

  /// The color for the button's [Material] when it has the input focus.
  final Color? focusColor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// The maximum height of the menu.
  ///
  /// The maximum height of the menu must be at least one row shorter than
  /// the height of the app's view. This ensures that a tappable area
  /// outside of the simple menu is present so the user can dismiss the menu.
  ///
  /// If this property is set above the maximum allowable height threshold
  /// mentioned above, then the menu defaults to being padded at the top
  /// and bottom of the menu by at one menu item's height.
  final double? dropdownMaxHeight;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// By default, platform-specific feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// Defines how the hint or the selected item is positioned within the button.
  ///
  /// This property must not be null. It defaults to [AlignmentDirectional.centerStart].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  final InputDecoration? _inputDecoration;
  final bool _isEmpty;

  @override
  State<CustomDropdown<T>> createState() => CustomDropdownState<T>();
}

class CustomDropdownState<T> extends State<CustomDropdown<T>>
    with WidgetsBindingObserver {
  int? _selectedIndex;
  _DropdownRoute<T>? _dropdownRoute;
  Orientation? _lastOrientation;
  FocusNode? _internalNode;

  FocusNode? get focusNode => widget.focusNode ?? _internalNode;
  bool _hasPrimaryFocus = false;
  late Map<Type, Action<Intent>> _actionMap;
  bool _isMenuOpen = false;

  FocusNode _createFocusNode() {
    return FocusNode(debugLabel: '${widget.runtimeType}');
  }

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
    if (widget.focusNode == null) {
      _internalNode ??= _createFocusNode();
    }
    _actionMap = <Type, Action<Intent>>{
      ActivateIntent: CallbackAction<ActivateIntent>(
        onInvoke: (ActivateIntent intent) => _handleTap(),
      ),
      ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
        onInvoke: (ButtonActivateIntent intent) => _handleTap(),
      ),
    };
    focusNode!.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeDropdownRoute();
    focusNode!.removeListener(_handleFocusChanged);
    _internalNode?.dispose();
    super.dispose();
  }

  void _removeDropdownRoute() {
    _dropdownRoute?._dismiss();
    _dropdownRoute = null;
    _lastOrientation = null;
  }

  void _handleFocusChanged() {
    if (_hasPrimaryFocus != focusNode!.hasPrimaryFocus) {
      setState(() {
        _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      });
    }
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChanged);
      if (widget.focusNode == null) {
        _internalNode ??= _createFocusNode();
      }
      _hasPrimaryFocus = focusNode!.hasPrimaryFocus;
      focusNode!.addListener(_handleFocusChanged);
    }
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    if (widget.items == null ||
        widget.items!.isEmpty ||
        (widget.value == null &&
            widget.items!
                .where((DropdownMenuItem<T> item) =>
            item.enabled && item.value == widget.value)
                .isEmpty)) {
      _selectedIndex = null;
      return;
    }

    assert(widget.items!
        .where((DropdownMenuItem<T> item) => item.value == widget.value)
        .length ==
        1);
    for (int itemIndex = 0; itemIndex < widget.items!.length; itemIndex++) {
      if (widget.items![itemIndex].value == widget.value) {
        _selectedIndex = itemIndex;
        return;
      }
    }
  }

  TextStyle? get _textStyle =>
      widget.style ?? Theme.of(context).textTheme.bodyLarge;

  void _handleTap() {
    final TextDirection? textDirection = Directionality.maybeOf(context);
    const EdgeInsetsGeometry menuMargin = EdgeInsets.zero;

    final List<_MenuItem<T>> menuItems = <_MenuItem<T>>[
      for (int index = 0; index < widget.items!.length; index += 1)
        _MenuItem<T>(
          item: widget.items![index],
          onLayout: (Size size) {
            // If [_dropdownRoute] is null and onLayout is called, this means
            // that performLayout was called on a _DropdownRoute that has not
            // left the widget tree but is already on its way out.
            //
            // Since onLayout is used primarily to collect the desired heights
            // of each menu item before laying them out, not having the _DropdownRoute
            // collect each item's height to lay out is fine since the route is
            // already on its way out.
            if (_dropdownRoute == null) return;

            _dropdownRoute!.itemHeights[index] = size.height;
          },
        ),
    ];

    final NavigatorState navigator =
    Navigator.of(context, rootNavigator: widget.dropdownFullScreen);
    assert(_dropdownRoute == null);
    final RenderBox itemBox = context.findRenderObject()! as RenderBox;
    final Rect itemRect = itemBox.localToGlobal(Offset.zero,
        ancestor: navigator.context.findRenderObject()) &
    itemBox.size;
    _dropdownRoute = _DropdownRoute<T>(
      items: menuItems,
      buttonRect: menuMargin.resolve(textDirection).inflateRect(itemRect),
      padding: widget.itemPadding ?? _kMenuItemPadding.resolve(textDirection),
      selectedIndex: _selectedIndex ?? 0,
      isNoSelectedItem: _selectedIndex == null,
      selectedItemHighlightColor: widget.selectedItemHighlightColor,
      elevation: widget.dropdownElevation,
      capturedThemes:
      InheritedTheme.capture(from: context, to: navigator.context),
      style: _textStyle!,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      enableFeedback: widget.enableFeedback ?? true,
      itemHeight: widget.itemHeight,
      itemWidth: widget.dropdownWidth,
      menuMaxHeight: widget.dropdownMaxHeight,
      dropdownDecoration: widget.dropdownDecoration,
      dropdownPadding: widget.dropdownPadding,
      scrollbarRadius: widget.scrollbarRadius,
      scrollbarThickness: widget.scrollbarThickness,
      scrollbarAlwaysShow: widget.scrollbarAlwaysShow,
      offset: widget.offset ?? const Offset(0, 0),
      showAboveButton: widget.dropdownOverButton,
      customItemsIndexes: widget.customItemsIndexes,
      customItemsHeight: widget.customItemsHeight,
    );

    _isMenuOpen = true;
    focusNode?.requestFocus();
    navigator
        .push(_dropdownRoute!)
        .then<void>((_DropdownRouteResult<T>? newValue) {
      _removeDropdownRoute();
      _isMenuOpen = false;
      widget.onMenuStateChange?.call(false);
      if (!mounted || newValue == null) return;
      widget.onChanged?.call(newValue.result);
    });

    widget.onMenuStateChange?.call(true);
  }

  // This expose the _handleTap() to Allow opening the button programmatically using GlobalKey.
  // Also, DropdownButton2State should be public as we need typed access to it through key.
  void callTap() => _handleTap();

  // When isDense is true, reduce the height of this button from _kMenuItemHeight to
  // _kDenseButtonHeight, but don't make it smaller than the text that it contains.
  // Similarly, we don't reduce the height of the button so much that its icon
  // would be clipped.
  double get _denseButtonHeight {
    final double fontSize = _textStyle!.fontSize ??
        Theme.of(context).textTheme.bodySmall!.fontSize!;
    return math.max(fontSize, math.max(widget.iconSize, _kDenseButtonHeight));
  }

  Color get _iconColor {
    // These colors are not defined in the Material Design spec.
    if (_enabled) {
      if (widget.iconEnabledColor != null) return widget.iconEnabledColor!;

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade700;
        case Brightness.dark:
          return Colors.white70;
      }
    } else {
      if (widget.iconDisabledColor != null) return widget.iconDisabledColor!;

      switch (Theme.of(context).brightness) {
        case Brightness.light:
          return Colors.grey.shade400;
        case Brightness.dark:
          return Colors.white10;
      }
    }
  }

  bool get _enabled =>
      widget.items != null &&
          widget.items!.isNotEmpty &&
          widget.onChanged != null;

  Orientation _getOrientation(BuildContext context) {
    Orientation? result = MediaQuery.maybeOf(context)?.orientation;
    if (result == null) {
      // If there's no MediaQuery, then use the window aspect to determine
      // orientation.
      final Size size = WidgetsBinding.instance.window.physicalSize;
      result = size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final Orientation newOrientation = _getOrientation(context);
    _lastOrientation ??= newOrientation;
    if (newOrientation != _lastOrientation) {
      _removeDropdownRoute();
      _lastOrientation = newOrientation;
    }

    // The width of the button and the menu are defined by the widest
    // item and the width of the hint.
    // We should explicitly type the items list to be a list of <Widget>,
    // otherwise, no explicit type adding items maybe trigger a crash/failure
    // when hint and selectedItemBuilder are provided.
    final List<Widget> items = widget.selectedItemBuilder == null
        ? (widget.items != null ? List<Widget>.of(widget.items!) : <Widget>[])
        : List<Widget>.of(widget.selectedItemBuilder!(context));

    int? hintIndex;
    if (widget.hint != null || (!_enabled && widget.disabledHint != null)) {
      Widget displayedHint =
      _enabled ? widget.hint! : widget.disabledHint ?? widget.hint!;
      if (widget.selectedItemBuilder == null) {
        displayedHint = _DropdownMenuItemContainer(
          child: displayedHint,
          alignment: widget.alignment,
        );
      }

      hintIndex = items.length;
      items.add(DefaultTextStyle(
        style: _textStyle!.copyWith(color: Theme.of(context).hintColor),
        child: IgnorePointer(
          ignoringSemantics: false,
          child: displayedHint,
        ),
      ));
    }

    final EdgeInsetsGeometry padding = ButtonTheme.of(context).alignedDropdown
        ? _kAlignedButtonPadding
        : _kUnalignedButtonPadding;

    // If value is null (then _selectedIndex is null) then we
    // display the hint or nothing at all.
    final Widget innerItemsWidget;
    if (items.isEmpty) {
      innerItemsWidget = Container();
    } else {
      innerItemsWidget = IndexedStack(
        index: _selectedIndex ?? hintIndex,
        alignment: widget.alignment,
        children: widget.isDense
            ? items
            : items.map((Widget item) {
          return SizedBox(height: widget.itemHeight, child: item);
        }).toList(),
      );
    }

    const Icon defaultIcon = Icon(Icons.arrow_drop_down);

    Widget result = DefaultTextStyle(
      style: _enabled
          ? _textStyle!
          : _textStyle!.copyWith(color: Theme.of(context).disabledColor),
      child: widget.customButton ??
          Container(
            decoration: widget.buttonDecoration?.copyWith(
              boxShadow: kElevationToShadow[widget.buttonElevation ?? 0],
            ),
            padding: widget.buttonPadding ??
                padding.resolve(Directionality.of(context)),
            height: widget.buttonHeight ??
                (widget.isDense ? _denseButtonHeight : null),
            width: widget.buttonWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (widget.isExpanded)
                  Expanded(child: innerItemsWidget)
                else
                  innerItemsWidget,
                IconTheme(
                  data: IconThemeData(
                    color: _iconColor,
                    size: widget.iconSize,
                  ),
                  child: widget.iconOnClick != null
                      ? _isMenuOpen
                      ? widget.iconOnClick!
                      : widget.icon!
                      : widget.icon ?? defaultIcon,
                ),
              ],
            ),
          ),
    );

    if (!DropdownButtonHideUnderline.at(context)) {
      final double bottom = widget.isDense ? 0.0 : 8.0;
      result = Stack(
        children: <Widget>[
          result,
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: bottom,
            child: widget.underline ??
                Container(
                  height: 1.0,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFBDBDBD),
                        width: 0.0,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      );
    }

    final MouseCursor effectiveMouseCursor =
    MaterialStateProperty.resolveAs<MouseCursor>(
      MaterialStateMouseCursor.clickable,
      <MaterialState>{
        if (!_enabled) MaterialState.disabled,
      },
    );

    if (widget._inputDecoration != null) {
      result = InputDecorator(
        decoration: widget._inputDecoration!,
        isEmpty: widget._isEmpty,
        isFocused: _isMenuOpen,
        child: result,
      );
    }

    return Semantics(
      button: true,
      child: Actions(
        actions: _actionMap,
        child: InkWell(
          mouseCursor: effectiveMouseCursor,
          onTap: _enabled ? _handleTap : null,
          canRequestFocus: _enabled,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          focusColor: widget.buttonDecoration?.color ??
              widget.focusColor ??
              Theme.of(context).focusColor,
          enableFeedback: false,
          child: result,
          borderRadius: widget.dropdownDecoration?.borderRadius
              ?.resolve(Directionality.of(context)),
        ),
      ),
    );
  }
}


class CustomDropFormField<T> extends FormField<T> {
  /// Creates a [CustomDropdown] widget that is a [FormField], wrapped in an
  /// [InputDecorator].
  ///
  /// For a description of the `onSaved`, `validator`, or `autovalidateMode`
  /// parameters, see [FormField]. For the rest (other than [decoration]), see
  /// [CustomDropdown].
  ///
  /// The `items`, `elevation`, `iconSize`, `isDense`, `isExpanded`,
  /// `autofocus`, and `decoration`  parameters must not be null.
  CustomDropFormField({
    super.key,
    required List<DropdownMenuItem<T>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    T? value,
    Widget? hint,
    Widget? disabledHint,
    this.onChanged,
    int dropdownElevation = 8,
    TextStyle? style,
    Widget? icon,
    Widget? iconOnClick,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double itemHeight = kMinInteractiveDimension,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    InputDecoration? decoration,
    super.onSaved,
    super.validator,
    AutovalidateMode? autovalidateMode,
    double? dropdownMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    double? buttonHeight,
    double? buttonWidth,
    EdgeInsetsGeometry? buttonPadding,
    BoxDecoration? buttonDecoration,
    int? buttonElevation,
    EdgeInsetsGeometry? itemPadding,
    double? dropdownWidth,
    EdgeInsetsGeometry? dropdownPadding,
    BoxDecoration? dropdownDecoration,
    Color? selectedItemHighlightColor,
    Radius? scrollbarRadius,
    double? scrollbarThickness,
    bool? scrollbarAlwaysShow,
    Offset? offset,
    Widget? customButton,
    List<int>? customItemsIndexes,
    double? customItemsHeight,
    bool openWithLongPress = false,
    bool dropdownOverButton = false,
    bool dropdownFullScreen = false,
    void Function(bool isOpen)? onMenuStateChange,
  })  : assert(
  items == null ||
      items.isEmpty ||
      value == null ||
      items.where((DropdownMenuItem<T> item) {
        return item.value == value;
      }).length ==
          1,
  "There should be exactly one item with [DropdownButton]'s value: "
      '$value. \n'
      'Either zero or 2 or more [DropdownMenuItem]s were detected '
      'with the same value',
  ),
        decoration = decoration ?? InputDecoration(focusColor: focusColor),
        super(
        initialValue: value,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        builder: (FormFieldState<T> field) {
          final _DropdownButtonFormFieldState<T> state =
          field as _DropdownButtonFormFieldState<T>;
          final InputDecoration decorationArg =
              decoration ?? InputDecoration(focusColor: focusColor);
          final InputDecoration effectiveDecoration =
          decorationArg.applyDefaults(
            Theme.of(field.context).inputDecorationTheme,
          );

          final bool showSelectedItem = items != null &&
              items
                  .where(
                      (DropdownMenuItem<T> item) => item.value == state.value)
                  .isNotEmpty;
          bool isHintOrDisabledHintAvailable() {
            final bool isDropdownDisabled =
                onChanged == null || (items == null || items.isEmpty);
            if (isDropdownDisabled) {
              return hint != null || disabledHint != null;
            } else {
              return hint != null;
            }
          }

          final bool isEmpty =
              !showSelectedItem && !isHintOrDisabledHintAvailable();

          // An unfocusable Focus widget so that this widget can detect if its
          // descendants have focus or not.
          return Focus(
            canRequestFocus: false,
            skipTraversal: true,
            child: Builder(builder: (BuildContext context) {
              return DropdownButtonHideUnderline(
                child: CustomDropdown._formField(
                  items: items,
                  selectedItemBuilder: selectedItemBuilder,
                  value: state.value,
                  hint: hint,
                  disabledHint: disabledHint,
                  onChanged: onChanged == null ? null : state.didChange,
                  dropdownElevation: dropdownElevation,
                  style: style,
                  icon: icon,
                  iconOnClick: iconOnClick,
                  iconDisabledColor: iconDisabledColor,
                  iconEnabledColor: iconEnabledColor,
                  iconSize: iconSize,
                  isDense: isDense,
                  isExpanded: isExpanded,
                  itemHeight: itemHeight,
                  focusColor: focusColor,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  dropdownMaxHeight: dropdownMaxHeight,
                  enableFeedback: enableFeedback,
                  alignment: alignment,
                  buttonHeight: buttonHeight,
                  buttonWidth: buttonWidth,
                  buttonPadding: buttonPadding,
                  buttonDecoration: buttonDecoration,
                  buttonElevation: buttonElevation,
                  itemPadding: itemPadding,
                  dropdownWidth: dropdownWidth,
                  dropdownPadding: dropdownPadding,
                  dropdownDecoration: dropdownDecoration,
                  selectedItemHighlightColor: selectedItemHighlightColor,
                  scrollbarRadius: scrollbarRadius,
                  scrollbarThickness: scrollbarThickness,
                  scrollbarAlwaysShow: scrollbarAlwaysShow,
                  offset: offset,
                  customButton: customButton,
                  customItemsIndexes: customItemsIndexes,
                  customItemsHeight: customItemsHeight,
                  openWithLongPress: openWithLongPress,
                  dropdownOverButton: dropdownOverButton,
                  dropdownFullScreen: dropdownFullScreen,
                  onMenuStateChange: onMenuStateChange,
                  inputDecoration: effectiveDecoration.copyWith(
                    errorText: field.errorText,
                  ),
                  isEmpty: isEmpty,
                ),
              );
            }),
          );
        },
      );

  /// {@macro flutter.material.dropdownButton.onChanged}
  final ValueChanged<T?>? onChanged;

  /// The decoration to show around the dropdown button form field.
  ///
  /// By default, draws a horizontal line under the dropdown button field but
  /// can be configured to show an icon, label, hint text, and error text.
  ///
  /// If not specified, an [InputDecorator] with the `focusColor` set to the
  /// supplied `focusColor` (if any) will be used.
  final InputDecoration decoration;

  @override
  FormFieldState<T> createState() => _DropdownButtonFormFieldState<T>();
}

class _DropdownButtonFormFieldState<T> extends FormFieldState<T> {
  @override
  void didChange(T? value) {
    super.didChange(value);
    final CustomDropFormField<T> dropdownButtonFormField =
    widget as CustomDropFormField<T>;
    assert(dropdownButtonFormField.onChanged != null);
    dropdownButtonFormField.onChanged!(value);
  }

  @override
  void didUpdateWidget(CustomDropFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}