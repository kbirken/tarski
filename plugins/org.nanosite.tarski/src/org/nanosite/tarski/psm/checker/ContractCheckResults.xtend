/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.checker

import com.google.common.collect.Maps
import java.util.Map
import java.util.Set
import org.nanosite.tarski.psm.checker.internal.ExecFSMSemantics.StateStep
import org.nanosite.tarski.psm.checker.internal.ExecFSMSemantics.TransitionStep
import org.nanosite.tarski.psm.fsmapi.IComponent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IEvent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IState
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.ITransition
import org.nanosite.tarski.psm.fsmapi.IPort
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent

import static extension org.nanosite.tarski.psm.checker.internal.ExecFSMSemantics.*

/**
 * This class uses the results from a SemanticsChecker run and computes 
 * proposals and warnings which can be used by a state-chart editor tool.
 * 
 * @see SemanticsChecker
 * 
 * @author Klaus Birken - initial contribution and API  
 */
class ContractCheckResults {
	
	val final static traceProposals = true
	
	val IComponent component
	val SemanticsChecker checker

	static interface ICheckResults {
		/**
		 * Get all send proposals for this statechart model entity.</p>
		 * 
		 * <em>Send proposals</em> are all events which could be send from the current
		 * state according to the current FSM implementation of the component and all
		 * contracts of the interfaces at the component's ports. 
		 * Send proposals might lead to the addition of some action code (i.e., entry/exit
		 * actions of states or firing action of a transition) which sends the event
		 * proposed here.
		 */
		def Map<IPort, Set<ICommEvent>> getProposedSends()
	
		/**
		 * Get all receive proposals for this statechart model entity.</p>
		 * 
		 * <em>Receive proposals</em> are all events which should be expected in the current
		 * state according to the current FSM implementation of the component and all
		 * contracts of the interfaces at the component's ports.<p>
		 * 
		 * Receive proposals might lead to the addition of a new transition
		 * in the implementation FSM by the designer of the component's implementation.</p>
		 * 
		 * In some development contexts, it might be useful to regard these proposals as warnings.</p>   
		 */
		def Map<IPort, Set<ICommEvent>> getProposedReceives()
		
		/**
		 * Get all invalid-event warnings for this statechart model entity.</p>
		 * 
		 * <em>Invalid-event</em> warnings indicate that some event cannot be consumed or
		 * sent due to restrictions by the port contracts.
		 */
		def Map<ITransition, IEvent> getInvalidEventWarnings()
	}

	static private class CheckResults implements ICheckResults {
		val Map<IPort, Set<ICommEvent>> proposedSends = Maps.newHashMap
		val Map<IPort, Set<ICommEvent>> proposedReceives = Maps.newHashMap
		val Map<ITransition, IEvent> warningInvalidEvent = Maps.newHashMap

		override getProposedSends() {
			proposedSends
		}
		
		override getProposedReceives() {
			proposedReceives
		}

		override getInvalidEventWarnings() {
			warningInvalidEvent
		}
		
		def addProposedSend(IPort port, ICommEvent ev) {
			if (! proposedSends.containsKey(port)) {
				proposedSends.put(port, newHashSet)
			}
			proposedSends.get(port).add(ev)
		}

		def addProposedReceive(IPort port, ICommEvent ev) {
			if (! proposedReceives.containsKey(port)) {
				proposedReceives.put(port, newHashSet)
			}
			proposedReceives.get(port).add(ev)
		}

		def addInvalidEvent(ITransition tr, IEvent ev) {
			warningInvalidEvent.put(tr, ev)
		}
	}
	
	/**
	 * Results of the contract checker for a state of the execution state machine.
	 */
	static interface IStateCheckResults extends ICheckResults { }
	
	static private class StateCheckResults extends CheckResults implements IStateCheckResults { }

	/**
	 * Results of the contract checker for a transition of the execution state machine.
	 */
	static interface ITransitionCheckResults extends ICheckResults {
		/**
		 * Check if the transition has a dead trigger.</p>
		 * 
		 * <em>Dead-trigger</em> warnings indicate that the trigger will never fire due to
		 * restrictions by the port contracts.
		 */
		def boolean hasDeadTrigger()
	}

	static private class TransitionCheckResults extends CheckResults implements ITransitionCheckResults {
		var boolean warningDeadTrigger = false
		
		new () {
		}

		override hasDeadTrigger() {
			warningDeadTrigger
		}
		
		def setDeadTrigger() {
			this.warningDeadTrigger = true			
		}
	}


	val Map<IState, StateCheckResults> stateResults = Maps.newHashMap
	val Map<ITransition, TransitionCheckResults> transitionResults = Maps.newHashMap


	/**
	 * Get results of contract checker for a given state of the execution state machine.
	 */
	def IStateCheckResults getCheckResults(IState state) {
		stateResults.get(state)
	}
	
	/**
	 * Get results of contract checker for a given transition of the execution state machine.
	 */
	def ITransitionCheckResults getCheckResults(ITransition transition) {
		transitionResults.get(transition)
	}
	


	/**
	 * Create a ProposalGenerator object from a given (abstract) component
	 * and a SemanticsChecker. 
	 */
	new (IComponent component, SemanticsChecker checker) {
		this.component = component
		this.checker = checker
	}
	
