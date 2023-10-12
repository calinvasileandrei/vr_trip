import 'package:hooks_riverpod/hooks_riverpod.dart';

final vrPlayerClientProvider =
    StateProvider.family<String?, String>((ref, deviceIp) {
  return '';
});
