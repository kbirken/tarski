/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
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
