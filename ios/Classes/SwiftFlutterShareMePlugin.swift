import Flutter
import UIKit
import Foundation
import Photos
import PhotosUI
import FBSDKShareKit
import TikTokOpenSDKCore
import TikTokOpenShareSDK

public class SwiftFlutterShareMePlugin: NSObject, FlutterPlugin, SharingDelegate {
    
    
    let _methodWhatsApp = "whatsapp_share";
    let _methodWhatsAppPersonal = "whatsapp_personal";
    let _methodWhatsAppBusiness = "whatsapp_business_share";
    let _methodFaceBook = "facebook_share";
    let _methodTwitter = "twitter_share";
    let _methodInstagram = "instagram_share";
    let _methodSystemShare = "system_share";
    let _methodTelegramShare = "telegram_share";
    let _methodTikTokShare = "tiktok_share";

    var result: FlutterResult?
    var documentInteractionController: UIDocumentInteractionController?
    var onPickFileCompletionHandler: ((String?) -> Void)? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_share_me", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterShareMePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        if(call.method.elementsEqual(_methodWhatsApp)){
            let args = call.arguments as? Dictionary<String,Any>
            
            if args!["url"] as! String == "" {
                // if don't pass url then pass blank so if can strat normal whatsapp
                shareWhatsApp(message: args!["msg"] as! String,imageUrl: "",type: args!["fileType"] as! String,result: result)
            }else{
                // if user pass url then use that
                shareWhatsApp(message: args!["msg"] as! String,imageUrl: args!["url"] as! String,type: args!["fileType"] as! String,result: result)
            }
            
        }
        else if(call.method.elementsEqual(_methodWhatsAppBusiness)){
            
            // There is no way to open WB in IOS.
            result(FlutterMethodNotImplemented)
            
            //            let args = call.arguments as? Dictionary<String,Any>
            //
            //            if args!["url"]as! String == "" {
            //                // if don't pass url then pass blank so if can strat normal whatsapp
            //                shareWhatsApp4Biz(message: args!["msg"] as! String, result: result)
            //            }else{
            //                // if user pass url then use that
            //                // wil open share sheet and user can select open for there.
            //                //                shareWhatsApp(message: args!["msg"] as! String,imageUrl: args!["url"] as! String,result: result)
            //            }
        }
        else if(call.method.elementsEqual(_methodWhatsAppPersonal)){
            let args = call.arguments as? Dictionary<String,Any>
            shareWhatsAppPersonal(message: args!["msg"]as! String, phoneNumber: args!["phoneNumber"]as! String, result: result)
        }
        else if(call.method.elementsEqual(_methodFaceBook)){
            let args = call.arguments as? Dictionary<String,Any>
            sharefacebook(message: args!, result: result)

        }else if(call.method.elementsEqual(_methodTwitter)){
            let args = call.arguments as? Dictionary<String,Any>
            shareTwitter(message: args!["msg"] as! String, url: args!["url"] as! String, result: result)
        }
        else if(call.method.elementsEqual(_methodInstagram)){
            let args = call.arguments as? Dictionary<String,Any>
            shareInstagram(args: args!, result: result)
        }
        else if(call.method.elementsEqual(_methodTelegramShare)){
            let args = call.arguments as? Dictionary<String,Any>
            shareToTelegram(message: args!["msg"] as! String, result: result )
        }
        else if(call.method.elementsEqual(_methodTikTokShare)){
            let args = call.arguments as! Dictionary<String,Any>
            shareToTikTok(args: args, result: result)
        }
        else{
            let args = call.arguments as? Dictionary<String,Any>
            systemShare(message: args!["msg"] as! String,result: result)
        }
    }


    func shareWhatsApp(message:String, imageUrl:String,type:String,result: @escaping FlutterResult)  {
        // @ For ios
        // we can't set both if you pass image then text will ignore
        var whatsURL = ""
        if(imageUrl==""){
            whatsURL = "whatsapp://send?text=\(message)"
        }else{
            whatsURL = "whatsapp://app"
        }
        
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            if(imageUrl==""){
                //mean user did not pass image url  so just got with text message
                result("Sucess");
                UIApplication.shared.openURL(whatsAppURL! as URL)
                
            }
            else{
                //this is whats app work around so will open system share and exclude other share types
                let viewController = UIApplication.shared.delegate?.window??.rootViewController
                let urlData:Data
                let filePath:URL
                if(type=="image"){
                    let image = UIImage(named: imageUrl)
                    if(image==nil){
                        result("File format not supported Please check the file.")
                        return;
                    }
                    //urlData=UIImageJPEGRepresentation(image!, 1.0)!
                    urlData = image!.jpegData(compressionQuality: 1.0)!
                    filePath=URL(fileURLWithPath:NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                }else{
                    filePath=URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("video.m4v")
                    urlData = NSData(contentsOf: URL(fileURLWithPath: imageUrl))! as Data
                }
                
                let tempFile = filePath
                do{
                    try urlData.write(to: tempFile, options: .atomic)
                    // image to be share
                    let imageToShare = [tempFile]
                    
                    let activityVC = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
                    // we want to exlude most of the things so developer can see whatsapp only on system share sheet
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.message, UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.postToWeibo,UIActivity.ActivityType.print,UIActivity.ActivityType.openInIBooks,UIActivity.ActivityType.postToFlickr,UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.postToFacebook]
                    
                    viewController!.present(activityVC, animated: true, completion: nil)
                    result("Sucess");
                    
                }catch{
                    print(error)
                }
            }
            
        }
        else
        {
            result(FlutterError(code: "Not found", message: "WhatsApp is not found", details: "WhatsApp not intalled or Check url scheme."));
        }
    }
    
    
    // Send whatsapp personal message
    // @ message
    // @ phone with contry code.
    func shareWhatsAppPersonal(message:String, phoneNumber:String,result: @escaping FlutterResult)  {
        
        let whatsURL = "whatsapp://send?phone=\(phoneNumber)&text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let whatsAppURL  = NSURL(string: whatsURL.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            UIApplication.shared.openURL(whatsAppURL! as URL)
            result("Sucess");
        }else{
            result(FlutterError(code: "Not found", message: "WhatsApp is not found", details: "WhatsApp not intalled or Check url scheme."));
        }
    }
    
    func shareWhatsApp4Biz(message:String, result: @escaping FlutterResult)  {
        let whatsApp = "https://wa.me/?text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        
        let whatsAppURL  = NSURL(string: whatsApp.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(whatsAppURL! as URL)
        {
            result("Sucess");
            UIApplication.shared.openURL(whatsAppURL! as URL)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "WhatsAppBusiness is not found", details: "WhatsAppBusiness not intalled or Check url scheme."));
        }
    }
    // share twitter
    // params
    // @ map conting meesage and url
    
    func sharefacebook(message:Dictionary<String,Any>, result: @escaping FlutterResult)  {
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        //let shareDialog = ShareDialog()
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: message["url"] as! String)!
        shareContent.quote = message["msg"] as? String
        
        let shareDialog = ShareDialog(viewController: viewController, content: shareContent, delegate: self)
        shareDialog.mode = .automatic
        shareDialog.show()
        result("Sucess")
        
    }
    
    // share twitter params
    // @ message
    // @ url
    func shareTwitter(message:String,url:String, result: @escaping FlutterResult)  {
        let urlstring = url
        let twitterUrl =  "twitter://post?message=\(message)"
        
        let urlTextEscaped = urlstring.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        let url = URL(string: urlTextEscaped ?? "")
        
        let urlWithLink = twitterUrl + url!.absoluteString
        
        let escapedShareString = urlWithLink.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        // cast to an url
        let urlschme = URL(string: escapedShareString)
        // open in safari
        do {
            if UIApplication.shared.canOpenURL(urlschme! as URL){
                UIApplication.shared.openURL(urlschme!)
                result("Sucess")
            }else{
                result(FlutterError(code: "Not found", message: "Twitter is not found", details: "Twitter not intalled or Check url scheme."));
                
            }
        }
        
    }
    //share via telegram
    //@ text that you want to share.
    func shareToTelegram(message: String,result: @escaping FlutterResult )
    {
        let telegram = "tg://msg?text=\(message)"
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "?&")
        let telegramURL  = NSURL(string: telegram.addingPercentEncoding(withAllowedCharacters: characterSet)!)
        if UIApplication.shared.canOpenURL(telegramURL! as URL)
        {
            result("Sucess");
            UIApplication.shared.openURL(telegramURL! as URL)
        }
        else
        {
            result(FlutterError(code: "Not found", message: "telegram is not found", details: "telegram not intalled or Check url scheme."));
        }
    
    }
    
    private func requestAddFileToPhotoLibraryPermission(_ completionHandler: @escaping (PHAuthorizationStatus) -> Void ) {
        if #available(iOS 14.0, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if [PHAuthorizationStatus.authorized, PHAuthorizationStatus.limited].contains(status) {
                completionHandler(status)
                return
            }

            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                completionHandler(newStatus)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { newStatus in
                completionHandler(newStatus)
            }
        }
    }

    private func addFileToPhotoLibrary(to filePath: String,
                                       fileType: String,
                                       completionHandler: @escaping (String?) -> Void) {
        guard let fileData = try? Data(contentsOf:  URL(fileURLWithPath: filePath)) as NSData else {
            print("error getting file data")
            completionHandler(nil)
            return
        }

        PHPhotoLibrary.shared().performChanges {
            if fileType == "image" {
                PHAssetChangeRequest.creationRequestForAssetFromImage(
                    atFileURL: URL(fileURLWithPath: filePath)
                )
            } else {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(
                    atFileURL: URL(fileURLWithPath: filePath)
                )
            }
        } completionHandler: { success, error in
            if let error {
                print("error saving file to PHPhotoLibrary \(error.localizedDescription)")
            }
            
            if success {
                if #available(iOS 14, *),
                   PHPhotoLibrary.authorizationStatus(for: .readWrite) == PHAuthorizationStatus.limited {
                    self.displayPHPhotoPicker { fileIdentifier in
                        completionHandler(fileIdentifier)
                    }
                    return
                }

                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
                let fetchResult = PHAsset.fetchAssets(
                    with: fileType == "image" ? .image : .video,
                    options: fetchOptions
                )

                if let assetToShare = fetchResult.firstObject {
                    completionHandler(assetToShare.localIdentifier)
                    return
                } else {
                    print("error querying file asset")
                }
            }

            completionHandler(nil)
        }
    }

    // share image/video via TikTok.
    func shareToTikTok(args: Dictionary<String,Any>, result: @escaping FlutterResult)  {
        let redirectUrl = ""
        let file = args["url"] as! String
        let fileType = args["fileType"] as! String

        self.requestAddFileToPhotoLibraryPermission { newStatus in
            print("The new status is \(newStatus.rawValue)")
            
            if #available(iOS 14, *) {
                if ![PHAuthorizationStatus.authorized, PHAuthorizationStatus.limited].contains(newStatus) {
                    result("permission not granted")
                    return
                }
            } else {
                if newStatus != .authorized {
                    result("permission not granted")
                    return
                }
            }
            
            self.addFileToPhotoLibrary(to: file, fileType: fileType) { destinationIdentifier in
                guard let destinationIdentifier else {
                    result("failed to save file to library")
                    return
                }

                let shareRequest = TikTokShareRequest(
                    localIdentifiers: [destinationIdentifier],
                    mediaType: fileType == "image" ? .image : .video,
                    redirectURI: redirectUrl
                )
                shareRequest.shareFormat = .normal

                DispatchQueue.main.async {
                    shareRequest.send() { response in
                        guard let shareResponse = response as? TikTokShareResponse else {
                            print("Tiktok no response")
                            return
                        }

                        if shareResponse.errorCode == .noError {
                            print("Success")
                        } else {
                            print("Share Failed! Error Code: \(shareResponse.errorCode.rawValue) " +
                                  "Error Message: \(shareResponse.errorDescription ?? "") " +
                                  "Share State: \(shareResponse.shareState)")
                        }
                    }
                }
                result("Success")
            }
        }
    }

    //share via system native dialog
    //@ text that you want to share.
    func systemShare(message:String,result: @escaping FlutterResult)  {
        // find the root view controller
        let viewController = UIApplication.shared.delegate?.window??.rootViewController

        // set up activity view controller
        // Here is the message for for sharing
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        /// if want to exlude anything then will add it for future support.
        //        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popup = activityVC.popoverPresentationController {
                popup.sourceView = viewController?.view
                popup.sourceRect = CGRect(x: (viewController?.view.frame.size.width)! / 2, y: (viewController?.view.frame.size.height)! / 4, width: 0, height: 0)
            }
        }
        viewController!.present(activityVC, animated: true, completion: nil)
        result("Sucess");
        
        
    }
    
    // share image via instagram stories.
    // @ args image url
    func shareInstagram(args: Dictionary<String,Any>, result: @escaping FlutterResult)  {
        let file = args["url"] as! String
        let fileType = args["fileType"] as! String
        
        guard let instagramURL = NSURL(string: "instagram://app") else {
            result("Instagram app is not installed on your device")
            return
        }
        
        self.requestAddFileToPhotoLibraryPermission { newStatus in
            print("The new status is \(newStatus.rawValue)")

            if #available(iOS 14, *) {
                if ![PHAuthorizationStatus.authorized, PHAuthorizationStatus.limited].contains(newStatus) {
                    result("permission not granted")
                    return
                }
            } else {
                if newStatus != .authorized {
                    result("permission not granted")
                    return
                }
            }

            self.addFileToPhotoLibrary(to: file, fileType: fileType) { destinationIdentifier in
                guard let destinationIdentifier else {
                    result("failed to save file to library")
                    return
                }

                let instaShareUrl = "instagram://library?LocalIdentifier=\(destinationIdentifier)"

                // Share file
                if UIApplication.shared.canOpenURL(instagramURL as URL) {
                    if let urlForRedirect = NSURL(string: instaShareUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(urlForRedirect as URL, options: [:], completionHandler: nil)
                        } else{
                            UIApplication.shared.openURL(urlForRedirect as URL)
                        }
                    }
                    result("Success")
                } else {
                    result("Instagram app is not installed on your device")
                }
            }
        }
    }

    //Facebook delegate methods
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print("Share: Success")

    }

    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Share: Fail")

    }

    public func sharerDidCancel(_ sharer: Sharing) {
        print("Share: Cancel")
    }
}

// - MARK: PHPickerViewControllerDelegate
@available(iOS 14, *)
extension SwiftFlutterShareMePlugin: PHPickerViewControllerDelegate {
    private func displayPHPhotoPicker(completionHandler: ((String?) -> Void)?) {
        self.onPickFileCompletionHandler = completionHandler
        DispatchQueue.main.async {
            self.triggerPicker()
        }
    }

    @IBAction private func triggerPicker() {
        let photoLibrary = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 1
        configuration.preferredAssetRepresentationMode = .compatible

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true)
    }

    public func picker(_ picker: PHPickerViewController,
                       didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                         ascending: false)]
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: fetchOptions)
        guard let localId = fetchResult.firstObject else {
            print("no asset selected")
            self.onPickFileCompletionHandler?(nil)
            return
        }

        self.onPickFileCompletionHandler?(localId.localIdentifier)
    }
}
