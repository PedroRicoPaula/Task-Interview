package com.pedro.task4_spec_driven

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.Collections
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

class OddEvenCounterTest {

    private data class Published(val value: Int, val parity: Parity, val threadName: String)

    /** Runs a counter with no delay until it finishes and returns what it published. */
    private fun runToEnd(limit: Int): List<Published> {
        val published = Collections.synchronizedList(mutableListOf<Published>())
        val finished = CountDownLatch(1)
        OddEvenCounter(
            limit = limit,
            stepDelayMs = 0,
            onNumber = { value, parity ->
                published.add(Published(value, parity, Thread.currentThread().name))
            },
            onFinished = { finished.countDown() },
        ).start()
        assertTrue("The run did not finish", finished.await(10, TimeUnit.SECONDS))
        return published.toList()
    }

    @Test
    fun publishesEveryNumberFromOneToTheLimitInOrder() {
        assertEquals((1..20).toList(), runToEnd(20).map { it.value })
    }

    @Test
    fun eachNumberIsPublishedByTheThreadWithTheMatchingParity() {
        for (published in runToEnd(20)) {
            val expected = if (published.value % 2 == 1) Parity.ODD else Parity.EVEN
            assertEquals(expected, published.parity)
            assertEquals("${expected.label}-thread", published.threadName)
        }
    }

    @Test
    fun orderHoldsAcrossManyRunsWithNoDelay() {
        repeat(500) { run ->
            assertEquals("Run $run", (1..100).toList(), runToEnd(100).map { it.value })
        }
    }

    @Test
    fun limitOfOnePublishesOnlyOne() {
        assertEquals(listOf(1), runToEnd(1).map { it.value })
    }

    @Test
    fun limitOfZeroPublishesNothingAndStillFinishes() {
        assertEquals(emptyList<Int>(), runToEnd(0).map { it.value })
    }

    @Test
    fun stopEndsTheRunEarlyWithoutCallingOnFinished() {
        val published = Collections.synchronizedList(mutableListOf<Int>())
        val firstNumber = CountDownLatch(1)
        val finished = AtomicBoolean(false)
        val counter = OddEvenCounter(
            limit = 1_000,
            stepDelayMs = 20,
            onNumber = { value, _ ->
                published.add(value)
                firstNumber.countDown()
            },
            onFinished = { finished.set(true) },
        )

        counter.start()
        assertTrue(firstNumber.await(5, TimeUnit.SECONDS))
        counter.stop()
        counter.stop() // A second call is harmless.

        Thread.sleep(100)
        val countAfterStop = published.size
        Thread.sleep(200)

        assertEquals("Numbers were published after stop()", countAfterStop, published.size)
        assertTrue(countAfterStop < 1_000)
        assertFalse(finished.get())
    }
}
