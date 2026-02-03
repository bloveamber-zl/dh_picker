import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'picker.dart';

///@author Evan
///@since 2020/12/31
///@describe:

typedef NumIndexFormatter = String Function(num value);

class NumberPicker extends StatefulWidget {
  final double diameterRatio;
  final Color? backgroundColor;
  final double offAxisFraction;
  final bool useMagnifier;
  final double magnification;
  final FixedExtentScrollController? scrollController;
  final double itemExtent;
  final double squeeze;
  final ValueChanged<num>? onSelectedItemChanged;
  final Widget? selectionOverlay;
  final bool looping;
  final TextStyle? textStyle;
  // 选中项文字样式
  final TextStyle? selectedTextStyle;
  // 非选中项文字样式
  final TextStyle? unselectedTextStyle;
  final num max;
  final num min;
  final num interval;
  final NumIndexFormatter? indexFormat;
  final Widget? label;
  final EdgeInsetsGeometry? labelPadding;
  final AlignmentGeometry labelAlignment;

  NumberPicker({
    Key? key,
    this.diameterRatio = kDefaultDiameterRatio,
    this.backgroundColor,
    this.offAxisFraction = 0.0,
    this.useMagnifier = false,
    this.magnification = 1.0,
    this.scrollController,
    this.squeeze = kSqueeze,
    this.selectionOverlay = const DefaultSelectionOverlay(),
    this.looping = false,
    required this.itemExtent,
    required this.onSelectedItemChanged,
    required this.max,
    required this.min,
    required this.interval,
    this.indexFormat,
    this.textStyle,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.label,
    this.labelPadding,
    this.labelAlignment = Alignment.center,
  })  : assert(min != null),
        assert(max != null),
        assert(min <= max),
        assert(diameterRatio != null),
        assert(diameterRatio > 0.0,
            RenderListWheelViewport.diameterRatioZeroMessage),
        assert(magnification > 0),
        assert(itemExtent != null),
        assert(itemExtent > 0),
        assert(squeeze != null),
        assert(squeeze > 0),
        super(key: key);

  @override
  _NumberPickerState createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  FixedExtentScrollController? _internalController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.scrollController == null) {
      _internalController = FixedExtentScrollController();
    }
    // 初始化选中索引，优先从controller获取，否则默认为0
    final controller = widget.scrollController ?? _internalController;
    if (controller != null && controller.hasClients) {
      _selectedIndex = controller.selectedItem;
    } else {
      _selectedIndex = 0;
    }
    // 在widget构建完成后，确保从controller获取正确的初始选中索引
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = widget.scrollController ?? _internalController;
      if (ctrl != null && ctrl.hasClients) {
        final newIndex = ctrl.selectedItem;
        if (newIndex != _selectedIndex) {
          setState(() {
            _selectedIndex = newIndex;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _handleSelectedItemChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onSelectedItemChanged?.call(widget.min + index * widget.interval);
  }

  @override
  Widget build(BuildContext context) {
    int count = (widget.max - widget.min) ~/ widget.interval + 1;
    Function format = widget.indexFormat ?? (val) => "$val";

    // 基础样式：优先使用未选中样式，否则使用通用样式
    final TextStyle? baseTextStyle =
        widget.unselectedTextStyle ?? widget.textStyle;
    // 选中样式：优先使用选中样式，否则使用基础样式
    final TextStyle? selectedStyle = widget.selectedTextStyle ?? baseTextStyle;

    return DHPicker.builder(
      key: widget.key,
      diameterRatio: widget.diameterRatio,
      backgroundColor: widget.backgroundColor,
      offAxisFraction: widget.offAxisFraction,
      useMagnifier: widget.useMagnifier,
      magnification: widget.magnification,
      scrollController: widget.scrollController ?? _internalController,
      squeeze: widget.squeeze,
      selectionOverlay: widget.selectionOverlay,
      label: widget.label,
      labelPadding: widget.labelPadding,
      labelAlignment: widget.labelAlignment,
      onSelectedItemChanged: _handleSelectedItemChanged,
      itemExtent: widget.itemExtent,
      childCount: count,
      itemBuilder: (BuildContext context, int index) {
        // 判断当前项是否为选中项
        final bool isSelected = index == _selectedIndex;
        // 根据是否选中应用不同的样式
        final TextStyle? itemStyle = isSelected ? selectedStyle : baseTextStyle;

        return Align(
          alignment: widget.labelAlignment,
          child: Text(
            format(widget.min + widget.interval * index),
            style: itemStyle,
          ),
        );
      },
    );
  }
}
