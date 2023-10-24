import 'package:flutter/material.dart';
import 'package:ustad_mech/app/screens/draggable/view/draggable_grid.dart';

final List<Widget> items = [
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Maths'),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Item $index',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
        },
      ),
    ],
  ),
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('English'),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Item $index',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
        },
      ),
    ],
  ),
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Urdu'),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Item $index',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
        },
      ),
    ],
  ),
  Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Islamiat'),
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.circle,
                size: 8,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'Item $index',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
        },
      ),
    ],
  ),
];

class GridGalleryExample extends StatefulWidget {
  const GridGalleryExample({super.key});

  @override
  State<GridGalleryExample> createState() => _GridGalleryExampleState();
}

class _GridGalleryExampleState extends State<GridGalleryExample> {
  final List<Widget> galleries = List.generate(
    4,
    (index) => items[index],
  );
  List<double> columnHeights = [0, 0, 0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Grid Items'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: GridGallery(
            galleries: galleries,
          ),
        ),
      ),
    );
  }
}
