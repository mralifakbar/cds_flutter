import 'package:flutter/widgets.dart';

import 'sample_data.dart';

/// Shared state for the sample wallet: the forced data state and the refresh
/// epoch that reshuffles sample prices.
class SampleWalletState extends ChangeNotifier {
  SampleDataState dataState = SampleDataState.live;
  int epoch = 0;
  bool priceAlerts = true;
  bool hideBalances = false;
  String currency = 'USD';

  void setDataState(SampleDataState s) {
    dataState = s;
    notifyListeners();
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    epoch++;
    notifyListeners();
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }
}

class SampleWalletScope extends InheritedNotifier<SampleWalletState> {
  const SampleWalletScope({super.key, required SampleWalletState state, required super.child}) : super(notifier: state);

  static SampleWalletState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SampleWalletScope>()!.notifier!;
}
