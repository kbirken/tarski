/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.checker.internal

import com.google.common.collect.Lists
import java.util.List
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IEvent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.ITransition
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IState

/**
 * This class represents the execution semantics of the implementation FSM.
 * 
 * @author Klaus Birken - initial contribution and API
 */
class ExecFSMSemantics {

	static class Step { }

	static class StateStep extends Step {
		val IState state
		
		new (IState state) {
			this.state = state
		}
		
		def getState() {
			state
		}
	}

	static class TransitionStep extends Step {
		val ITransition transition
		
		new (ITransition transition) {
			this.transition = transition
		}
		
		def getTransition() {
			transition
		}
	}

	/**
	 * Get the initial chain of events for a given initial state.
	 */
	def static List<IEvent> getInitialEventChain(IState initial) {
		val List<IEvent> msgList = Lists.newLinkedList

		// just add the entry action for the initial state
		if (initial.entryAction!==null)
			msgList.addAll(initial.entryAction.willSend)

		msgList
	}

	/**
	 * Get the chain of events when a transition is triggered.</p>
	 * 
	 * The method returns an ordered list of pairs, each containing two items:
	 * <ul>
	 * <li>The first element of the pairs and contains the sequence
	 * of consumed and produced events which will be executed until the
	 * target state is reached.</li>
	 * <li>The second element of the pairs contains the execution step for each
	 * of the events. The execution step is an abstraction for
	 * some location in the execution FSM, e.g. a state's entry code or a
	 * transitions trigger.</li>
	 * </ul> 
	 */
	def static List<Pair<IEvent, Step>> getTriggeredEventChain(
		IState source,
		ITransition triggered,
		boolean stopAfterFirstTransition
	) {
			// sanity check
			if (! source.outgoing.contains(triggered))
				throw new RuntimeException("Invalid transition '" + triggered +
					"' for source state '" + source.name + "'")

			// compile event list in the order: trigger -> exit -> action -> entry 
			val List<Pair<IEvent, Step>> msgList = Lists.newLinkedList

			// first the transition trigger
			val handled = triggered.handledMessages
			val trStep = new TransitionStep(triggered)
			for(ev : handled)
				msgList.add(new Pair(ev, trStep))
			
			// now exit action of the source state
			if (source.exitAction!==null) {
				val stateStep = new StateStep(source)
				for(ev : source.exitAction.willSend)
					msgList.add(new Pair(ev, stateStep))
			}
			
			// now action of triggered transition
			if (triggered.action!==null) {
				for(ev : triggered.action.willSend)
					msgList.add(new Pair(ev, trStep))
			}
			
			if (! stopAfterFirstTransition) {
				// finally entry action of target state
				val target = triggered.to
				if (target.entryAction!==null) {
					val stateStep = new StateStep(target)
					for(ev : target.entryAction.willSend)
						msgList.add(new Pair(ev, stateStep))
				}
			}
			
			msgList
	}


	def private static List<IEvent> getHandledMessages(ITransition tr) {
		val List<IEvent> handledMessages = Lists.newArrayList
		if (tr.trigger?.event!==null)
			handledMessages.add(tr.trigger.event)
		handledMessages
	}
	

}
