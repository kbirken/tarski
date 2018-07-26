package org.nanosite.tarski.types

/** 
 * The common interface for all lattice types.</p>
 * 
 * See https://en.wikipedia.org/wiki/Lattice_(order) for background on lattices.</p>
 * 
 * @author Klaus Birken (initial contribution)
 */
interface ILatticeType {
//	static class Type {
//		val int id
//
//		new(int id) {
//			this.id = id
//		}
//	}
//
//	// the value's type (base for a type-system)
//	public static Type type() {
//		return AbstractValueTypeSystem.getType(T.class.toString)
//	}
	
	/**
	 * Each type has a unique id (used for type comparison).</p>
	 */
	//def int getTypeId()

	/**
	 * Create a copy of the type object.</p>
	 */
	def <T extends ILatticeType> T cloneTyped()

	/**
	 * Check if the value is actually abstract.</p>
	 */
	def boolean isUndefined()

	/**
	 * Check if the value is actually concrete.</p>
	 * 
	 * If yes, it could be represented by a concrete type.</p>
	 */
	def boolean isConcrete()

	/**
	 * Least upper bound of two values.</p>
	 * 
	 * The result is a generalization of both input values.</p>
	 */
	def <T extends ILatticeType> T lub(ILatticeType other)

	/**
	 * Check for concrete equality of lattice values.</p>
	 */
	def boolean isEqual(ILatticeType other)

	/**
	 * Check for abstract equality.</p>
	 */
	def <B extends IBooleanLattice> B isEqualAbstract(ILatticeType other)

	/**
	 * Check for abstract inequality.</p>
	 */
	def <B extends IBooleanLattice> B isNotEqualAbstract(ILatticeType other)
}
