/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests.utils

import com.google.common.collect.Lists
import java.util.List
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM
import org.nanosite.tarski.psm.fsmapi.IPort
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent

class TestFSM implements IExecutionFSM {
	
	static class State implements IState {
		
		val String name
		val List<ITransition> outgoing = Lists.newArrayList
		
		val List<IEvent> willSendEntry = Lists.newArrayList
		
		new (String name) {
			this.name = name	
		}
		
		override getName() {
			this.name
		}
		
		override getOutgoing() {
			outgoing
		}
		
		override getEntryAction() {
			new IExecutionFSM.IAction {
				override willSend() {
					willSendEntry
				}
				override mightSend() {
					Lists.newArrayList
				}
			}
		}

		override getExitAction() {
			null	
		}

		def addOutgoing(ITransition t) {
			outgoing.add(t)
		}
		
		def addEntryEvent(IPort port, ICommEvent ev /* , boolean mightSend*/ ) {
			willSendEntry.add(new Event(port, ev))
		}
		
		override toString() {
			'''State_«name»'''
		}
	}

	static class Transition implements ITransition {
		val IState to
		val ITrigger trigger
		
		val List<IEvent> willSend = Lists.newArrayList

		new(IState to, ITrigger trigger) {
			this.to = to
			this.trigger = trigger
		}
	
		new(IState to, IPort port, ICommEvent event) {
			this.to = to
			this.trigger = new Trigger(port, event)
		}
	
		override getTo() {
			to
		}
		
		override getTrigger() {
			trigger
		}

		override getAction() {
			new IExecutionFSM.IAction {
				override willSend() {
					willSend
				}
				override mightSend() {
					Lists.newArrayList
				}
			}
		}
		
		def addActionEvent(IPort port, ICommEvent ev /* , boolean mightSend*/ ) {
			willSend.add(new Event(port, ev))
		}

		override toString() {
			if (to!==null)
				'''Tr_to_«to.name»(«trigger»)'''
			else
				'''Tr_ignore(«trigger»)'''
		}
	}
	
	static class Trigger implements ITrigger {
		
		val Event event
		
		new (IPort port, ICommEvent event) {
			this.event = new Event(port, event)
		}
		
		override getEvent() {
			event
		}
	
		override String toString() {
			event.toString
		}
	}
	
	static class Event implements IEvent {
		
		val IPort port
		val ICommEvent event
		
		new (IPort port, ICommEvent event) {
			this.port = port
			this.event = event
		}
		
		override getPort() {
			port
		}
		
		override getInterfaceEvent() {
			event
		}
	
		override String toString() {
			port.name + "." + event.label.replace(' ', '_')
		}
	}
	
	val State initialState
	val List<IState> states = Lists.newArrayList
	
	new(State initialState) {
		this.initialState = initialState
		this.states.add(initialState)
	}

	override getInitial() {
		initialState
	}
	
	override getStates() {
		states
	}
	
	def addState(IState state) {
		states.add(state)
	}
}

