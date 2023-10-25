import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ustad_mech/app/screens/draggable/view/draggable_item_drag.dart';

import 'package:ustad_mech/app/screens/draggable/view/draggable_item_widget.dart';

typedef GalleryItemBuilder = Widget Function();

class GridGallery extends StatefulWidget {
  const GridGallery({
    required this.galleries,
    required this.crossAxisCount, super.key,
    this.scrollDirection = Axis.vertical,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 5.0,
    this.mainAxisSpacing = 5.0,
    this.maxCount,
    this.curve = Curves.easeIn,
    this.addGallery,
  });
  final int crossAxisCount;
  final List<Widget> galleries;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final int? maxCount;
  final Axis scrollDirection;
  final Curve curve;
  final GalleryItemBuilder? addGallery;

  @override
  State<GridGallery> createState() => GridGalleryState();

  static GridGalleryState of(BuildContext context) {
    final state = context.findAncestorStateOfType<GridGalleryState>();

    return state!;
  }

  static GridGalleryState? mayOf(BuildContext context) {
    final state = context.findAncestorStateOfType<GridGalleryState>();
    return state!;
  }
}

class GridGalleryState extends State<GridGallery>
    with TickerProviderStateMixin, GalleryGridDragDelegate {
  final Map<int, GalleryItemWidgetState> _items = {};

  @override
  Map<int, GalleryItemWidgetState> get items => _items;

  @override
  List<Widget> get galleries => widget.galleries;

  bool get canAddGallery =>
      widget.addGallery != null &&
      (widget.maxCount == null || galleries.length < widget.maxCount!);

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      itemCount: widget.galleries.length,
      crossAxisCount:widget.crossAxisCount,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
      itemBuilder: (context, index) {
        return GalleryItemWidget(
          key: ValueKey(index),
          index: index,
          curve: widget.curve,
          child: widget.galleries[index],
        );
      },

      // children: [
      //   for (int i = 0; i < widget.galleries.length; i++)
      //     GalleryItemWidget(
      //       key: ValueKey(i),
      //       index: i,
      //       curve: widget.curve,
      //       child: widget.galleries[i],
      //     ),
      //   if (canAddGallery) widget.addGallery!.call(),
      // ],
    );
  }

  void registerItem(GalleryItemWidgetState item) {
    _items[item.index] = item;

    if (item.index == _drag?.index) {
      item
        ..isDragging = true
        ..rebuild();
    }
  }

  void unregisterItem(int index, GalleryItemWidgetState item) {
    final current = _items[index];

    if (current == item) {
      _items.remove(index);
    }
  }

  Offset calculateItemCoordinate(int itemIndex) {
    final vertical = (itemIndex ~/ widget.crossAxisCount).toDouble();
    final horizontal = (itemIndex % widget.crossAxisCount).toDouble();

    switch (widget.scrollDirection) {
      case Axis.vertical:
        return Offset(horizontal, vertical);
      case Axis.horizontal:
        return Offset(vertical, horizontal);
    }
  }

  void startItemDragging({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    _cleanDragIfNecessary(event);

    if (_items.containsKey(index)) {
      _dragIndex = index;
      _recognizer = recognizer
        ..onStart = _startDrag
        ..addPointer(event);
    } else {
      throw Exception(
        'Attempting to start a drag on a non-visible item: $index',
      );
    }
  }
}

mixin GalleryGridDragDelegate<T extends StatefulWidget>
    on State<T>, TickerProvider {
  Map<int, GalleryItemWidgetState> get items;
  List<Widget> get galleries;
  MultiDragGestureRecognizer? _recognizer;
  OverlayEntry? _draggingOverlay;
  GalleryItemDrag? _drag;
  int? _dragIndex;
  int? _targetIndex;
  Drag? _startDrag(Offset position) {
    final item = items[_dragIndex];

    item!.isDragging = true;
    item.rebuild();

    _targetIndex = item.index;

    _drag = GalleryItemDrag(
      item: item,
      initialPosition: position,
      onDragCancel: _onDragCancel,
      onDragEnd: _onDragEnd,
      onDragUpdate: _onDragUpdate,
    );

    _draggingOverlay = OverlayEntry(builder: _drag!.buildOverlay);
    Overlay.of(context).insert(_draggingOverlay!);

    return _drag;
  }

  void _onDragUpdate(GalleryItemDrag drag, Offset position, Offset delta) {
    _draggingOverlay?.markNeedsBuild();
    _translateItems(delta);
    setState(() {});
  }

  void _onDragEnd(GalleryItemDrag drag) {
    _onDragCompleted();
  }

  void _onDragCancel(GalleryItemDrag drag) {
    _resetDrag();
  }

  void _onDragCompleted() {
    final fromIndex = _dragIndex!;
    final toIndex = _targetIndex!;

    final gallery = galleries.removeAt(fromIndex);

    galleries.insert(toIndex, gallery);

    _resetDrag();
  }

  void _cleanDragIfNecessary(PointerDownEvent event) {
    if (_drag != null) {
      _resetDrag();
    } else if (_recognizer != null) {
      _recognizer?.dispose();
      _recognizer = null;
    }
  }

  void _resetDrag() {
    if (_drag != null) {
      if (_dragIndex != null && items.containsKey(_dragIndex)) {
        final item = items[_dragIndex];
        item!.rebuild();
        _dragIndex = null;
      }

      _drag = null;
      _recognizer?.dispose();
      _resetItemTranslation();
      _recognizer = null;
      _draggingOverlay?.remove();
      _draggingOverlay = null;
      _targetIndex = null;
    }

    setState(() {});
  }

  void _translateItems(Offset delta) {
    final gapSize = _drag!.itemSize;
    final pointer = _drag!.overlayPosition(context);
    final dragPosition = pointer + _drag!.itemSize.center(Offset.zero);

    var newTargetIndex = _targetIndex!;

    for (final item in items.values) {
      if (!item.mounted || !item.isTransitionCompleted) continue;

      final geometry = Rect.fromCenter(
        center: item.geometry.center,
        width: item.size!.width * 0.5,
        height: item.size!.height * 0.5,
      );

      if (geometry.contains(dragPosition)) {
        newTargetIndex = item.index;
        break;
      }
    }

    if (newTargetIndex != _targetIndex) {
      final forward = _dragIndex! < newTargetIndex;
      _targetIndex = newTargetIndex;

      for (final item in items.values) {
        if (item.index == _dragIndex!) {
          item.apply(moving: _targetIndex!, gapSize: gapSize);
          continue;
        }

        if (forward) {
          if (item.index > _dragIndex! && item.index <= _targetIndex!) {
            item.apply(moving: item.index - 1, gapSize: gapSize);
          } else {
            item.apply(moving: item.index, gapSize: gapSize);
          }
        } else {
          if (item.index >= _targetIndex! && item.index < _dragIndex!) {
            item.apply(moving: item.index + 1, gapSize: gapSize);
          } else {
            item.apply(moving: item.index, gapSize: gapSize);
          }
        }
      }
    }
  }

  void _resetItemTranslation() {
    for (final item in items.values) {
      item.reset();
    }
  }
}
