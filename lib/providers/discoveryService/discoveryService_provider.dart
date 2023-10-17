import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_trip/services/network_discovery_server/network_discovery_server.dart';

final discoveryServiceStatusSP = StateProvider.autoDispose((ref) => NetworkDiscoveryServerStatus.offline);

