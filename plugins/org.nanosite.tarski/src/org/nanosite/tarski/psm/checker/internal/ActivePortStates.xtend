package org.nanosite.tarski.psm.checker.internal

import com.google.common.collect.Maps
import java.util.List
import java.util.Map
import java.util.Set
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IEvent
import org.nanosite.tarski.psm.fsmapi.IPort

/**
 * This class represents the overall state of a component's connections.</p>
 *
 * For each of the component's ports, this overall state is defined by the
 * current state of the interface contract of this port. For each 
 * interface contract, one or more actual states of the protocol state machine
 * are stored.</p>
 * 
 * This class will be instantiated for every state of the execution FSM and
 * is updated during the SemanticsChecker computation.
 * 
 * @author Klaus Birken - initial contribution and API
 */
class ActivePortStates {

	//val final static traceProposals = true
	
	var Map<IPort, AbstractConnectionState> portStates

	new() {
		this.portStates = Maps.newLinkedHashMap
	}
	
	private new (Map<IPort, AbstractConnectionState> rules) {
		this.portStates = rules
	}
	
	def Set<IPort> getPorts() {
		portStates.keySet
	}

	def AbstractConnectionState getAbstractConnectionState(IPort port) {
		return portStates.get(port)
	}
		

	/**
	 * Consume a linear list of events.
	 * 
	 * @param eventSeq the event sequence to be consumed
	 * @param abortOnUnexpected if false, we will continue even if an event cannot be consumed
	 * @return -1 if all events could be consumed, otherwise we return the index
	 *         of the first unexpected event 
	 */	
	def int consumeEvents(List<IEvent> eventSeq, boolean abortOnUnexpected) {
		var idx = 0
		var ret = -1
		for(ev : eventSeq) {
			// does this event belong to a port with an interface contract?
			if (portStates.containsKey(ev.port)) {
				// compute a new abstract connection state by consuming the event on this port 
				val current = portStates.get(ev.port)
				
				// never ignore triggering event (which has idx 0)
				val ignoreNotAcceptedEvents = idx>0 && !abortOnUnexpected
				val updated = current.acceptEvent(ev.interfaceEvent, ignoreNotAcceptedEvents)
				
				// replace the old abstract state by the updated one 
				portStates.put(ev.port, updated)
				
				// check if abstract state is still valid
				if (! updated.isValid) {
					// none of the port states accepts the event
					// if this is not the triggering event (idx==0), we may abort here
					if (abortOnUnexpected && idx>0) {
						return idx
					} else {
						ret = idx
					}
				}
			} else {
				// no states available for the port of the current event
				if (ev.port.interface.contract!==null) {
					if (abortOnUnexpected) {
						return idx
					} else {
						ret = idx
					}
				} else {
					// the interface for this port doesn't have a contract
					// => all events have to be regarded as valid
				}
			}
			idx = idx + 1
		}
		return ret
	}


	def void buildInitLocalRules(List<IPort> ports) {
		for(port : ports) {
			// add initial abstract state for this port if interface has a contract
			val contract = port.interface.contract
			if (contract!==null) {
				portStates.put(port, new AbstractConnectionState(contract))
			}
		}
	}
	

	/**
	 * Merge another ActivePortStates object into the current one.
	 * 
	 * @param other another set of active port states
	 * @return true if the current object has been changed due to the merge, false otherwise
	 */
	def boolean merge(ActivePortStates other) {
		var addedAtLeastOnce = false
		for(op : other.ports) {
			val otherState = other.portStates.get(op)
			if (otherState.isValid) {
				// only merge with valid abstract states
				if (portStates.containsKey(op)) {
					val merged = portStates.get(op).mergeWith(otherState)
					if (merged!==null) {
						portStates.put(op, merged)
						addedAtLeastOnce = true
					}
				} else {
					// we do not have an entry for the other's port, just use it
					portStates.put(op, otherState) 
					addedAtLeastOnce = true
				}
			}
		}
		
		addedAtLeastOnce
	}
	
	def ActivePortStates createCopy() {
		val Map<IPort, AbstractConnectionState> newRules = Maps.newLinkedHashMap
		for(port : portStates.keySet) {
			newRules.put(port, portStates.get(port))
		}
		new ActivePortStates(newRules)
	}
	
	
	override String toString() {
		val sb = new StringBuilder
		sb.append("[")
		for(p : portStates.keySet) {
			sb.append(p.name + ":" + portStates.get(p))
		}
		sb.append("]")
		sb.toString
	}
	
}
		