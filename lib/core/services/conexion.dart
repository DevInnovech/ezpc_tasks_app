import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class InternetStatusState {
  const InternetStatusState();
}

class InternetStatusInitial extends InternetStatusState {
  const InternetStatusInitial();
}

class InternetStatusBackState extends InternetStatusState {
  final String message;

  const InternetStatusBackState(this.message);
}

class InternetStatusLostState extends InternetStatusState {
  final String message;

  const InternetStatusLostState(this.message);
}

final internetStatusProvider =
    StateNotifierProvider<InternetStatusNotifier, InternetStatusState>(
  (ref) => InternetStatusNotifier(),
);

class InternetStatusNotifier extends StateNotifier<InternetStatusState> {
  InternetStatusNotifier() : super(const InternetStatusInitial()) {
    _assumeInternetConnectivity();
  }

  void _assumeInternetConnectivity() {
    // Asume que siempre hay conexión
    state = const InternetStatusBackState(
        'Internet connection is assumed to be available');
  }
}
