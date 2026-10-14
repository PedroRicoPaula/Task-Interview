package com.pedro.task4_spec_driven

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Connects [OddEvenCounter] to Flutter through an [EventChannel].
 *
 * Listening to the stream starts a run and cancelling it stops the run. Every
 * event is posted to the main thread, as Flutter requires for channel messages.
 * See section 5 of docs/02-technical-spec.md.
 */
class CounterStreamHandler : EventChannel.StreamHandler {
    private val mainThread = Handler(Looper.getMainLooper())

    // Only read and written on the main thread.
    private var sink: EventChannel.EventSink? = null
    private var counter: OddEvenCounter? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) return
        stop() // One run at a time.

        val args = arguments as? Map<*, *>
        val limit = (args?.get("limit") as? Number)?.toInt()
        val stepDelayMs = (args?.get("stepDelayMs") as? Number)?.toLong()
        if (limit == null || limit < 0 || stepDelayMs == null || stepDelayMs < 0) {
            events.error(
                "INVALID_ARGUMENT",
                "Expected {limit: int >= 0, stepDelayMs: int >= 0}, got $arguments",
                null,
            )
            return
        }

        sink = events
        counter = OddEvenCounter(
            limit = limit,
            stepDelayMs = stepDelayMs,
            onNumber = { value, parity ->
                send(events, mapOf("type" to "number", "value" to value, "thread" to parity.label))
            },
            onFinished = {
                send(events, mapOf("type" to "finished"), endOfStream = true)
            },
        ).also { it.start() }
    }

    override fun onCancel(arguments: Any?) = stop()

    /** Stops the current run, if any. Events it has already queued are dropped. */
    fun stop() {
        counter?.stop()
        counter = null
        sink = null
    }

    /**
     * Posts [event] to the main thread. It is only delivered if [events] still
     * belongs to the current run, so a stopped run can never leak into a new one.
     */
    private fun send(events: EventChannel.EventSink, event: Map<String, Any>, endOfStream: Boolean = false) {
        mainThread.post {
            if (sink !== events) return@post
            events.success(event)
            if (endOfStream) {
                events.endOfStream()
                sink = null
                counter = null
            }
        }
    }
}
