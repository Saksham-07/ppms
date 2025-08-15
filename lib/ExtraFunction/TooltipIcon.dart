import 'package:flutter/material.dart';

class TooltipIcon extends StatefulWidget {
  final String tooltipText;

  const TooltipIcon({Key? key, required this.tooltipText}) : super(key: key);

  @override
  _TooltipIconState createState() => _TooltipIconState();
}

class _TooltipIconState extends State<TooltipIcon> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(BuildContext context) {
    _hideTooltip(); // Hide existing tooltip if any

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    double tooltipWidth = 200; // Set your tooltip width
    double tooltipHeight = 50; // Set your tooltip height
    double padding = 10; // Safe padding from edges

    double left = offset.dx - (tooltipWidth / 2);
    double top = offset.dy - tooltipHeight - 10; // Position above the icon

    // Ensure the tooltip stays within the screen bounds
    if (left < padding) {
      left = padding; // Prevent going off left
    } else if (left + tooltipWidth > screenSize.width - padding) {
      left = screenSize.width - tooltipWidth - padding; // Prevent going off right
    }

    if (top < padding) {
      top = offset.dy + 40; // Move below the icon if not enough space above
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap anywhere to dismiss
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _hideTooltip,
            ),
          ),
          // Tooltip Box
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: tooltipWidth,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.tooltipText,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTooltip(context),
      child: const Icon(
        Icons.info_outline,
        color: Colors.black,
        size: 22,
      ),
    );
  }
}
