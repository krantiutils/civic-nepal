package com.nepal.constitution.nepal_civic

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.nepal.constitution.nepal_civic/foreground_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startDateService" -> {
                    startDateForegroundService()
                    result.success(true)
                }
                "stopDateService" -> {
                    stopDateForegroundService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(isServiceRunning())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun startDateForegroundService() {
        val serviceIntent = Intent(this, DateForegroundService::class.java).apply {
            action = DateForegroundService.ACTION_START
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopDateForegroundService() {
        val serviceIntent = Intent(this, DateForegroundService::class.java).apply {
            action = DateForegroundService.ACTION_STOP
        }
        startService(serviceIntent)
    }

    private fun isServiceRunning(): Boolean {
        val manager = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (DateForegroundService::class.java.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
