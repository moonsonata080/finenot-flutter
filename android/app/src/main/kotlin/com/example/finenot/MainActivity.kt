package com.example.finenot

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity onCreate called")
    }
    
    override fun onResume() {
        super.onResume()
        Log.d(TAG, "MainActivity onResume called")
    }
}
