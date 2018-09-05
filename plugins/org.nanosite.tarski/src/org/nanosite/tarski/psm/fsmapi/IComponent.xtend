/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.fsmapi

import java.util.List

/**
 * The abstraction of a component as used by the Tarski SemanticsChecker.</p>
 * 
 * @see IPort
 * 
 * @author Klaus Birken (initial contribution)  
 */
interface IComponent {

	/**
	 * Get the name of this component.
	 */	
	def String getName()
	
	/**
	 * Get the list of ports of this component.
	 */	
	def List<IPort> getPorts()
	
	/**
	 * Get the state-chart by which the component is currently implemented.</p>
	 * 
	 * The state-chart will interact with the component's environment by 
	 * being triggered by events which are received from a port or by 
	 * sending events out via one of the ports. The incoming and outgoing events
	 * are defined in terms of abstract interfaces (see Event class). 
	 */
	def IExecutionFSM getExecutionFSM()
}
