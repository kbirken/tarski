/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests.utils

import java.util.Collection
import java.util.List
import java.util.Map
import org.nanosite.tarski.psm.psmapi.IProtocolSM
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent
import org.nanosite.tarski.psm.psmapi.IProtocolSM.IPSMTrigger
import org.nanosite.tarski.psm.tests.utils.TestPSM.Transition

class TestPSM implements IProtocolSM {

	static class State implements IPSMState {
		
		val String name
		val List<IPSMTransition> outgoing = newArrayList

		new (String name) {
			this.name = name	
		}

		override getName() {
			name
		}
		
		override getOutgoing() {
			outgoing
		}
		
		def addOutgoing(IPSMTransition tr) {
			outgoing.add(tr)
		}
	}

	static class Transition implements IPSMTransition {
		val IPSMState to
		val IPSMTrigger trigger
		
		new(IPSMState to, IPSMTrigger trigger) {
			this.to = to
			this.trigger = trigger
		}
		
		override getTrigger() {
			trigger
		}
		
		override getTo() {
			to
		}
		
		override getAction() {
			throw new UnsupportedOperationException("TODO: auto-generated method stub")
		}
		
	}
	
	val State initialState
	val List<IPSMState> states = newArrayList
	val Map<String, State> stateMap = newHashMap
	
	val Map<String, ICommEvent> eventMap = newHashMap
	
	new(String initialState, Collection<String> otherStates) {
		this.initialState = new State(initialState)
		addState(this.initialState)

		for(s : otherStates) {
			addState(new State(s))
		}
	}

	override getInitial() {
		initialState
	}
	
	override getStates() {
		states
	}
	
	def addState(State s) {
		states.add(s)
		stateMap.put(s.name, s)
	}
	
	def getState(String s) {
		stateMap.get(s)
	}

	def addTransition(String sFrom, String sTo, ICommEvent ev) {
		val trigger = new IProtocolSM.IPSMTrigger() {
			override getEvent() { ev }
		}

		val from = getState(sFrom)
		val to = getState(sTo)
		from.addOutgoing(new Transition(to, trigger))
		
		if (! eventMap.containsKey(ev.getID)) {
			eventMap.put(ev.getID, ev)
		}
	}
	
	def getEvent(String id) {
		eventMap.get(id)
	}

	/**
	 * Utility method to create an event sent from client to server.</p>
	 */
	def protected fromClient(String label) {
		createEvent(label, true)
	}

	/**
	 * Utility method to create an event sent from server to client.</p>
	 */
	def protected fromServer(String label) {
		createEvent(label, false)
	}

	def private createEvent(String eventLabel, boolean client2server) {
		new ICommEvent {
			override getLabel() { eventLabel }
			override getID() { eventLabel }
			override isClientToServer() { client2server }
			override isEqual(ICommEvent other) { getID == other.getID }
		}
	}
	
}
