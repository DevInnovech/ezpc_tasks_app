import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Importar kIsWeb
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
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  InternetStatusNotifier() : super(const InternetStatusInitial()) {
    // Si la plataforma es web, omitir la verificación de conectividad
    if (kIsWeb) {
      state = const InternetStatusBackState('Web platform: Assuming connected');
    } else {
      // Verificación inicial de la conectividad
      _initializeConnectivity();

      // Escuchar cambios en la conectividad
      _subscription = _connectivity.onConnectivityChanged.listen((result) {
        _updateConnectivityState(result as ConnectivityResult);
      });
    }
  }

  Future<void> _initializeConnectivity() async {
    if (!kIsWeb) {
      try {
        final result = await _connectivity.checkConnectivity();
        _updateConnectivityState(result as ConnectivityResult);
      } catch (e) {
        state = const InternetStatusLostState('Failed to check connectivity');
      }
    }
  }

  void _updateConnectivityState(ConnectivityResult result) {
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      state = const InternetStatusBackState('Your internet was restored');
    } else {
      state = const InternetStatusLostState('No internet connection');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
