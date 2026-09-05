import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:coders_adda_app/main.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isFirstCheck = true;
  bool _wasOffline = false;

  bool get isOffline => _wasOffline;

  void initialize() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // connectivity_plus 7.x returns a List of ConnectivityResult
    bool isOffline = results.isEmpty || results.every((result) => result == ConnectivityResult.none);

    if (_isFirstCheck) {
      _isFirstCheck = false;
      _wasOffline = isOffline;
      if (isOffline) {
        showOfflineModal();
      }
      return;
    }

    if (isOffline && !_wasOffline) {
      _wasOffline = true;
      showOfflineModal();
    } else if (!isOffline && _wasOffline) {
      _wasOffline = false;
      _showToast("Welcome back to online", Colors.green);
    }
  }

  void showOfflineModal() {
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("You are offline"),
            content: const Text("Please turn on data to go online. You can still access downloaded content and your profile."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Continue Offline"),
              ),
            ],
          );
        },
      );
    }
  }

  void _showToast(String message, Color color) {
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void dispose() {
    _connectivitySubscription.cancel();
  }
}
