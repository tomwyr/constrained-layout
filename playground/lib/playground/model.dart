import 'model/drag_state.dart';
import 'model/hover_tracker.dart';
import 'model/items_actions.dart';
import 'model/items_factory.dart';
import 'model/items_history.dart';
import 'model/items_resolver.dart';
import 'model/layout_utils.dart';

final layoutUtils = LayoutUtils();
final hoverTracker = HoverTracker();
final itemsHistory = ItemsHistory();
final itemsFactory = ItemsFactory();
final itemsActions = ItemsActions(
  itemsHistory: itemsHistory,
  itemsFactory: itemsFactory,
);
final itemResolver = ItemsResolver(
  dragState: dragState,
  itemsHistory: itemsHistory,
  itemsActions: itemsActions,
  hoverTracker: hoverTracker,
);
final dragState = DragState(
  itemsActions: itemsActions,
);
