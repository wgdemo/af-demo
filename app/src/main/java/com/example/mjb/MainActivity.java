package com.example.mjb;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.DownloadListener;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import org.greenrobot.eventbus.EventBus;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;


public class MainActivity extends Activity {

    private static final String TAG = "MainActivity";
    private WebView webView;
    String loadUrl = "https://9955502.com";
//     String loadUrl = "https://run.edlucky333.com/home/game?currency=BRL&languageCode=pt&cid=906445&gameCategoryId=0";
//    String loadUrl = "https://9.zone/?cid=704069&languageCode=pt&type=2&currency=BRL&gtmId=G-L0FER2DBF4&&tiktokBaesCode=CI7V59JC77U8RIVTJSC0";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (TextUtils.isEmpty(loadUrl)){
            finish();
        }
        webView = new WebView(this);
        setSetting();
        webView.setWebViewClient(new WebViewClient(){
            @Override
            public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                super.onReceivedError(view, errorCode, description, failingUrl);
                if (TextUtils.equals(failingUrl,loadUrl)){
                    view.post(new Runnable() {
                        @Override
                        public void run() {
                            finish();
                        }
                    });
                }

            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                String WgPackage = "javascript:window.WgPackage = {name:'"+getPackageName()+"', version:'"+getAppVersionName(MainActivity.this)+"'}";
                webView.evaluateJavascript(WgPackage, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {

                    }
                });
            }
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
                String WgPackage = "javascript:window.WgPackage = {name:'"+getPackageName()+"', version:'"+getAppVersionName(MainActivity.this)+"'}";
                webView.evaluateJavascript(WgPackage, new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {

                    }
                });
            }
        });
        webView.addJavascriptInterface(new JsInterface() , "jsBridge");
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);

        webView.loadUrl(loadUrl);
        setContentView(webView);


    }

    public  String getAppVersionName(Context context) {
        String appVersionName = "";
        try {
            PackageInfo packageInfo = context.getApplicationContext()
                    .getPackageManager()
                    .getPackageInfo(context.getPackageName(), 0);
                appVersionName = packageInfo.versionName;
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, e.getMessage());
        }
        return appVersionName;
    }

    private void setSetting() {
        WebSettings setting = webView.getSettings();
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        setting.setSupportMultipleWindows(true);
        setting.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        setting.setDomStorageEnabled(true);
        setting.setCacheMode(WebSettings.LOAD_DEFAULT);
        setting.setAllowContentAccess(true);
        setting.setDatabaseEnabled(true);
        setting.setGeolocationEnabled(true);
        setting.setUseWideViewPort(true);
        setting.setAppCacheEnabled(true);
        setting.setUserAgentString(setting.getUserAgentString().replaceAll("; wv",""));

        // 视频播放需要使用
        int SDK_INT = Build.VERSION.SDK_INT;
        if (SDK_INT > 16) {
            setting.setMediaPlaybackRequiresUserGesture(false);
        }
        setting.setSupportZoom(false);//支持缩放
        EventBus.getDefault().post(new String());
        try {
            Class<?> clazz = setting.getClass();
            Method method = clazz.getMethod("setAllowUniversalAccessFromFileURLs", boolean.class);
            if (method != null) {
                method.invoke(setting, true);
            }
        } catch (IllegalArgumentException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            e.printStackTrace();
        }
        webView.setDownloadListener(new DownloadListener() {
            @Override
            public void onDownloadStart(String url, String userAgent, String contentDisposition, String mimetype, long contentLength) {
                Intent intent = new Intent();
                // 设置意图动作为打开浏览器
                intent.setAction(Intent.ACTION_VIEW);
                // 声明一个Uri
                Uri uri = Uri.parse(url);
                intent.setData(uri);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                startActivity(intent);
            }
        });
    }
    @Override
    public void onBackPressed() {
        if (webView.canGoBack()){
            webView.goBack();
        }else {
            super.onBackPressed();
        }
    }

    public class JsInterface {
        // Android 调用 Js 方法1 中的返回值
        @JavascriptInterface
        public void postMessage(String name, String data) {
            Log.e(TAG, "name = "+name + "    data = "+data);
            if (TextUtils.isEmpty(name) || TextUtils.isEmpty(data)) {
                return;
            }
            AppsFlyerLibUtil.event(MainActivity.this, name,data);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK) {
            if (requestCode == 1) {
                if (webView == null) {
                    return;
                }
                Log.e(TAG, "---------下分成功-----");
                /**
                 *   下分回调
                 */
                webView.evaluateJavascript("javascript:window.closeGame()", new ValueCallback<String>() {
                    @Override
                    public void onReceiveValue(String value) {

                    }
                });
            }
        }
    }
}
