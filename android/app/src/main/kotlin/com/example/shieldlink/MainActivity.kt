package com.example.shieldlink

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity // ✅ Keep only this import

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE) // 🚫 Prevent Screenshots
    }
}
