package org.nanosite.tarski.types.tests

import org.junit.Test

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue
import static org.junit.Assert.assertFalse

import static extension org.nanosite.tarski.types.VagueBoolean.*

class VagueBooleanTests {

	@Test
	def void testBooleanNot() {
		assertEquals(FALSE, !TRUE)
		assertEquals(TRUE, !FALSE)
		assertEquals(UNKNOWN, !UNKNOWN)
	}
	
	@Test
	def void testBooleanAnd() {
		assertEquals(FALSE, FALSE && FALSE)
		assertEquals(FALSE, FALSE && UNKNOWN)
		assertEquals(FALSE, FALSE && TRUE)
		assertEquals(FALSE, UNKNOWN && FALSE)
		assertEquals(UNKNOWN, UNKNOWN && UNKNOWN)
		assertEquals(UNKNOWN, UNKNOWN && TRUE)
		assertEquals(FALSE, TRUE && FALSE)
		assertEquals(UNKNOWN, TRUE && UNKNOWN)
		assertEquals(TRUE, TRUE && TRUE)
	}
	
	@Test
	def void testBooleanOr() {
		assertEquals(FALSE, FALSE || FALSE)
		assertEquals(UNKNOWN, FALSE || UNKNOWN)
		assertEquals(TRUE, FALSE || TRUE)
		assertEquals(UNKNOWN, UNKNOWN || FALSE)
		assertEquals(UNKNOWN, UNKNOWN || UNKNOWN)
		assertEquals(TRUE, UNKNOWN || TRUE)
		assertEquals(TRUE, TRUE || FALSE)
		assertEquals(TRUE, TRUE || UNKNOWN)
		assertEquals(TRUE, TRUE || TRUE)
	}	

	@Test
	def void testEquals() {
		assertTrue(FALSE==FALSE)
		assertFalse(FALSE==UNKNOWN)
		assertFalse(FALSE==TRUE)
		assertFalse(UNKNOWN==FALSE)
		assertTrue(UNKNOWN==UNKNOWN)
		assertFalse(UNKNOWN==TRUE)
		assertFalse(TRUE==FALSE)
		assertFalse(TRUE==UNKNOWN)
		assertTrue(TRUE==TRUE)
	}

	@Test
	def void testVagueTypeAPI() {
		assertTrue(FALSE.isConcrete)
		assertFalse(UNKNOWN.isConcrete)
		assertTrue(TRUE.isConcrete)

		assertFalse(FALSE.isUndefined)
		assertTrue(UNKNOWN.isUndefined)
		assertFalse(TRUE.isUndefined)

		assertEquals(TRUE, FALSE.isEqualAbstract(FALSE))
		assertEquals(UNKNOWN, FALSE.isEqualAbstract(UNKNOWN))
		assertEquals(FALSE, FALSE.isEqualAbstract(TRUE))
		assertEquals(UNKNOWN, UNKNOWN.isEqualAbstract(FALSE))
		assertEquals(TRUE, UNKNOWN.isEqualAbstract(UNKNOWN)) // TODO: correct? shouldn't this return UNKNOWN? 
		assertEquals(UNKNOWN, UNKNOWN.isEqualAbstract(TRUE))
		assertEquals(FALSE, TRUE.isEqualAbstract(FALSE))
		assertEquals(UNKNOWN, TRUE.isEqualAbstract(UNKNOWN))
		assertEquals(TRUE, TRUE.isEqualAbstract(TRUE))

		assertEquals(FALSE, FALSE.isNotEqualAbstract(FALSE))
		assertEquals(UNKNOWN, FALSE.isNotEqualAbstract(UNKNOWN))
		assertEquals(TRUE, FALSE.isNotEqualAbstract(TRUE))
		assertEquals(UNKNOWN, UNKNOWN.isNotEqualAbstract(FALSE))
		assertEquals(FALSE, UNKNOWN.isNotEqualAbstract(UNKNOWN)) // TODO: correct? shouldn't this return UNKNOWN? 
		assertEquals(UNKNOWN, UNKNOWN.isNotEqualAbstract(TRUE))
		assertEquals(TRUE, TRUE.isNotEqualAbstract(FALSE))
		assertEquals(UNKNOWN, TRUE.isNotEqualAbstract(UNKNOWN))
		assertEquals(FALSE, TRUE.isNotEqualAbstract(TRUE))
	}

	@Test
	def void testVagueMerge() {
		assertEquals(FALSE, FALSE.lub(FALSE))
		assertEquals(UNKNOWN, FALSE.lub(UNKNOWN))
		assertEquals(UNKNOWN, FALSE.lub(TRUE))
		assertEquals(UNKNOWN, UNKNOWN.lub(FALSE))
		assertEquals(UNKNOWN, UNKNOWN.lub(UNKNOWN)) 
		assertEquals(UNKNOWN, UNKNOWN.lub(TRUE))
		assertEquals(UNKNOWN, TRUE.lub(FALSE))
		assertEquals(UNKNOWN, TRUE.lub(UNKNOWN))
		assertEquals(TRUE, TRUE.lub(TRUE))
	}
		
	@Test
	def void testVagueBooleanAPI() {
		assertFalse(FALSE.isTrue)
		assertFalse(UNKNOWN.isTrue)
		assertTrue(TRUE.isTrue)

		assertTrue(FALSE.isFalse)
		assertFalse(UNKNOWN.isFalse)
		assertFalse(TRUE.isFalse)

		assertFalse(FALSE.maybeTrue)
		assertTrue(UNKNOWN.maybeTrue)
		assertTrue(TRUE.maybeTrue)

		assertTrue(FALSE.maybeFalse)
		assertTrue(UNKNOWN.maybeFalse)
		assertFalse(TRUE.maybeFalse)
	}

	@Test
	def void testToString() {
		assertEquals("{T}", TRUE.toString)
		assertEquals("{F}", FALSE.toString)
		assertEquals("{F,T}", UNKNOWN.toString)
	}	
}
