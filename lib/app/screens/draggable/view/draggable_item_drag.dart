import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:ustad_mech/app/screens/draggable/view/draggable_grid.dart';
import 'package:ustad_mech/app/screens/draggable/view/draggable_item_widget.dart';

typedef GalleryItemDragUpdate = void Function(GalleryItemDrag, Offset, Offset);
typedef GalleryItemDragCallback = void Function(GalleryItemDrag);

Offset _overlayOrigin(BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class GalleryItemDrag extends Drag {
  GalleryItemDrag({
    required GalleryItemWidgetState item,
    Offset initialPosition = Offset.zero,
    this.onDragUpdate,
    this.onDragCancel,
    this.onDragEnd,
  }) {
    final itemBox = item.context.findRenderObject()! as RenderBox;

    gridState = item.gridState;
    index = item.index;
    child = item.widget.child;
    dragPosition = initialPosition;
    dragOffset = itemBox.globalToLocal(initialPosition);
    itemSize = itemBox.size;
  }
  late GridGalleryState gridState;
  late int index;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;

  final GalleryItemDragUpdate? onDragUpdate;
  final GalleryItemDragCallback? onDragEnd;
  final GalleryItemDragCallback? onDragCancel;

  @override
  void update(DragUpdateDetails details) {
    final delta = details.delta;

    dragPosition += delta;
    onDragUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    onDragEnd?.call(this);
  }

  @override
  void cancel() {
    onDragCancel?.call(this);
  }

  /// get the top-left position of the dragging item
  Offset overlayPosition(BuildContext context) {
    return dragPosition - dragOffset - _overlayOrigin(context);
  }

  Widget buildOverlay(BuildContext context) {
    return DraggingItemOverlay(
      gridState: gridState,
      index: index,
      position: overlayPosition(context),
      size: itemSize,
      child: child,
    );
  }
}

class DraggingItemOverlay extends StatelessWidget {
  const DraggingItemOverlay({
    required this.gridState,
    required this.child,
    required this.index,
    required this.position,
    required this.size,
    super.key,
  });
  final GridGalleryState gridState;
  final int index;
  final Widget child;
  final Offset position;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox.fromSize(
              size: size,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
