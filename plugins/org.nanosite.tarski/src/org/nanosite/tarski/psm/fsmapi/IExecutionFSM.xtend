/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.fsmapi

import java.util.List
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent

/**
 * The abstraction of an execution finite-state machine (FSM) as used by
 * the Tarski SemanticsChecker.</p>
 * 
 * This is the state chart which implements a component. The state chart interacts
 * with the outside world by exchanging events being sent or received via
 * the component's ports.</p>
 * 
 * @see IPort
 * @see IComponent
 * 
 * @author Klaus Birken (initial contribution)  
 */
interface IExecutionFSM {

	/**
	 * The abstraction of a state in the execution finite-state machine.
	 * 
	 * Currently, we do not support nested states.
	 */
	interface IState {
		/**
		 * Get the unique name of the state.
		 */
		def String getName()
		
		/**
		 * Get all outgoing transitions of the state. 
		 */
		def List<ITransition> getOutgoing()
		
		/**
		 * Get information about the action which is executed when the state is entered.
		 */
		def IAction getEntryAction()

		/**
		 * Get information about the action which is executed when the state is exited.
		 */
		def IAction getExitAction()
	}

	/**
	 * The abstraction of a transition in the execution finite-state machine.</p>
	 * 
	 * We do not model the source state for this transition, as this information is
	 * already modeled in the source state (see IState.getOutgoing).</p>
	 * 
	 * TODO: Lateron, we will add the notion of "guards" here.
	 */
	interface ITransition {
		/**
		 * Get information on how the transition is triggered.
		 * 
		 * @return the actual trigger or null if trigger is unknown
		 */
		def ITrigger getTrigger()
		
		/**
		 * The target state of this transition.
		 */
		def IState getTo()

		/**
		 * Get information about the action which is executed when the transition fires.
		 */
		def IAction getAction()
	}

	/**
	 * The abstraction of a transition trigger.</p>
	 * 
	 * Currently, a trigger is modeled as exactly one actual event. 
	 */
	interface ITrigger {
		/**
		 * Get the event for this trigger.
		 */
		def IEvent getEvent()
		
		/**
		 * Get a string representation of the trigger.
		 */
		override String toString()
	}
		
	/**
	 * The abstraction of an actual event being send or received through a port.</p>
	 */
	interface IEvent {
		/**
		 * Get the port which will transport the event.
		 */
		def IPort getPort()
		
		/**
		 * Get the interface-related event which is being sent or received.</p>
		 * 
		 * Note: This is actually a class which is used by the contracts model.
		 */
		def ICommEvent getInterfaceEvent()
		
		/**
		 * Get a string representation of the event.
		 */
		override String toString()
	}
	
	/**
	 * The abstraction of some action happening while the state machine is executed.</p>
	 * 
	 * There are three types of actions:
	 * <ul>
	 * <li>the action being executed when a transition fires</li>
	 * <li>the action being executed when a state is entered</li>
	 * <li>the action being executed when a state is left</li>
	 * </ul>
	 */
	interface IAction {
		/**
		 * Retrieve a list of events which will be sent when the action is executed.
		 * 
		 * For the events in this list, it is clear that they will be sent each time when
		 * the action is executed.
		 */
		def List<IEvent> willSend()

		/**
		 * Retrieve a list of events which <em>might</em> be sent when the action is executed.
		 * 
		 * For the events in this list, it depends on the current state of the component if they
		 * actually will be send or not.  
		 */
		def List<IEvent> mightSend()
	}

	/**
	 * Get the initial state for this finite-state machine.
	 */
	def IState getInitial()

	/**
	 * Get a list of all states of this finite-state machine.
	 * 
	 * The initial state must be included here.
	 */
	def List<IState> getStates()
}
