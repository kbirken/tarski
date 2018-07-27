package org.nanosite.tarski.psm.fsmapi

import org.nanosite.tarski.psm.psmapi.IInterface

/**
 * The abstraction of a component port as used by the Franca SemanticsChecker.</p>
 * 
 * A port will be typed by a Franca interface and has a direction (required vs. provided).
 * A component will have one or more ports. Two or more ports of a component might have
 * the same type (aka Franca interface).</p>
 * 
 * @see IExecutionFSM
 * @see IComponent
 * 
 * @author Klaus Birken (initial contribution)  
 */
interface IPort {
	
	/**
	 * Get the name of this port.
	 */
	def String getName()
	
	/**
	 * Get the interface definition this port adheres to.</p>
	 * 
	 * The interface can be regarded as the type of this port.
	 */
	def IInterface getInterface()
	
	/**
	 * Is the port offering the interface in the server role?</p>
	 * 
	 * There are two options for a port:
	 * <ol>
	 * <li>The component provides the interface via the port: isServer() returns true.
	 *     In this case, the component has the server role in the communication.</li>
	 * <li>The component requires the interface via the port: isServer() returns false.
	 *     In this case, the component has the client role in the communication.</li>
	 * </ol>
	 * 
	 * @return true if the component is a server, false if the component is a client 
	 */
	def boolean isServer()
	
}
