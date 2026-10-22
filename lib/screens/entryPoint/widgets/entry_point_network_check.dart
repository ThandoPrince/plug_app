import 'package:connectivity_plus/connectivity_plus.dart';

/// True if the device has *some* network path (wifi or mobile data).
/// This does NOT confirm the network actually reaches the internet or
/// that our backend is reachable — it only rules out "no radio/interface
/// at all", which is the one thing worth reporting to the user as a
/// distinct, actionable state ("turn on mobile data / wifi") rather than
/// a generic server error.
Future<bool> hasNetworkConnection() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}