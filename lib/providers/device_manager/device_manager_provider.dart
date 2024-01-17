
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/library_item_model.dart';

import 'types.dart';

final selectedLibraryItemSP = StateProvider<LibraryItemModel?>((ref) => null);

final videoPreviewEventSP = StateProvider<VideoPreviewEvent?>((ref) => null);

final currentTimeLineItemSP = StateProvider<TimelineItem?>((ref) => null);
