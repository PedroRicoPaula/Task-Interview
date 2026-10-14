package com.pedro.task4_spec_driven

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val counterHandler = CounterStreamHandler()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COUNTER_CHANNEL)
            .setStreamHandler(counterHandler)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // No counting thread may outlive the screen (FR-13).
        counterHandler.stop()
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val COUNTER_CHANNEL = "com.pedro.task4_spec_driven/counter"
    }
}
