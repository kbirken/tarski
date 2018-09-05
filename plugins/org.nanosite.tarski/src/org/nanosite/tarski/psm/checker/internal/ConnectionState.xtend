/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.checker.internal

import org.nanosite.tarski.psm.psmapi.IContract
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent
import org.nanosite.tarski.psm.psmapi.IProtocolSM.IPSMState
import org.nanosite.tarski.psm.psmapi.IProtocolSM.IPSMTransition

/**
 * Current state of a connection (which is represented by a PSM).
 * 
 * We assume that a client component and a server component are 
 * connected and the common interface is defined by a Franca contract.
 * The state of the connection is the current state of the PSM of this
 * contract.
 * 
 * This class also provides a method to accept an event and compute a new
 * connection state by advancing the current state according to this event.
 * 
 * This class is immutable. 
 * 
 * @author Klaus Birken - initial contribution and API
 */
class ConnectionState {
	
//	val IContract contract
	var IPSMState currentState
	
	new (IContract contract) {
//		this.contract = contract
		this.currentState = contract.PSM.initial
	}
	
	private new (IPSMState state) {
		this.currentState = state
	}

//	def getName() {
//		currentState.name
//	}

	/**
	 * Consume the given event and advance the current state of this connection.
	 * 
	 * @param ev the event which should be consumed
	 * @return a new connection state if event was accepted, null otherwise
	 */
	def ConnectionState acceptEvent(ICommEvent ev) {
		// find an outgoing transition which is triggered by this event
		val match = ev.matchedEvent
		
		// found a transition?
		if (match!==null) {
			// yes, advance the PSM state to the transition's target
			new ConnectionState(match.to)
		} else {
			// no matching outgoing transition, do not accept the event
			null
		}
	}
	
	/**
	 * Get all outgoing PSM transitions.
	 */
	def Iterable<IPSMTransition> getOutgoing() {
		currentState.outgoing
	}

	/**
	 * Check if the PSM accepts the given event in its current state.
	 * 
	 * @param ev the event to be accepted
	 * @return true if event would be accepted in the current state, false otherwise
	 */
	def boolean willAcceptEvent(ICommEvent ev) {
		ev.matchedEvent !== null
	}

	/**
	 * Find all outgoing PSM transitions which are not matched by any of the input events.
	 */
	def Iterable<IPSMTransition> getUnmatched(Iterable<ICommEvent> events) {
		val matched = events.map[getMatchedEvent].filterNull.toSet
		currentState.outgoing.filter[! matched.contains(it)]
	}

	/**
	 * Find first outgoing transition of the current PSM state which
	 * is triggered by the given event.
	 * 
	 * @param ev the event which should trigger a transition
	 * @return the first outgoing transition which is triggered by this event   
	 */
	def private getMatchedEvent(ICommEvent ev) {
		currentState.outgoing.findFirst[it.trigger.event.isEqual(ev)]
	}
	
	override boolean equals(Object obj) {
		if (this === obj)
			return true
			
		if (obj===null || (obj.class!=this.class))
			return false
			
		val other = obj as ConnectionState
		this.currentState == other.currentState
	}
	
	override int hashCode() {
		currentState.hashCode
	}


	override String toString() {
		val sb = new StringBuilder
		sb.append(currentState.name)
		sb.append("<")
		sb.append(currentState.outgoing.map[it.trigger.event.ID].join(","))
		sb.append(">")
		sb.toString
	}

}
