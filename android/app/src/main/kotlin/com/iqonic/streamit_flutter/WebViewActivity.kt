package com.vn2.phim

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.util.Log
import android.view.MenuItem
import android.view.View
import android.webkit.ValueCallback
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import com.vn2.phim.databinding.ActivityStreamitWebViewBinding

@SuppressLint("SetJavaScriptEnabled")
class WebViewActivity : AppCompatActivity() {

    private lateinit var binding: ActivityStreamitWebViewBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = ActivityStreamitWebViewBinding.inflate(layoutInflater)
        setContentView(binding.root)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setBackgroundDrawable(ColorDrawable(Color.parseColor("#141414")))

        val url = intent.getStringExtra("url")!!
        val username: String = intent.getStringExtra("username")!!
        val password: String = intent.getStringExtra("password")!!
        var isLoggedIn: Boolean = intent.getBooleanExtra("isLoggedIn", false)

        val myWebView: WebView = binding.streamitNativeWebView

        myWebView.settings.javaScriptEnabled = true
        myWebView.settings.allowFileAccess = true
        myWebView.settings.allowContentAccess = true

        Log.d("url", url)

        myWebView.setBackgroundColor(Color.parseColor("#000000"))

        myWebView.clearCache(true)

        Log.d("Final URL", "URL: $url")

        myWebView.loadUrl(url)

        myWebView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                view?.loadUrl(url!!)
                return true
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                Log.d("onPageFinished", url!!)
                binding.progressBar.visibility = View.GONE

                if (!isLoggedIn && url.contains("_wpnonce")) {
                    myWebView.evaluateJavascript("document.getElementById('pms_login').submit()") {
                        //
                    }
                }

                if (isLoggedIn) {

                    myWebView.evaluateJavascript("document.getElementById('user_login').value ='${username}'", ValueCallback {
                        //
                    })
                    myWebView.evaluateJavascript("document.getElementById('user_pass').value = '${password}'") {
                        //
                    }

                    myWebView.evaluateJavascript("document.getElementById('pms_login').submit()") {
                        //
                    }
                    isLoggedIn = false
                }
            }

            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                Log.d("onPageFinished", url!!)
                binding.progressBar.visibility = View.VISIBLE
            }
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        // Handle presses on the action bar menu items
        when (item.itemId) {
            android.R.id.home -> {
                onBackPressed()
                return true
            }
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onBackPressed() {
        if (binding.streamitNativeWebView.canGoBack()) {
            binding.streamitNativeWebView.evaluateJavascript(
                "var check = document.getElementsByClassName('pms-account-navigation-link--logout');\n" +
                        "if (check.length > 0) {\n" +
                        "    // elements with class \"snake--mobile\" exist\n" +
                        "document.querySelector('.pms-account-navigation-link--logout a').click();\n" +
                        "}", ValueCallback {})


            binding.streamitNativeWebView.goBack()
        } else {
            binding.streamitNativeWebView.evaluateJavascript(
                "var check = document.getElementsByClassName('pms-account-navigation-link--logout');\n" +
                        "if (check.length > 0) {\n" +
                        "    // elements with class \"snake--mobile\" exist\n" +
                        "document.querySelector('.pms-account-navigation-link--logout a').click();\n" +
                        "}", ValueCallback {})


            binding.streamitNativeWebView.clearCache(true)
            binding.streamitNativeWebView.clearFormData()
            binding.streamitNativeWebView.clearHistory()
            binding.streamitNativeWebView.clearMatches()
            binding.streamitNativeWebView.clearSslPreferences()
            super.onBackPressed()
        }
    }
}
