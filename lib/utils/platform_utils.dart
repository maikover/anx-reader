import 'dart:io';

import 'package:flutter/foundation.dart';

enum AnxPlatformEnum { android, ios, macos, windows, ohos, linux }

class AnxPlatform {
  static AnxPlatformEnum? _cachedType;

  static AnxPlatformEnum get type {
    if (_cachedType != null) return _cachedType!;

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        return _cachedType = AnxPlatformEnum.android;
      }
      if (Platform.isIOS) {
        return _cachedType = AnxPlatformEnum.ios;
      }
      if (Platform.isMacOS) {
        return _cachedType = AnxPlatformEnum.macos;
      }
      if (Platform.isWindows) {
        return _cachedType = AnxPlatformEnum.windows;
      }
      try {
        if (Platform.operatingSystem == 'ohos') {
          return _cachedType = AnxPlatformEnum.ohos;
        }
      } catch (_) {}
      if (Platform.isLinux) {
        return _cachedType = AnxPlatformEnum.linux;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static bool get isAndroid {
    try {
      return type == AnxPlatformEnum.android;
    } catch (_) {
      return false;
    }
  }

  static bool get isIOS {
    try {
      return type == AnxPlatformEnum.ios;
    } catch (_) {
      return false;
    }
  }

  static bool get isMacOS {
    try {
      return type == AnxPlatformEnum.macos;
    } catch (_) {
      return false;
    }
  }

  static bool get isWindows {
    try {
      return type == AnxPlatformEnum.windows;
    } catch (_) {
      return false;
    }
  }

  static bool get isOhos {
    try {
      return type == AnxPlatformEnum.ohos;
    } catch (_) {
      return false;
    }
  }

  static bool get isLinux {
    try {
      return type == AnxPlatformEnum.linux;
    } catch (_) {
      return false;
    }
  }

  static bool get isMobile => isAndroid || isIOS || isOhos;

  static bool get isDesktop => isWindows || isMacOS || isLinux;
}