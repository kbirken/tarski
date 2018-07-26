package org.nanosite.tarski.types

interface IIntegerLattice extends ILatticeType {

	def <T extends IIntegerLattice> T operator_plus(IIntegerLattice other)

}
