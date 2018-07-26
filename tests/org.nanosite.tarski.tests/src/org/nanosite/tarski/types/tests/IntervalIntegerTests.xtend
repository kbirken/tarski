package org.nanosite.tarski.types.tests

import org.junit.Test
import org.nanosite.tarski.types.IntervalInteger

import static org.junit.Assert.assertEquals

import static org.nanosite.tarski.types.Interval.*

class IntervalIntegerTests {

	@Test
	def void testPlus() {
		assertEquals(i(5), i(2) + i(3))

		assertEquals(i(6,9), i(2,5) + i(4))
		assertEquals(i(-7,-2), i(-5,0) + i(-2))

		assertEquals(i(7,15), i(4,10) + i(3,5))
		assertEquals(i(0,10), i(4,10) + i(-4,0))

		assertEquals(i(3,POS_INF), i(0,POS_INF) + i(3))
		assertEquals(i(NEG_INF,9), i(NEG_INF,4) + i(5))
		assertEquals(i(NEG_INF,POS_INF), i(0,POS_INF) + i(NEG_INF,3))
	}	

	@Test
	def void testToString() {
		assertEquals("5", i(5).toString)
		assertEquals("[3..8]", i(3, 8).toString)
		assertEquals("[-2..2]", i(-2, 2).toString)

		assertEquals("-INF", i(NEG_INF).toString)
		assertEquals("INF", i(POS_INF).toString)
		assertEquals("[-INF..INF]", i(NEG_INF, POS_INF).toString)
	}
	
	def private IntervalInteger i(long a) {
		new IntervalInteger(a)
	}

	def private IntervalInteger i(long a, long b) {
		new IntervalInteger(a, b)
	}
}
