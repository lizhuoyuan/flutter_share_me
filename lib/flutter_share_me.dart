import 'package:flutter/services.dart';

import 'file_type.dart';

//export file type enum
export 'package:flutter_share_me/file_type.dart';

class FlutterShareMe {
  const FlutterShareMe();

  static const MethodChannel _channel = MethodChannel('flutter_share_me');

  static const String _methodWhatsApp = 'whatsapp_share';
  static const String _methodWhatsAppPersonal = 'whatsapp_personal';
  static const String _methodWhatsAppBusiness = 'whatsapp_business_share';
  static const String _methodFaceBook = 'facebook_share';
  static const String _methodMessenger = 'messenger_share';
  static const String _methodInstagramShare = 'instagram_share';
  static const String _methodSystemShare = 'system_share';
  static const String _methodTelegramShare = 'telegram_share';
  static const String _methodTikTokShare = 'tiktok_share';
  static const String _methodCheckAppAvailable = 'check_app_available';

  ///share to WhatsApp
  /// [imagePath] is local image
  /// [phoneNumber] enter phone number with counry code
  /// For ios
  /// If include image then text params will be ingored as there is no current way in IOS share both at the same.
  Future<String?> shareToWhatsApp(
      {String msg = '',
      String imagePath = '',
      FileType? fileType = FileType.image}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => imagePath);
    if (fileType == FileType.image) {
      arguments.putIfAbsent('fileType', () => 'image');
    } else {
      arguments.putIfAbsent('fileType', () => 'video');
    }

    String? result;
    try {
      result = await _channel.invokeMethod<String>(_methodWhatsApp, arguments);
    } catch (e) {
      return e.toString();
    }

    return result;
  }

  ///share to WhatsApp
  /// [phoneNumber] phone number with counry code
  /// [msg] message text you want on whatsapp
  Future<String?> shareWhatsAppPersonalMessage(
      {required String message, required String phoneNumber}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => message);
    arguments.putIfAbsent('phoneNumber', () => phoneNumber);

    String? result;
    try {
      result = await _channel.invokeMethod<String>(
          _methodWhatsAppPersonal, arguments);
    } catch (e) {
      return e.toString();
    }

    return result;
  }

  ///share to Telegram
  /// [msg] message text you want on telegram
  Future<String?> shareToTelegram({required String msg}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    String? result;
    try {
      result =
          await _channel.invokeMethod<String>(_methodTelegramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to WhatsApp4Biz
  ///[imagePath] is local image
  /// For ios
  /// If include image then text params will be ingored as there is no current way in IOS share both at the same.
  Future<String?> shareToWhatsApp4Biz(
      {String msg = '', String? imagePath = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};

    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => imagePath);
    String? result;
    try {
      result = await _channel.invokeMethod<String>(
          _methodWhatsAppBusiness, arguments);
    } catch (e) {
      return 'false';
    }

    return result;
  }

  ///share to facebook
  Future<String?> shareToFacebook(
      {required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result = await _channel.invokeMethod<String?>(_methodFaceBook, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share to messenger
  Future<String?> shareToMessenger(
      {required String msg, String url = ''}) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('msg', () => msg);
    arguments.putIfAbsent('url', () => url);
    String? result;
    try {
      result =
          await _channel.invokeMethod<String?>(_methodMessenger, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///use system share ui
  Future<String?> shareToSystem({required String msg}) async {
    String? result;
    try {
      result =
          await _channel.invokeMethod<String>(_methodSystemShare, {'msg': msg});
    } catch (e) {
      return 'false';
    }
    return result;
  }

  ///share file to instagram
  Future<String?> shareToInstagram({
    required String filePath,
    FileType fileType = FileType.image,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{};
    arguments.putIfAbsent('url', () => filePath);
    if (fileType == FileType.image) {
      arguments.putIfAbsent('fileType', () => 'image');
    } else {
      arguments.putIfAbsent('fileType', () => 'video');
    }
    String? result;

    try {
      result =
          await _channel.invokeMethod<String>(_methodInstagramShare, arguments);
    } catch (e) {
      return e.toString();
    }
    return result;
  }

  ///share file to tiktok
  Future<String?> shareToTikTok({
    required String filePath,
    FileType fileType = FileType.image,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'url': filePath,
      'fileType': fileType == FileType.image ? 'image' : 'video',
    };

    try {
      return await _channel.invokeMethod<String>(
        _methodTikTokShare,
        arguments,
      );
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> checkAppAvailable(AppValue app) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'app': app.name,
    };

    return (await _channel.invokeMethod<bool>(
          _methodCheckAppAvailable,
          arguments,
        )) ??
        false;
  }
}

enum AppValue {
  tiktok,
  instagram,
  facebookMessenger,
  whatsapp,
  sms,
}

extension AppValueExtension on AppValue {
  String get name {
    switch (this) {
      case AppValue.tiktok:
        return 'tiktok';

      case AppValue.instagram:
        return 'instagram';

      case AppValue.facebookMessenger:
        return 'facebookMessenger';

      case AppValue.whatsapp:
        return 'whatsapp';

      case AppValue.sms:
        return 'sms';
    }
  }
}
