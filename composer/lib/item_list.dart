import 'package:constrained_layout/constrained_layout.dart';
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  final List<ConstrainedItem> items;
  final void Function(ConstrainedItem) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 360,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) => ItemListCard(
          item: items[index],
          onClick: () => onRemove(items[index]),
        ),
      ),
    );
  }
}

class ItemListCard extends StatelessWidget {
  const ItemListCard({
    super.key,
    required this.item,
    required this.onClick,
  });

  final ConstrainedItem item;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text('${item.id}'),
          ),
        ),
      ),
    );
  }
}