	/**
	 * Compute the proposals of the contract checker for a component's execution FSM.</p>
	 * 
	 * Note: It is a necessary precondition that the checker already ran on the input component.</p>
	 * 
	 * After calling this method, use getCheckerResults() to get the actual results
	 * for states and transitions.</p>
	 * 
	 * @return true if proposals could be computed, false otherwise (e.g., if the checker hasn't been run before)
	 */
	def boolean computeProposals() {
		stateResults.clear
		transitionResults.clear

		// start computation for each state in turn
		// Note: starting at one state might produce results for another state
		for(s : component.executionFSM.states) {
			if (! s.computeResults)
				return false
		}
		
		true
	}
	
	/**
	 * This helper method computes all the warnings and proposals for one state
	 * and all transition chains starting from that state.
	 * 
	 * Note that due to following transition chains proposals and warnings might 
	 * result also in successor states.
	 */
	def private computeResults (IState state) {
		val localPortStates = checker.getActivePortStates(state)
		if (localPortStates===null) {
			// no information for this state: the state is not reachable
			return true
		}
		
		// determine active triggers of this state
		// (currently these are only the triggers of the outgoing transitions)
		// we ignore all transitions with unknown triggers
		val validOutgoingTransitions = state.outgoing.filter[trigger?.event!==null]

		// determine events sent by this state (entry or exit action)
		val Set<ICommEvent> sentEvents = newHashSet
		if (state.entryAction!==null)
			sentEvents.addAll(state.entryAction.willSend.map[interfaceEvent])
		if (state.exitAction!==null)
			sentEvents.addAll(state.exitAction.willSend.map[interfaceEvent])
		
		if (traceProposals) {
			println("Computing results for state " + state.name + " -- " + localPortStates)
		}
		
		// compute proposals for this state
		for(p : localPortStates.ports) {
			val abstractConnState = localPortStates.getAbstractConnectionState(p)
			for(connState : abstractConnState.states) {
				// get all active transitions triggered by an event from the current port p
				val activeTransitions = validOutgoingTransitions.filter[trigger.event.port==p]
				
				// find all outgoing PSM transitions which are not yet matched by
				// some active input event from this port
				val triggeringEvents = activeTransitions.map[trigger.event.interfaceEvent]
				val unmatched = connState.getUnmatched(triggeringEvents)
				for(u : unmatched) {
					val ev = u.trigger.event
					
					// determine if this event is send or received
					// (depends on the port direction and the event type)
					val isSendProposal = ev.isClientToServer != p.isServer
					
					// store proposal for later consumption
					if (isSendProposal) {
						if (sentEvents.containsEvent(ev)) {
							// this event is actually sent in the state's entry or exit code, don't propose it
						} else {
							state.results.addProposedSend(p, ev)
						}
					} else {
						state.results.addProposedReceive(p, ev)
					}
					
					if (traceProposals) {
						val op = if (isSendProposal) "send" else "receive"
						println("  proposal: " + op + " " + ev.ID)
					}
				}
			}
		}
		
		// compute warnings for this state according to outgoing transitions
		for(tr : validOutgoingTransitions) {
			// check if all events along the triggered event chain are valid  			
			val eventSeq = state.getTriggeredEventChain(tr, false)
			val tempPortStates = localPortStates.createCopy
			val invalid = tempPortStates.consumeEvents(eventSeq.map[key], true)
			if (invalid<0) {
				// all events in the sequence could be consumed properly
				// do nothing
			} else {
				// (at least) one of the events couldn't be consumed
				val invalidItem = eventSeq.get(invalid)
				val evInvalid = invalidItem.key
				val step = invalidItem.value
				
				if (invalid==0) {
					// the first entry in the event chain is always the trigger
					if (step instanceof TransitionStep) {
						step.transition.results.setDeadTrigger
					} 
					if (traceProposals) {
						println("  warning: dead trigger " + evInvalid)
					}
				} else {
					// the second and all following events in the chain are not triggers
					switch (step) {
						StateStep: step.state.results.addInvalidEvent(tr, evInvalid)
						TransitionStep: step.transition.results.addInvalidEvent(tr, evInvalid)
					}
					if (traceProposals) {
						println("  warning: invalid event " + evInvalid +
							" (when " + tr.trigger + " is fired)"
						)
					}
				}
			}
			
			// check send proposals for the action code of outgoing transitions
			val localPortStatesTr = checker.getActivePortStates(tr)
			for(p : localPortStatesTr.ports) {
				val abstractConnState = localPortStatesTr.getAbstractConnectionState(p)
				for(connState : abstractConnState.states) {
					for(outg : connState.outgoing) {
						val ev = outg.trigger.event
						
						// determine if this event is send or received
						// (depends on the port direction and the event type)
						val isSendProposal = ev.isClientToServer != p.isServer
						
						// store proposal for later consumption
						if (isSendProposal) {
							tr.results.addProposedSend(p, ev)
							if (traceProposals) {
								println("  tr proposal: send " + ev.ID)
							}
						}
					}
				}
			}
			
			// TODO check invalid entry events for initial states 
		}

		true
	}
	
	def private getResults(IState state) {
		if (! stateResults.containsKey(state)) {
			// create on the fly
			stateResults.put(state, new StateCheckResults)
		}
		stateResults.get(state)
	}
	
	def private getResults(ITransition transition) {
		if (! transitionResults.containsKey(transition)) {
			// create on the fly
			transitionResults.put(transition, new TransitionCheckResults)
		}
		transitionResults.get(transition)
	}
	
	// TODO: this doesn't scale for large collections
	def private static containsEvent(Iterable<ICommEvent> events, ICommEvent event) {
		for(ev : events) {
			if (ev.isEqual(event))
				return true
		}
		false
	} 
	
}
