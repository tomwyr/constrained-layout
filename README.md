# ConstrainedLayout

A flexible Flutter layout allowing to position widgets by declaring relations between them.

## Usage

```dart
ConstrainedLayout(
  items: [
    // Use AttachToParent to position item at the parent's edges.
    ConstrainedItem(
      id: 'red',
      bottom: AttachToParent(),
      right: AttachToParent(),
      child: Square(Colors.red),
    ),
    // Use AttachTo to position item in relation to the target item.
    ConstrainedItem(
      id: 'green',
      bottom: AttachTo(id: 'red', edge: Edge.top),
      right: AttachTo(id: 'red', edge: Edge.left),
      child: Square(Colors.green),
    ),
    // Attaching both horizontal or vertical edges will center item between target edges.
    ConstrainedItem(
      id: 'blue',
      top: AttachToParent(),
      bottom: AttachTo(id: 'green', edge: Edge.top),
      left: AttachToParent(),
      right: AttachTo(id: 'green', edge: Edge.left),
      child: Square(Colors.blue),
    ),
    // Items can be attached to different targets to position them in the desired way.
    ConstrainedItem(
      id: 'orange',
      top: AttachTo(id: 'blue', edge: Edge.bottom),
      bottom: AttachTo(id: 'green', edge: Edge.top),
      left: AttachToParent(),
      right: AttachTo(id: 'red', edge: Edge.right),
      child: Square(Colors.orange),
    ),
    // Unconstrained items are aligned to the top left corner of the parent.
    ConstrainedItem(
      id: 'yellow',
      child: Square(Colors.yellow),
    ),
  ],
)
```
