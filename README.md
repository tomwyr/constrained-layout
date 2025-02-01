# ConstrainedLayout

A flexible Flutter layout allowing to position widgets by declaring relations between them.

Try out the package in an [interactive playground app](https://tomwyr.github.io/constrained-layout/).

https://github.com/user-attachments/assets/eb47462c-1a3b-4990-9197-03fac519e707

## Usage

Add `ConstrainedLayout` to the widget tree:

```dart
ConstrainedLayout(
  items: [
    // Use LinkToParent to position item at the parent's edges.
    ConstrainedItem(
      id: 'red',
      bottom: LinkToParent(),
      right: LinkToParent(),
      child: Square(Colors.red),
    ),
    // Use LinkTo to position item in relation to the target item.
    ConstrainedItem(
      id: 'green',
      bottom: LinkTo(id: 'red', edge: Edge.top),
      right: LinkTo(id: 'red', edge: Edge.left),
      child: Square(Colors.green),
    ),
    // Linking both horizontal or vertical edges will center item between target edges.
    ConstrainedItem(
      id: 'blue',
      top: LinkToParent(),
      bottom: LinkTo(id: 'green', edge: Edge.top),
      left: LinkToParent(),
      right: LinkTo(id: 'green', edge: Edge.left),
      child: Square(Colors.blue),
    ),
    // Items can be linked to different targets to position them in the desired way.
    ConstrainedItem(
      id: 'orange',
      top: LinkTo(id: 'blue', edge: Edge.bottom),
      bottom: LinkTo(id: 'green', edge: Edge.top),
      left: LinkToParent(),
      right: LinkTo(id: 'red', edge: Edge.right),
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

The widget will use defined relations to determine the layout positions and sizes of its children:

<img width="539" alt="example" src="https://github.com/user-attachments/assets/22978362-9844-46cf-8df1-9c3585693a65">
