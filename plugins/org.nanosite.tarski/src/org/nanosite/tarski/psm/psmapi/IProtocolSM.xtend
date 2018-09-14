/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.psmapi

import java.util.Collection
import java.util.List

/**
 * The abstraction of a protocol finite-state machine (PSM) as used by
 * the Tarski SemanticsChecker.</p>
 * 
 * @author Klaus Birken (initial contribution)  
 */
interface IProtocolSM {

	/**
	 * The abstraction of a state in the execution finite-state machine.
	 * 
	 * Currently, we do not support nested states.
	 */
	interface IPSMState {
		/**
		 * Get the unique name of the state.
		 */
		def String getName()
		
		/**
		 * Get all outgoing transitions of the state. 
		 */
		def List<IPSMTransition> getOutgoing()
		
//		/**
//		 * Get information about the action which is executed when the state is entered.
//		 */
//		def IAction getEntryAction()
//
//		/**
//		 * Get information about the action which is executed when the state is exited.
//		 */
//		def IAction getExitAction()
	}

	/**
	 * The abstraction of a transition in the protocol state machine.</p>
	 * 
	 * We do not model the source state for this transition, as this information is
	 * already modeled in the source state (see IState.getOutgoing).</p>
	 * 
	 * TODO: Lateron, we will add the notion of "guards" here.
	 */
	interface IPSMTransition {
		/**
		 * Get information on how the transition is triggered.
		 * 
		 * @return the actual trigger or null if trigger is unknown
		 */
		def IPSMTrigger getTrigger()
		
		/**
		 * The target state of this transition.
		 */
		def IPSMState getTo()

		/**
		 * Get information about the action which is executed when the transition fires.
		 */
		def IPSMAction getAction()
	}

	/**
	 * The abstraction of a transition trigger.</p>
	 * 
	 * Currently, a trigger is modeled as exactly one actual event. 
	 */
	interface IPSMTrigger {
		/**
		 * Get the event for this trigger.
		 */
		def ICommEvent getEvent()
		
		/**
		 * Get a string representation of the trigger.
		 */
		override String toString()
	}
		
	/**
	 * The abstraction of an actual event being send or received through a port.</p>
	 */
	interface ICommEvent {
		
		def String getLabel()
		
		def String getID()
		
		/**
		 * Get the Franca event which is being sent or received.</p>
		 * 
		 * Note: This is actually a class which is used by the Franca contracts model.
		 */
//		def FEventOnIf getFrancaEvent()

		def boolean isClientToServer()
		
		def boolean isEqual(ICommEvent other)
		
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
	interface IPSMAction {
		/**
		 * Retrieve a list of events which will be sent when the action is executed.
		 * 
		 * For the events in this list, it is clear that they will be sent each time when
		 * the action is executed.
		 */
		def List<ICommEvent> willSend()

		/**
		 * Retrieve a list of events which <em>might</em> be sent when the action is executed.
		 * 
		 * For the events in this list, it depends on the current state of the component if they
		 * actually will be send or not.  
		 */
		def List<ICommEvent> mightSend()
	}

	/**
	 * Get the initial state for this finite-state machine.
	 */
	def IPSMState getInitial()

	/**
	 * Get a list of all states of this finite-state machine.
	 * 
	 * The initial state must be included here.
	 */
	def Collection<IPSMState> getStates()
}
