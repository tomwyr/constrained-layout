import 'dart:js_interop';

bool get isFullScreenSupported {
  return true;
}

@JS()
external bool isFullScreen();

@JS()
external void setFullScreen(bool enabled);
