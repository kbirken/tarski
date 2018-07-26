package org.nanosite.tarski.types

/** 
 * An "vague" (abstract) boolean which can represent true and false at the same time.</p>
 * 
 * The vague boolean can have three values:
 * <ul>
 * <li>false (like a concrete boolean)</li>
 * <li>true (like a concrete boolean)</li>
 * <li>false or true (i.e., value is not known, a bit like a quantum bit)</li>
 * </ul></p>
 * 
 * It provides two sets of operations on abstract booleans:
 * <ul>
 * <li>the usual operations on booleans (e.g., not, and, or, ...)</li>
 * <li>operations on any kind of abstract values (e.g., isEqualAbstract,
 * isSpecialization, merge, ...)</li>
 * </ul></p>
 * 
 * @author Klaus Birken (initial contribution)
 */
class VagueBoolean implements IBooleanLattice {
	
	public static val TRUE = new VagueBoolean(true)
	public static val FALSE = new VagueBoolean(false)
	public static val UNKNOWN = new VagueBoolean()
	
	val boolean aspectFalse
	val boolean aspectTrue

	// constructors are private, clients should use literals
	private new() {
		this.aspectFalse = true
		this.aspectTrue = true
	}

	// constructors are private, clients should use literals
	private new(boolean value) {
		this.aspectFalse = !value
		this.aspectTrue = value
	}
	
	override boolean equals(Object other) {
		if (other===null)
			return false
		if (other instanceof VagueBoolean) {
			aspectFalse === other.aspectFalse && aspectTrue === other.aspectTrue
		} else {
			true
		}
	}
	
	override int hashCode() {
		throw new RuntimeException("NIY - it is not clear how to hash with abstract values")
	}

//	override int getTypeId() {
//		// TODO: this should be defined centrally
//		77
//	}

	override VagueBoolean cloneTyped() {
		// there is only one instance for each VagueBoolean value
		this
	}

	override boolean isUndefined() {
		aspectFalse && aspectTrue
	}

	override boolean isConcrete() {
		isFalse() || isTrue()
	}

	override VagueBoolean isEqualAbstract(ILatticeType other) {
		if (other instanceof VagueBoolean) {
			if (this==other) {
				return TRUE
			}
			if (aspectFalse === other.aspectFalse || aspectTrue === other.aspectTrue) {
				return UNKNOWN
			}
			FALSE
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}

	override VagueBoolean isNotEqualAbstract(ILatticeType other) {
		! isEqualAbstract(other)
	}

	// merge this VagueBoolean with another VagueBoolean
	// this and other are a specialization of the result
	override VagueBoolean lub(ILatticeType other) {
		if (other instanceof VagueBoolean) {
			val noFalse = (!aspectFalse) && (!other.aspectFalse)
			val noTrue = (!aspectTrue) && (!other.aspectTrue)
			if (noFalse) {
				return TRUE
			}
			if (noTrue) {
				return FALSE
			}
			UNKNOWN
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}


	override boolean isFalse() {
		aspectFalse && !aspectTrue
	}

	override boolean isTrue() {
		!aspectFalse && aspectTrue
	}

	override boolean maybeFalse() {
		aspectFalse
	}

	override boolean maybeTrue() {
		aspectTrue
	}

	// private static AbstractValue.Type TYPE = AbstractValueTypeSystem.type(AbstractBoolean.class.toString)
	// public AbstractValue.Type type() { TYPE }
	
	// abstract logical negation
	override VagueBoolean operator_not() {
		if (isTrue()) {
			return FALSE
		}
		if (isFalse()) {
			return TRUE
		}
		return UNKNOWN
	}

	// abstract logical 'or'
	override VagueBoolean operator_or(IBooleanLattice other) {
		if (other instanceof VagueBoolean) {
			val noTrue = (!aspectTrue) && (!other.aspectTrue)
			val mayFalse = aspectFalse && other.aspectFalse
			if (noTrue) {
				return FALSE
			}
			if (!mayFalse) {
				return TRUE
			}
			UNKNOWN
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}

	// abstract logical 'and'
	override VagueBoolean operator_and(IBooleanLattice other) {
		if (other instanceof VagueBoolean) {
			val noFalse = (!aspectFalse) && (!other.aspectFalse)
			val mayTrue = aspectTrue && other.aspectTrue
			if (noFalse) {
				return TRUE
			}
			if (!mayTrue) {
				return FALSE
			}
			UNKNOWN
		} else {
			throw new RuntimeException("Invalid argument type")
		}
	}

	override String toString() {
		if (aspectFalse) {
			if (aspectTrue) "{F,T}" else "{F}"
		} else {
			if (aspectTrue) "{T}" else "{}"
		}
	}
	
}
