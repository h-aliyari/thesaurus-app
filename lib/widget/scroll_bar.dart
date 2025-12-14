import 'package:flutter/material.dart';

class DesktopScrollbar extends StatefulWidget {
  final ScrollController controller;
  final double scrollAmount;
  final bool leftSide;

  const DesktopScrollbar({
    super.key,
    required this.controller,
    this.scrollAmount = 100,
    this.leftSide = false,
  });

  @override
  State<DesktopScrollbar> createState() => _DesktopScrollbarState();
}

class _DesktopScrollbarState extends State<DesktopScrollbar> {
  double _thumbTop = 0;
  double _thumbHeight = 50;

  void _scrollUp() {
    final offset = (widget.controller.offset - widget.scrollAmount)
        .clamp(0.0, widget.controller.position.maxScrollExtent);
    widget.controller.animateTo(offset,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _scrollDown() {
    final offset = (widget.controller.offset + widget.scrollAmount)
        .clamp(0.0, widget.controller.position.maxScrollExtent);
    widget.controller.animateTo(offset,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  void _updateThumb() {
    if (!widget.controller.hasClients) return;
    final maxScroll = widget.controller.position.maxScrollExtent;
    final viewport = widget.controller.position.viewportDimension;
    final trackHeight = context.size?.height ?? 100;

    const triangleHeight = 24.0;
    final availableHeight = trackHeight - 2 * triangleHeight;

    final thumbHeight =
        (viewport / (viewport + maxScroll) * availableHeight).clamp(50.0, availableHeight);
    final thumbTop = (widget.controller.offset / (maxScroll == 0 ? 1 : maxScroll)) *
            (availableHeight - thumbHeight) +
        triangleHeight;

    setState(() {
      _thumbHeight = thumbHeight;
      _thumbTop = thumbTop;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateThumb);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateThumb);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final side = widget.leftSide ? 0.0 : null;
      final oppositeSide = widget.leftSide ? null : 0.0;

      return SizedBox(
        width: 30,
        child: Stack(
          children: [
            // Thumb
            Positioned(
              top: _thumbTop,
              left: side != null ? side + 10.5 : null,
              right: oppositeSide != null ? oppositeSide + 10.5 : null,
              child: Container(
                width: 7,
                height: _thumbHeight,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 101, 107, 111),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            // مثلث بالا ثابت
            Positioned(
              top: 0,
              left: side,
              right: oppositeSide,
              child: GestureDetector(
                onTap: _scrollUp,
                child: const Icon(Icons.arrow_drop_up, size: 28),
              ),
            ),
            // مثلث پایین ثابت
            Positioned(
              bottom: 0,
              left: side,
              right: oppositeSide,
              child: GestureDetector(
                onTap: _scrollDown,
                child: const Icon(Icons.arrow_drop_down, size: 28),
              ),
            ),
          ],
        ),
      );
    });
  }
}