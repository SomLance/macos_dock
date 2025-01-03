import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: DockOld(),
        ),
      ),
    );
  }
}

class DockOld extends StatelessWidget {
  const DockOld({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Dock(
          items: const [
            Icons.person,
            Icons.message,
            Icons.call,
            Icons.camera,
            Icons.photo,
            Icons.home,
            Icons.file_copy,
            Icons.upload,
          ],
          builder: (e) {
            return Container(
              constraints: const BoxConstraints(minWidth: 48),
              height: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.primaries[e.hashCode % Colors.primaries.length],
              ),
              child: Center(child: Icon(e, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// My variables
  dynamic lastHoveredIndex = -1;
  dynamic hoveredIndex = -1;
  dynamic hoveredIndexLeftOne = -1;
  dynamic hoveredIndexLeftTwo = -1;
  dynamic hoveredIndexRightOne = -1;
  dynamic hoveredIndexRightTwo = -1;
  dynamic draggedItem;
  dynamic draggedIndex = -1;
  dynamic pickIndex = -1;

  /// mouse moving in direction
  String mouseDirection = '';
  double currentXPosition = 0;
  double previousXPosition = 0;

  ///
  bool mouseOnDock = false;

  /// for horizontal movement -- new additon
  double mouseOffsetX = 0;

  /// My Functions
  /// Calculating zoom
  double calculateZoom(index) {
    if (hoveredIndex == index) {
      return 1.40;
    } else if (hoveredIndexLeftOne == index || hoveredIndexRightOne == index) {
      return 1.25;
    } else if (hoveredIndexLeftTwo == index || hoveredIndexRightTwo == index) {
      return 1.10;
    }

    return 1.0;
  }

  /// Calculate icon spacing
  double calculateIconSpacingLeft(index) {
    if (hoveredIndex == index) {
      return 7;
    } else if (hoveredIndexLeftOne == index || hoveredIndexRightOne == index || hoveredIndexLeftTwo == index || hoveredIndexRightTwo == index) {
      return 3;
    }
    return 0;
  }

  /// Calculate icon spacing
  double calculateIconSpacingRight(index) {
    if (hoveredIndex == index) {
      return 7;
    } else if (hoveredIndexLeftOne == index || hoveredIndexRightOne == index || hoveredIndexLeftTwo == index || hoveredIndexRightTwo == index) {
      return 3;
    }
    return 0;
  }

  /// Calculating lift
  double calculateLift(index) {
    if (hoveredIndex == index) {
      return 11;
    } else if (hoveredIndexLeftOne == index || hoveredIndexRightOne == index) {
      return 7;
    } else if (hoveredIndexLeftTwo == index || hoveredIndexRightTwo == index) {
      return 3;
    }

    return 0;
  }

  /// Calculate Dock Zoom
  double calculateDockWidth() {
    if (hoveredIndex > -1 || mouseOnDock) {
      return 550;
    }
    return 515;
  }

  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// build
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MouseRegion(
            onEnter: (PointerEnterEvent event) {},
            onExit: (PointerExitEvent event) {
              setState(() {
                mouseOnDock = false;
              });
            },
            child: SizedBox(
              height: 100,
              width: calculateDockWidth() + 5,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 50),
                      width: calculateDockWidth(),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black12,
                      ),
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: SizedBox(
                      width: calculateDockWidth(),
                      child: Center(
                        child: DragTarget(
                          onWillAcceptWithDetails: (data) => true,
                          onAcceptWithDetails: (details) {
                            final droppedItem = details.data;

                            setState(() {
                              ///
                              if (draggedItem != null && !_items.contains(draggedItem)) {
                                final index = _items.indexOf(draggedItem!);
                                _items.insert(index, draggedItem!);
                                draggedItem = null;
                              }

                              ///
                              if (!_items.contains(droppedItem)) {
                                _items.add(droppedItem as T);
                              }
                            });
                          },
                          builder: (BuildContext context, List candidateData, List<dynamic> rejectedData) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_items.length, (index) {
                                final builtWidget = widget.builder(_items[index]);

                                /// Applying drag functionality
                                /// while dragging the element is removed from the list
                                /// so that it disappears from the list
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onHover: (PointerHoverEvent event) {
                                    setState(() {
                                      mouseOffsetX = event.localPosition.dx;
                                    });
                                  },
                                  onEnter: (PointerEnterEvent event) {
                                    setState(() {
                                      mouseOnDock = true;
                                      hoveredIndex = index;
                                      hoveredIndexLeftOne = index - 1;
                                      hoveredIndexLeftTwo = index - 2;
                                      hoveredIndexRightOne = index + 1;
                                      hoveredIndexRightTwo = index + 2;
                                    });
                                  },
                                  onExit: (PointerExitEvent event) {
                                    setState(() {
                                      lastHoveredIndex = hoveredIndex;
                                      hoveredIndex = -1;
                                      hoveredIndexLeftOne = -1;
                                      hoveredIndexLeftTwo = -1;
                                      hoveredIndexRightOne = -1;
                                      hoveredIndexRightTwo = -1;
                                    });
                                  },
                                  child: AnimatedPadding(
                                    curve: Curves.decelerate,
                                    padding: EdgeInsets.only(
                                      bottom: calculateLift(index),
                                    ),
                                    duration: const Duration(milliseconds: 200),
                                    child: AnimatedScale(
                                      curve: Curves.decelerate,
                                      scale: calculateZoom(index),
                                      duration: const Duration(milliseconds: 200),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          calculateIconSpacingLeft(index),
                                          0,
                                          calculateIconSpacingRight(index),
                                          0,
                                        ),
                                        child: Draggable(
                                          key: ValueKey(_items[index]),
                                          feedback: builtWidget,
                                          onDragStarted: () {
                                            setState(() {
                                              draggedItem = _items[index];
                                              draggedIndex = index;
                                              pickIndex = index;
                                            });
                                          },
                                          onDragEnd: (details) {
                                            setState(() {
                                              if (draggedItem != null) {
                                                /// getting the mouse position on x axis
                                                double xPosition = details.offset.dx;

                                                /// updating previous position
                                                previousXPosition = currentXPosition;
                                                currentXPosition = xPosition;
                                                if (previousXPosition != currentXPosition) {}

                                                _items.removeAt(draggedIndex);
                                                int droppedIndex = hoveredIndex > -1 ? hoveredIndex : pickIndex;
                                                if (xPosition > 500) {
                                                  _items.insert(_items.length, draggedItem!);
                                                } else if (xPosition < 30) {
                                                  _items.insert(0, draggedItem!);
                                                } else {
                                                  _items.insert(droppedIndex, draggedItem!);
                                                }

                                                // clear
                                                draggedItem = null;
                                                draggedIndex = -1;
                                              }
                                            });
                                          },
                                          child: draggedIndex == index
                                              ? SizedBox()
                                              : Transform.translate(
                                                  offset: Offset(-mouseOffsetX / 15, 0),
                                                  child: builtWidget,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
