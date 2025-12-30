import 'dart:async';

class SessionManager {
  // A "Radio Station" (Stream) that broadcasts when the session dies
  static final StreamController<void> _expirationController =
      StreamController<void>.broadcast();

  // Listen to this stream
  static Stream<void> get onTokenExpired => _expirationController.stream;

  // Call this function when we detect a 401
  static void expireSession() {
    _expirationController.add(null);
  }
}
