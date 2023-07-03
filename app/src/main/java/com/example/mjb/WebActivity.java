package com.example.mjb;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.DownloadListener;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.TextView;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class WebActivity extends Activity {
    private WebView webView;
    private String loadUrl;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        loadUrl = getIntent().getStringExtra("url");
        Log.e("TAG", "loadUrl  ="+loadUrl);

        loadUrl = "www.baidu.com";
        if (TextUtils.isEmpty(loadUrl)){
            finish();
        }
        RelativeLayout relativeLayout = new RelativeLayout(this);
        relativeLayout.setLayoutParams(new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
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
        });
        webView.setLayoutParams(new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        webView.loadUrl(loadUrl);
        TextView textView = new TextView(this);
        textView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent();
                setResult(RESULT_OK, intent);
                finish();
            }
        });
        textView.setText("X ");
        textView.setTextColor(Color.RED);
        textView.setTextSize(25);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.setMargins(10,20,20,10);
        textView.setLayoutParams(layoutParams);
        textView.setId(View.generateViewId());
        ((RelativeLayout.LayoutParams)(textView.getLayoutParams())).addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
        relativeLayout.addView(webView);
        relativeLayout.addView(textView);
        setContentView(relativeLayout);
    }

    private void setSetting() {
        WebSettings setting = webView.getSettings();
        setting.setJavaScriptEnabled(true);
        setting.setJavaScriptCanOpenWindowsAutomatically(true);
        setting.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        setting.setDomStorageEnabled(true);
        setting.setCacheMode(WebSettings.LOAD_DEFAULT);
        setting.setAllowContentAccess(true);
        setting.setDatabaseEnabled(true);
        setting.setGeolocationEnabled(true);
        setting.setUseWideViewPort(true);
//        setting.setAppCacheEnabled(true);
        setting.setUserAgentString(setting.getUserAgentString().replaceAll("; wv",""));
        // 视频播放需要使用
        int SDK_INT = Build.VERSION.SDK_INT;
        if (SDK_INT > 16) {
            setting.setMediaPlaybackRequiresUserGesture(false);
        }
        setting.setSupportZoom(false);//支持缩放

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
            Intent intent = new Intent();
            setResult(RESULT_OK, intent);
            finish();

        }
    }
}
