package zhuoyuan.li.fluttershareme;


import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.content.pm.ResolveInfo;
import android.os.Parcelable;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.widget.MessageDialog;
import com.facebook.share.widget.ShareDialog;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterShareMePlugin
 */
public class FlutterShareMePlugin implements MethodCallHandler, FlutterPlugin, ActivityAware {

    final private static String _methodWhatsApp = "whatsapp_share";
    final private static String _methodWhatsAppPersonal = "whatsapp_personal";
    final private static String _methodWhatsAppBusiness = "whatsapp_business_share";
    
    final private static String _methodFaceBook = "facebook_share";
    final private static String _methodMessenger = "messenger_share";
    
    final private static String _methodTwitter = "twitter_share";
    
    final private static String _methodSystemShare = "system_share";
    
    final private static String _methodInstagramShare = "instagram_share";
    final private static String _methodInstagramShareText = "instagram_share_text";
    
    final private static String _methodTelegramShare = "telegram_share";


    private Activity activity;
    private static CallbackManager callbackManager;
    private MethodChannel methodChannel;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final FlutterShareMePlugin instance = new FlutterShareMePlugin();
        instance.onAttachedToEngine(registrar.messenger());
        instance.activity = registrar.activity();
    }

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        activity = null;
    }

    private void onAttachedToEngine(BinaryMessenger messenger) {
        methodChannel = new MethodChannel(messenger, "flutter_share_me");
        methodChannel.setMethodCallHandler(this);
        callbackManager = CallbackManager.Factory.create();
    }

    /**
     * method
     *
     * @param call   methodCall
     * @param result Result
     */
    @Override
    public void onMethodCall(MethodCall call, @NonNull Result result) {
        String url, msg, fileType;
        switch (call.method) {
            case _methodFaceBook:
                url = call.argument("url");
                msg = call.argument("msg");
                shareToFacebook(url, msg, result);
                break;
            case _methodMessenger:
                msg = call.argument("msg");
                shareToMessenger( msg, result);
                break;
            case _methodTwitter:
                msg = call.argument("msg");
                shareToTwitter(msg, result);
                break;
            case _methodWhatsApp:
                msg = call.argument("msg");
                url = call.argument("url");
                shareWhatsApp(url, msg, result, false);
                break;
            case _methodWhatsAppBusiness:
                msg = call.argument("msg");
                url = call.argument("url");
                shareWhatsApp(url, msg, result, true);
                break;
            case _methodWhatsAppPersonal:
                msg = call.argument("msg");
                String phoneNumber = call.argument("phoneNumber");
                shareWhatsAppPersonal(msg, phoneNumber, result);
                break;
            case _methodSystemShare:
                msg = call.argument("msg");
                shareSystem(result, msg);
                break;
            case _methodInstagramShare:
                msg = call.argument("url");
                fileType = call.argument("fileType");
                shareInstagramStory(msg, fileType, result);
                break;
            case _methodInstagramShareText:
                msg = call.argument("msg");
                shareInstagramText(msg,  result);
                break;
            case _methodTelegramShare:
                msg = call.argument("msg");
                shareToTelegram(msg, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * system share
     *
     * @param msg    String
     * @param result Result
     */
    private void shareSystem(Result result, String msg) {
        try {
            Intent textIntent = new Intent("android.intent.action.SEND");
            textIntent.setType("text/plain");
            textIntent.putExtra("android.intent.extra.TEXT", msg);
            activity.startActivity(Intent.createChooser(textIntent, "Share to"));
            result.success("success");
        } catch (Exception var7) {
            result.error("error", var7.toString(), "");
        }
    }

    /**
     * share to twitter
     *
     * @param msg    String
     * @param result Result
     */
    private void shareToTwitter(String msg,  Result result) {
        if (twitterInstalled()) {
            List<Intent> targetedShareIntents = new ArrayList<Intent>();

            Intent textIntent = new Intent(Intent.ACTION_SEND);
            textIntent.setType("text/plain");
            textIntent.putExtra(Intent.EXTRA_TEXT, msg);

            List<ResolveInfo> resInfo = activity.getPackageManager().queryIntentActivities(textIntent, 0);

            for (ResolveInfo resolveInfo : resInfo) {
                String packageName = resolveInfo.activityInfo.packageName;

                Intent targetedShareIntent = new Intent(android.content.Intent.ACTION_SEND);
                targetedShareIntent.setType("text/plain");
                targetedShareIntent.putExtra(Intent.EXTRA_TEXT, msg);
                targetedShareIntent.setPackage(packageName);

                if (packageName.equals("com.twitter.android")) { // Add only instagram
                    targetedShareIntents.add(targetedShareIntent);
                }
            }

            Intent chooserIntent = Intent.createChooser(
                    targetedShareIntents.remove(0), "Select how to share");

            chooserIntent.putExtra(
                    Intent.EXTRA_INITIAL_INTENTS, targetedShareIntents.toArray(new Parcelable[]{}));

            try {
                activity.startActivity(chooserIntent);
                result.success("Success");
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
                result.success("Failure");
            }

        } else {
            result.error("Twitter not found", "Twitter is not installed on device.", "");
        }
    }

    /**
     * share to Facebook
     *
     * @param url    String
     * @param msg    String
     * @param result Result
     */
    private void shareToFacebook(String url, String msg, Result result) {

        ShareDialog shareDialog = new ShareDialog(activity);
        // this part is optional
        shareDialog.registerCallback(callbackManager, new FacebookCallback<Sharer.Result>() {
            @Override
            public void onSuccess(Sharer.Result result) {
                System.out.println("--------------------success");
            }

            @Override
            public void onCancel() {
                System.out.println("-----------------onCancel");
            }

            @Override
            public void onError(FacebookException error) {
                System.out.println("---------------onError");
            }
        });

        ShareLinkContent content = new ShareLinkContent.Builder()
                .setContentUrl(Uri.parse(url))
                .setQuote(msg)
                .build();
        if (ShareDialog.canShow(ShareLinkContent.class)) {
            shareDialog.show(content);
            result.success("success");
        }

    }

    /**
     * share to Messenger
     *
     * @param msg    String
     * @param result Result
     */
    private void shareToMessenger(String msg,  Result result) {
        if (messengerInstalled()) {
            List<Intent> targetedShareIntents = new ArrayList<Intent>();

            Intent textIntent = new Intent(Intent.ACTION_SEND);
            textIntent.setType("text/plain");
            textIntent.putExtra(Intent.EXTRA_TEXT, msg);

            List<ResolveInfo> resInfo = activity.getPackageManager().queryIntentActivities(textIntent, 0);

            for (ResolveInfo resolveInfo : resInfo) {
                String packageName = resolveInfo.activityInfo.packageName;

                Intent targetedShareIntent = new Intent(android.content.Intent.ACTION_SEND);
                targetedShareIntent.setType("text/plain");
                targetedShareIntent.putExtra(Intent.EXTRA_TEXT, msg);
                targetedShareIntent.setPackage(packageName);

                if (packageName.equals("com.facebook.orca")) { // Add only instagram
                    targetedShareIntents.add(targetedShareIntent);
                }
            }

            Intent chooserIntent = Intent.createChooser(
                    targetedShareIntents.remove(0), "Select how to share");

            chooserIntent.putExtra(
                    Intent.EXTRA_INITIAL_INTENTS, targetedShareIntents.toArray(new Parcelable[]{}));

            try {
                activity.startActivity(chooserIntent);
                result.success("Success");
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
                result.success("Failure");
            }

        } else {
            result.error("Messenger not found", "Messenger is not installed on device.", "");
        }
    }
    /**
     * share to whatsapp
     *
     * @param msg                String
     * @param result             Result
     * @param shareToWhatsAppBiz boolean
     */
    private void shareWhatsApp(String imagePath, String msg, Result result, boolean shareToWhatsAppBiz) {
        try {
            Intent whatsappIntent = new Intent(Intent.ACTION_SEND);
            
            whatsappIntent.setPackage(shareToWhatsAppBiz ? "com.whatsapp.w4b" : "com.whatsapp");
            whatsappIntent.putExtra(Intent.EXTRA_TEXT, msg);
            // if the url is the not empty then get url of the file and share
            if (!TextUtils.isEmpty(imagePath)) {
                whatsappIntent.setType("*/*");
                System.out.print(imagePath+"url is not empty");
                File file = new File(imagePath);
                Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file);
                whatsappIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                whatsappIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
                whatsappIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            }
            else {
                whatsappIntent.setType("text/plain");
            }
            activity.startActivity(whatsappIntent);
            result.success("success");
        } catch (Exception var9) {
            result.error("error", var9.toString(), "");
        }
    }
      /**
     * share to telegram
     *
     * @param msg                String
     * @param result             Result
     */
    
    private void shareToTelegram(String msg, Result result) {
        try {
            Intent telegramIntent = new Intent(Intent.ACTION_SEND);
            telegramIntent.setType("text/plain");
            telegramIntent.setPackage("org.telegram.messenger");
            telegramIntent.putExtra(Intent.EXTRA_TEXT, msg);
            try {
                activity.startActivity(telegramIntent);
                result.success("true");
            } catch (Exception ex) {
                result.success("false:Telegram app is not installed on your device");
            }
        } catch (Exception var9) {
            result.error("error", var9.toString(), "");
        }
    }
    /**
     * share whatsapp message to personal number
     *
     * @param msg         String
     * @param phoneNumber String with country code
     * @param result
     */
    private void shareWhatsAppPersonal(String msg, String phoneNumber, Result result) {
        String url = null;
        try {
            url = "https://api.whatsapp.com/send?phone=" + phoneNumber + "&text=" + URLEncoder.encode(msg, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setPackage("com.whatsapp");
        i.setData(Uri.parse(url));
        activity.startActivity(i);
        result.success("success");
    }

    /**
     * share to instagram
     *
     * @param url      local file path
     * @param fileType type of file to share (image or video)
     * @param result   flutterResult
     */
    private void shareInstagramStory(String url, String fileType, Result result) {
        if (instagramInstalled()) {
            File file = new File(url);
            Uri fileUri = FileProvider.getUriForFile(activity, activity.getApplicationContext().getPackageName() + ".provider", file);

            Intent instagramIntent = new Intent(Intent.ACTION_SEND);
            if(fileType.equals("image"))
                instagramIntent.setType("image/*");
            else if(fileType.equals("video"))
                instagramIntent.setType("video/*");
            instagramIntent.putExtra(Intent.EXTRA_STREAM, fileUri);
            instagramIntent.setPackage("com.instagram.android");
            try {
                activity.startActivity(instagramIntent);
                result.success("Success");
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
                result.success("Failure");
            }
        } else {
            result.error("Instagram not found", "Instagram is not installed on device.", "");
        }
    }

    private void shareInstagramText(String msg,  Result result) {
        if (instagramInstalled()) {
            List<Intent> targetedShareIntents = new ArrayList<Intent>();

            Intent textIntent = new Intent(Intent.ACTION_SEND);
            textIntent.setType("text/plain");
            textIntent.putExtra(Intent.EXTRA_TEXT, msg);

            List<ResolveInfo> resInfo = activity.getPackageManager().queryIntentActivities(textIntent, 0);

            for (ResolveInfo resolveInfo : resInfo) {
                String packageName = resolveInfo.activityInfo.packageName;

                Intent targetedShareIntent = new Intent(android.content.Intent.ACTION_SEND);
                targetedShareIntent.setType("text/plain");
                targetedShareIntent.putExtra(Intent.EXTRA_TEXT, msg);
                targetedShareIntent.setPackage(packageName);

                if (packageName.equals("com.instagram.android")) { // Add only instagram
                    targetedShareIntents.add(targetedShareIntent);
                }
            }

            //Intent i = new Intent(this);
            //targetedShareIntents.add(i);

            Intent chooserIntent = Intent.createChooser(
                    targetedShareIntents.remove(0), "Select how to share");

            chooserIntent.putExtra(
                    Intent.EXTRA_INITIAL_INTENTS, targetedShareIntents.toArray(new Parcelable[]{}));

            try {
                activity.startActivity(chooserIntent);
                result.success("Success");
            } catch (ActivityNotFoundException e) {
                e.printStackTrace();
                result.success("Failure");
            }



        } else {
            result.error("Instagram not found", "Instagram is not installed on device.", "");
        }
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {

    }

    ///Utils methods
    private boolean instagramInstalled() {
        try {
            if (activity != null) {
                activity.getPackageManager()
                        .getApplicationInfo("com.instagram.android", 0);
                return true;
            } else {
                Log.d("App", "Instagram app is not installed on your device");
                return false;
            }
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
//        return false;
    }

    private boolean twitterInstalled() {
        try {
            if (activity != null) {
                activity.getPackageManager()
                        .getApplicationInfo("com.twitter.android", 0);
                return true;
            } else {
                Log.d("App", "Twitter app is not installed on your device");
                return false;
            }
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
//        return false;
    }

    private boolean messengerInstalled() {
        try {
            if (activity != null) {
                activity.getPackageManager()
                        .getApplicationInfo("com.facebook.orca", 0);
                return true;
            } else {
                Log.d("App", "Messenger app is not installed on your device");
                return false;
            }
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
//        return false;
    }
}
