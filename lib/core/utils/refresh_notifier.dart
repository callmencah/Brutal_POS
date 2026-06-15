import 'package:flutter/foundation.dart';

/// Global notifier to trigger refreshes across different screens.
/// For example, after a successful payment, we can increment this
/// notifier to force the HomeScreen to reload recent transactions.
final ValueNotifier<int> globalRefreshNotifier = ValueNotifier<int>(0);

void triggerGlobalRefresh() {
  globalRefreshNotifier.value++;
}
