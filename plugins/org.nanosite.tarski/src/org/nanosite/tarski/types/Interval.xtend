package org.nanosite.tarski.types

class Interval {
	static public val long NEG_INF = Long.MIN_VALUE
	static public val long POS_INF = Long.MAX_VALUE

	val long a
	val long b

	new(long i, long j) {
		// precondition (sanity check)
		if (i>j) {
			throw new RuntimeException("Invalid interval range " + i + ".." + j)
		}
		a = i
		b = j
	}

	new(Interval orig) {
		a = orig.a
		b = orig.b
	}

	def long getA() {
		a
	}

	def long getB() {
		b
	}

	def boolean isEqual(Interval other) {
		a === other.a && b === other.b
	}

	def boolean contains(long i) {
		a <= i && i <= b
	}

	def boolean contains(Interval other) {
		a <= other.a && other.b <= b
	}

	def boolean overlaps(Interval other) {
		contains(other.a) || contains(other.b) ||
		other.contains(a) || other.contains(b)
	}

	def boolean partlyOverlaps(Interval other) {
		if (contains(other) || other.contains(this)) {
			// completely containing other, this is no partly overlap
			false
		} else {
			contains(other.a) || contains(other.b)
		}
	}

	def boolean isContiguous(Interval other) {
		b+1 === other.a || other.b+1 === a
	}

	def boolean lessThan(Interval other) {
		return b < other.a
	}

	def boolean lessThanOrEqual(Interval other) {
		return b <= other.a
	}

//	def boolean merge(Interval other) {
//		if (overlaps(other) || isContiguous(other)) {
//			// both intervals overlap, we can merge
//			if (other.a < a) a = other.a
//			if (other.b > b) b = other.b
//			true
//		} else {
//			false
//		}
//	}

//	def boolean cutTo(long i) {
//		if(i < a)
//			return false
//		if(i < b)
//			b = i
//		true
//	}

//	def boolean cutFrom(long i) {
//		if (b < i)
//			return false
//		if (a < i)
//			a = i
//		true
//	}

	override toString() {
		if (a === b) {
			'''«toString(a)»'''
		} else {
			'''[«toString(a)»..«toString(b)»]'''
		}
	}

	def private toString(long i) {
		if(i === NEG_INF) return "-INF"
		if(i === POS_INF) return "INF"
		return '''«i»'''
	}
}
