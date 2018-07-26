package org.nanosite.tarski.types

import org.nanosite.tarski.types.ILatticeType

import static org.nanosite.tarski.types.Interval.*

/**
 * An abstract integer type which can represent multiple concrete integer numbers.</p>
 *
 * The abstract number is represented as an integer interval.
 * It provides two sets of operations on abstract numbers:
 * <ul>
 * <li>the usual arithmetic operations (e.g., plus, minus, ...)</li>
 * <li>operations on any kind of abstract values (e.g., isEqualAbstract,
 *     isSpecialization, merge, ...)</li>
 * </ul></p>
 *
 * @author KLaus Birken (initial contribution)
 */
class IntervalInteger implements IIntegerLattice {
	
	public static val IntervalInteger BOTTOM = new IntervalInteger
	
	val Interval iv
	
	// the interval-less instance will be a singleton (no public access)
	private new() {
		this.iv = null
	}
	
	new(long a) {
		this.iv = new Interval(a, a)
	}
	
	new(long a, long b) {
		this.iv = new Interval(a, b)
	}
	
	new(Interval iv) {
		// as Interval objects are immutable, we can share them here
		this.iv = iv
	}

	override boolean equals(Object other) {
		if (other===null)
			return false
		if (other instanceof IntervalInteger) {
			if (iv===null && other.iv===null)
				return true
			if (iv===null || other.iv===null)
				return false
				
			iv.a==other.iv.a && iv.b==other.iv.b
		} else {
			return false
		}
	}

	override int hashCode() {
		throw new RuntimeException("NIY - it is not clear how to hash with abstract values")
	}
	
	override IntervalInteger cloneTyped() {
		new IntervalInteger(iv)
	}
	
	override isUndefined() {
		iv!==null && iv.a==NEG_INF && iv.b==POS_INF
	}
	
	override isConcrete() {
		iv!==null && iv.a==iv.b
	}
	
	override IntervalInteger lub(ILatticeType other) {
		if (other instanceof IntervalInteger) {
			if (iv===null)
				return other
			if (other.iv===null)
				return this

			new IntervalInteger(
				Long.min(iv.a, other.iv.a),
				Long.max(iv.b, other.iv.b)
			)
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}
	
	override IBooleanLattice isEqualAbstract(ILatticeType other) {
		if (other instanceof IntervalInteger) {
			if (iv===null && other.iv===null)
				return VagueBoolean.TRUE
			if (iv===null || other.iv===null)
				return VagueBoolean.FALSE
			
			if (iv.isEqual(other.iv)) {
				VagueBoolean.TRUE
			} else {
				if (iv.overlaps(other.iv))
					VagueBoolean.UNKNOWN
				else
					VagueBoolean.FALSE
			}
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}
	
	override IBooleanLattice isNotEqualAbstract(ILatticeType other) {
		! isEqualAbstract(other)
	}

	def lowerBound() {
		iv.a
	}	

	def upperBound() {
		iv.b
	}
	
	override IntervalInteger operator_plus(IIntegerLattice other) {
		if (other instanceof IntervalInteger) {
			if (iv===null)
				return other
			if (other.iv===null)
				return this
			val iv2 = other.iv
			val a = if (iv.a==NEG_INF || iv2.a==NEG_INF) NEG_INF else iv.a+iv2.a
			val b = if (iv.b==POS_INF || iv2.b==POS_INF) POS_INF else iv.b+iv2.b
			new IntervalInteger(a, b)
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}
	
	override String toString() {
		if (iv===null)
			"#?#"
		else
			iv.toString
	}		
}
