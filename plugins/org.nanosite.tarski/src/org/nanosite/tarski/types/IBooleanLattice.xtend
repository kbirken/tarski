package org.nanosite.tarski.types

import org.nanosite.tarski.types.ILatticeType

interface IBooleanLattice extends ILatticeType {
	
	def boolean isFalse()

	def boolean isTrue()

	def boolean maybeFalse()

	def boolean maybeTrue()
	

	def <B extends IBooleanLattice> B operator_not()
	
	def <B extends IBooleanLattice> B operator_or(IBooleanLattice other)

	def <B extends IBooleanLattice> B operator_and(IBooleanLattice other)

}
