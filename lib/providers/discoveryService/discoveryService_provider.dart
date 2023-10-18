import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/models/nsd_model.dart';

final discoveryServiceStatusSP = StateProvider.autoDispose((ref) => NetworkDiscoveryServerStatus.offline);

