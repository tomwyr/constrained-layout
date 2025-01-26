import 'model/drag_model.dart';
import 'model/hover_tracker.dart';
import 'model/item_resolver.dart';
import 'model/items_history.dart';
import 'model/items_model.dart';
import 'model/layout_utils.dart';

final layoutUtils = LayoutUtils();
final itemsHistory = ItemsHistory();
final hoverTracker = HoverTracker();
final itemsModel = ItemsModel(itemsHistory: itemsHistory);
final dragModel = DragModel(itemsModel: itemsModel, hoverTracker: hoverTracker);
final itemResolver = ItemResolver(
  dragModel: dragModel,
  itemsModel: itemsModel,
  hoverTracker: hoverTracker,
);
