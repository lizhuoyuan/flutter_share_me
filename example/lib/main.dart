import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:image_picker/image_picker.dart';

///sharing platform
enum Share {
  facebook,
  messenger,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? file;
  ImagePicker picker = ImagePicker();
  bool videoEnable = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              ElevatedButton(onPressed: pickImage, child: Text('Pick Image')),
              ElevatedButton(onPressed: pickVideo, child: Text('Pick Video')),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.whatsapp),
                child: const Text('share to WhatsApp'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.whatsapp_business),
                child: const Text('share to WhatsApp Business'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.whatsapp_personal),
                child: const Text('share to WhatsApp Personal'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.facebook),
                child: const Text('share to  FaceBook'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.messenger),
                child: const Text('share to  Messenger'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.share_instagram),
                child: const Text('share to Instagram'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.share_telegram),
                child: const Text('share to Telegram'),
              ),
              ElevatedButton(
                onPressed: () => onButtonTap(Share.share_system),
                child: const Text('share to System'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
    print(xFile);
    if (xFile != null) {
      file = File(xFile.path);
      setState(() {
        videoEnable = false;
      });
    }
  }

  Future<void> pickVideo() async {
    final XFile? xFile = await picker.pickVideo(source: ImageSource.gallery);
    print(xFile);
    if (xFile != null) {
      file = File(xFile.path);
      setState(() {
        videoEnable = true;
      });
    }
  }

  Future<void> onButtonTap(Share share) async {
    String msg =
        'Flutter share is great!!\n Check out full example at https://pub.dev/packages/flutter_share_me';
    String url = 'https://pub.dev/packages/flutter_share_me';

    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      case Share.messenger:
        response = await flutterShareMe.shareToMessenger(url: url, msg: msg);
        break;
      case Share.whatsapp:
        if (file != null) {
          response = await flutterShareMe.shareToWhatsApp(
              imagePath: file!.path,
              fileType: videoEnable ? FileType.video : FileType.image);
        } else {
          response = await flutterShareMe.shareToWhatsApp(msg: msg);
        }
        break;
      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: msg);
        break;
      case Share.whatsapp_personal:
        response = await flutterShareMe.shareWhatsAppPersonalMessage(
            message: msg, phoneNumber: 'phone-number-with-country-code');
        break;
      case Share.share_instagram:
        response = await flutterShareMe.shareToInstagram(
            filePath: file!.path,
            fileType: videoEnable ? FileType.video : FileType.image);
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
    }
    debugPrint(response);
  }
}
