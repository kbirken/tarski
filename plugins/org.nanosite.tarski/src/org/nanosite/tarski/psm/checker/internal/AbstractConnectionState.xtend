/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.checker.internal

import java.util.Set
import org.nanosite.tarski.psm.psmapi.IContract
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent

/**
 * An abstract connection state.
 * 
 * The ConnectionState class represents a concrete state of a PSM
 * which describes the state of the connection between a client
 * and a server component. This AbstractConnectionState class represents
 * an abstract state of the connection, which is a (non-empty) set
 * of concrete states of the PSM.
 * 
 * If the abstract connection state's state-set contains only one
 * ConnectionState object, it is identical to a single PSM state,
 * i.e., no abstraction is involved. If the set contains more than
 * one state, we have to assume that the connection currently is in one
 * of those states.
 * 
 * This class is immutable.
 * 
 * @author Klaus Birken - initial contribution and API
 */
class AbstractConnectionState {
	
	val Set<ConnectionState> states
	
//	def getStates() {
//		states.immutableCopy
//	}

//	new () {
//		this.states = newLinkedHashSet
//	}

	new (IContract contract) {
		this.states = newLinkedHashSet
		states.add(new ConnectionState(contract))
	}

	/**
	 * Private constructor, used by acceptEvent().
	 */
	private new (Set<ConnectionState> states) {
		this.states = states
	}

	// TODO: remove this method
	def getStates() {
		states
	}

	/**
	 * Check if this abstract state is valid.
	 * 
	 * An abstract connection state is invalid if it doesn't contain
	 * any concrete events anymore.  
	 */
	def isValid() {
		! states.empty
	}

	/**
	 * Consume the given event and advance the abstract current state
	 * of this connection.
	 * 
	 * Each of the existing concrete states of this abstract state
	 * will either be replaced by its successor (if it can consume the
	 * event according to the PSM) or will be removed from the set
	 * (if it cannot consume the event).
	 * 
	 * @param ev the event which should be consumed
	 * @param ignoreEventOnFail defines behavior in case of events which are not
	 *     accepted: if flag is true, events which are not accepted will be simply
	 *     ignored, but the PSM remains in that state 
	 * @return a new abstract connection state
	 */
	def AbstractConnectionState acceptEvent(ICommEvent ev, boolean ignoreEventOnFail) {
		val Set<ConnectionState> newStates = newLinkedHashSet
		
		// try to consume the event by all concrete states
		for(s : states) {
			val s1 = s.acceptEvent(ev)
			if (s1===null) {
				// event hasn't been accepted by the concrete state
				if (ignoreEventOnFail)
					newStates.add(s)
				else {
					// do not add this state to the new abstract state
				}
			} else {
				// event has been accepted by this concrete state
				newStates.add(s1)
			}
		}
		
		// create a new instance (this class is immutable)
		new AbstractConnectionState(newStates)
	}

	/**
	 * Merge two abstract connection states and create a new one.
	 * 
	 * In general, the resulting "union" connection state is more abstract
	 * than any of the two input abstract states. Thus, we loose information
	 * by this operation.
	 * 
	 * @return the merged state, or null if the merge didn't result in a new state
	 */
	def AbstractConnectionState mergeWith(AbstractConnectionState other) {
		val Set<ConnectionState> union = newLinkedHashSet
		union.addAll(states)
		union.addAll(other.states)
		if (union.size != states.size)
			new AbstractConnectionState(union)
		else
			null		
	}

	override String toString() {
		'''{«states.join(',')»}'''
	}
}
