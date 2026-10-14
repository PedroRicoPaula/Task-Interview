package com.pedro.task4_spec_driven

import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/** Which of the two threads published a number. */
enum class Parity(val label: String) {
    ODD("odd"),
    EVEN("even");

    /** True when it is this thread's turn to publish [number]. */
    fun owns(number: Int): Boolean = (number % 2 == 1) == (this == ODD)
}

/**
 * Two threads that take turns counting: `odd-thread` publishes 1, 3, 5, ...
 * and `even-thread` publishes 2, 4, 6, ..., so together they publish
 * 1, 2, 3, ... up to [limit], in order.
 *
 * The turn is the shared field [next], guarded by [lock]. Only the thread whose
 * parity matches [next] may publish it, and it only moves [next] on after
 * publishing. See section 4 of docs/02-technical-spec.md.
 *
 * [onNumber] and [onFinished] are called on the counting threads.
 */
class OddEvenCounter(
    private val limit: Int,
    private val stepDelayMs: Long,
    private val onNumber: (value: Int, parity: Parity) -> Unit,
    private val onFinished: () -> Unit,
) {
    private val lock = ReentrantLock()
    private val turnChanged = lock.newCondition()

    // Guarded by lock.
    private var next = 1
    private var running = false
    private var started = false

    private val activeThreads = AtomicInteger(0)

    @Volatile
    private var threads: List<Thread> = emptyList()

    /** Starts both threads. A counter can only be started once. */
    fun start() {
        lock.withLock {
            check(!started) { "OddEvenCounter can only be started once." }
            started = true
            running = true
        }
        val workers = Parity.entries.map { parity ->
            Thread({ count(parity) }, "${parity.label}-thread").apply { isDaemon = true }
        }
        threads = workers
        activeThreads.set(workers.size)
        workers.forEach(Thread::start)
    }

    /** Stops both threads promptly. [onFinished] is not called. Safe to call more than once. */
    fun stop() {
        lock.withLock {
            running = false
            turnChanged.signalAll()
        }
        // Wakes a thread that is sleeping between two numbers.
        threads.forEach(Thread::interrupt)
    }

    private fun count(parity: Parity) {
        try {
            while (true) {
                val value = lock.withLock {
                    while (running && next <= limit && !parity.owns(next)) {
                        turnChanged.await()
                    }
                    if (!running || next > limit) return
                    next
                }

                // Still our turn: next has not moved yet, so the other thread is waiting.
                onNumber(value, parity)
                if (stepDelayMs > 0) Thread.sleep(stepDelayMs)

                lock.withLock {
                    next = value + 1 // Hands the turn to the other thread.
                    turnChanged.signalAll()
                }
            }
        } catch (_: InterruptedException) {
            // stop() interrupted this thread; leaving the loop is all that is needed.
        } finally {
            val lastToExit = activeThreads.decrementAndGet() == 0
            if (lastToExit && lock.withLock { running }) onFinished()
        }
    }
}
