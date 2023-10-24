import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ustad_mech/app/screens/draggable/view/draggable_grid.dart';

class GalleryItemWidget extends StatefulWidget {
  const GalleryItemWidget({
    required this.child,
    required this.index,
    super.key,
    this.curve = Curves.easeIn,
  });
  final int index;
  final Widget child;
  final Curve curve;

  @override
  State<GalleryItemWidget> createState() => GalleryItemWidgetState();
}

class GalleryItemWidgetState extends State<GalleryItemWidget>
    with GalleryItemDragDelegate {
  AnimationController? _controller;

  ValueKey<int> get key => ValueKey<int>(widget.index);
  @override
  int get index => widget.index;
  @override
  Curve get curve => widget.curve;

  @override
  AnimationController? get animation => _controller;

  @override
  set animation(AnimationController? value) => _controller = value;

  bool get isTransitionCompleted =>
      _controller == null || _controller!.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();

    gridState = GridGallery.of(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GalleryItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.index != widget.index) {
      gridState
        ..unregisterItem(oldWidget.index, this)
        ..registerItem(this);
    }
  }

  @override
  void deactivate() {
    gridState.unregisterItem(index, this);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject()! as RenderBox;

      size = box.size;
    });

    gridState.registerItem(this);

    if (isDragging) {
      return const SizedBox();
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width < 600
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.3,
      child: GalleryItemDragStartListener(
        index: index,
        child: Transform.translate(
          offset: offset,
          child: Material(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {},
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryItemDragStartListener extends StatelessWidget {
  const GalleryItemDragStartListener({
    required this.index,
    required this.child,
    super.key,
    this.enabled = true,
  });
  final int index;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled ? (event) => _startDragging(context, event) : null,
      child: child,
    );
  }

  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final gestureSetting = MediaQuery.maybeOf(context)?.gestureSettings;

    final grid = GridGallery.mayOf(context);

    grid?.startItemDragging(
      index: index,
      event: event,
      recognizer: createRecognizer()..gestureSettings = gestureSetting,
    );
  }
}

mixin GalleryItemDragDelegate<T extends StatefulWidget> on State<T> {
  late GridGalleryState gridState;
  bool isDragging = false;

  Size? size;
  Offset startOffset = Offset.zero;
  Offset targetOffset = Offset.zero;

  int get index;
  Curve get curve;
  AnimationController? get animation;
  set animation(AnimationController? value);

  bool get isTransitionEnd => animation == null;

  Offset get offset {
    if (animation != null) {
      final t = curve.transform(animation!.value);

      return Offset.lerp(startOffset, targetOffset, t)!;
    }
    return targetOffset;
  }

  /// return the original [RenderBox]'s top-left
  /// the effective geometry should be (itemPosition - targetOffset) & size!
  Rect get geometry {
    final box = context.findRenderObject()! as RenderBox;
    final itemPosition = box.localToGlobal(Offset.zero);

    size = box.size;

    return itemPosition & size!;
  }

  Rect get translatedGeometry {
    return geometry.translate(targetOffset.dx, targetOffset.dy);
  }

  void apply({
    required int moving,
    required Size gapSize,
    bool playAnimation = true,
  }) {
    translateTo(moving: moving, gapSize: gapSize);

    if (playAnimation) {
      animate();
    } else {
      jump();
    }
    rebuild();
  }

  void translateTo({required int moving, required Size gapSize}) {
    if (index == moving) {
      targetOffset = Offset.zero;
      return;
    }

    final original = gridState.calculateItemCoordinate(index);
    final target = gridState.calculateItemCoordinate(moving);

    final mainAxis = gridState.widget.scrollDirection;

    var verticalSpacing = 0;
    var horizontalSpacing = 0;

    switch (mainAxis) {
      case Axis.vertical:
        verticalSpacing = gridState.widget.mainAxisSpacing.toInt();
        horizontalSpacing = gridState.widget.crossAxisSpacing.toInt();
      case Axis.horizontal:
        verticalSpacing = gridState.widget.crossAxisSpacing.toInt();
        horizontalSpacing = gridState.widget.mainAxisSpacing.toInt();
    }

    targetOffset = (target - original).scale(
      gapSize.width + horizontalSpacing,
      gapSize.height + verticalSpacing,
    );
  }

  void animate() {
    if (animation == null) {
      animation = AnimationController(
        vsync: gridState,
        duration: const Duration(
          milliseconds: 100,
        ),
      )
        ..addListener(rebuild)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            startOffset = targetOffset;
            animation?.dispose();
            animation = null;
            rebuild();
          }
        })
        ..forward();
    } else {
      startOffset = offset;
      animation?.forward(from: 0);
    }
  }

  void jump() {
    animation?.dispose();
    animation = null;
    startOffset = targetOffset;
    // rebuild();
  }

  void rebuild() {
    setState(() {});
  }

  void reset() {
    animation?.dispose();
    animation = null;
    startOffset = Offset.zero;
    targetOffset = Offset.zero;
    isDragging = false;
    rebuild();
  }
}
