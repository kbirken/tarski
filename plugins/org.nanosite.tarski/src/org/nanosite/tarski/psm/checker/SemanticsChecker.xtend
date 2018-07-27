package org.nanosite.tarski.psm.checker

import com.google.common.collect.Lists
import com.google.common.collect.Maps
import com.google.common.collect.Sets
import java.util.Map
import java.util.Queue
import java.util.Set
import org.nanosite.tarski.psm.checker.internal.ActivePortStates
import org.nanosite.tarski.psm.fsmapi.IComponent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IState
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.ITransition

import static extension org.nanosite.tarski.psm.checker.internal.ExecFSMSemantics.*

/**
 * Check the current implementation statechart of a component against
 * the contracts of the interface definitions of all the component's ports.
 * 
 * @author Klaus Birken - initial contribution and API  
 */
class SemanticsChecker {
	
	val IComponent component
	
	val Queue<IState> queue = Lists.newLinkedList
	val Set<IState> visited = Sets.newHashSet
	
	val Map<IState, ActivePortStates> activePortStates = Maps.newLinkedHashMap

	/**
	 * This represents the ActivePortStates for a given transition, after the
	 * transition has fired and its action code has been executed.
	 */
	val Map<ITransition, ActivePortStates> activePortStatesTr = Maps.newLinkedHashMap
	
	/**
	 * Initialize the semantics checker for a given component.
	 */
	new (IComponent component) {
		println("\nSemanticsChecker constructor for component " + component.name)
		this.component = component	
	}
	
	/**
	 * Run the actual checking algorithm.</p>
	 * 
	 * This should be called again after the comonent's structure (e.g., its ports) or
	 * the execution FSM has been changed.
	 * 
	 * @return a check result object, or null if there are no ports with contract at all
	 */
	def ContractCheckResults update() {
		// clear previous state
		queue.clear
		visited.clear
		activePortStates.clear
		activePortStatesTr.clear
				
		// if no port of this component has a contract, we simply skip the computation
		val hasPortWithContract = component.ports.filter[^interface.contract!==null].size > 0
		if (!hasPortWithContract)
			return null

		// build initial local rules for all ports
		val localPortStates = new ActivePortStates
		localPortStates.buildInitLocalRules(component.ports)
		
		// compute starting points for the traversal
		val fsm = component.executionFSM
		addStartingPoints(fsm, localPortStates)
		
		// do actual traversal until a fixpoint is reached
		doTraversal
		
		// now compute actual proposals and warnings
		val results = new ContractCheckResults(component, this)
		if (results.computeProposals)
			results
		else 
			null
	}

	def Iterable<IState> getVisitedStates() {
		activePortStates.keySet
	}

	def private void doTraversal() {
		while (! queue.empty) {
			visit(queue.poll)
		}
	}
	
	def private void visit(IState state) {
		println("traversal: visit " + state.name)
		visited.add(state)

		// TODO: Subgraphs have to be handled, too
		
		/*
		 * For each transition
		 * 1. Add messages handled on the transition to message list.
		 *    Messages are handled on actual transition -> entry -> do -> exit
		 * 2. Get a copy of the rule of the present node and check it with the message list
		 * 3. Add and merge rules on target node with the present rule
		 */
		for(tr : state.outgoing) {
			val target = tr.to
			val trigger = if (tr.trigger!==null) tr.trigger.toString else "unknown trigger"
			println("  transition to '" + target.name + "' (" + trigger + ")")

			val tempRule = activePortStates.get(state).createCopy
			val tempRuleTr = activePortStates.get(state).createCopy

			// update ActivePortState of target state
			val eventSeq = state.getTriggeredEventChain(tr, false).map[key]
			println("    eventSeq: " + eventSeq.map[it.toString].join(', '))
			println("      rule pre:  " + tempRule)
			tempRule.consumeEvents(eventSeq, false)
			println("      rule post: " + tempRule)
			addAndMergePortStates(target, tempRule)
			println("      final rule of '" + state.name + "': " + activePortStates.get(state))

			// update ActivePortState of triggered transition
			val eventSeqTr = state.getTriggeredEventChain(tr, true).map[key]
			println("    eventSeqTr: " + eventSeqTr.map[it.toString].join(', '))
			println("      rule pre:  " + tempRuleTr)
			tempRuleTr.consumeEvents(eventSeq, false)
			println("      rule post: " + tempRuleTr)
			addAndMergePortStates(tr, tempRuleTr)
			println("      final rule of '" + tr + "': " + activePortStatesTr.get(tr))
		}
	}
	
	def private void addStartingPoints(IExecutionFSM graph, ActivePortStates localRules) {
		// get initial state
		val initial = graph.initial

		// consume entry messages of initial state
		val eventSeq = initial.getInitialEventChain
		val tempRule = localRules.createCopy
		tempRule.consumeEvents(eventSeq, false)
		addAndMergePortStates(initial, tempRule)
	}

//						/* 
//						 * In SCT, outgoing Transitions from Entries cannot have a Trigger.
//						 * We only need to check for the Entry of the initial state
//						 */
//						List<HandledMessage> msgList = getHandledMessagesOnEntry(cur);
//						List<HandledMessage> wrongMsgList = localRules.consumeMessages(msgList, mappingService);
//						
//						/*
//						 * TODO: Add wrong messages to warnings
//						 */
//						
//						boolean rulesChanged = false;
//						if (mapToRules.containsKey(cur)) {
//							rulesChanged = mapToRules.get(cur).merge(localRules);
//						} else {
//							mapToRules.put(cur, localRules);
//							rulesChanged = true;
//						}
//						if (!visited.contains(cur) || rulesChanged) {
//							queue.add(cur);
//						}
//						
//						break;
//
//					}
//				}
//			}


	
	
//	/**
//	 * Retrieve the message handled. 
//	 * 
//	 * @param vertex
//	 * @return
//	 */
//	private List<HandledMessage> getHandledMessages(Vertex vertex, Class clazz) {
//		
//		List<HandledMessage> handledMessages = new ArrayList<HandledMessage>();
//		
//		if (vertex instanceof State) {
//			for(Scope scope : ((State) vertex).getScopes()) {
//				
////				if (scope instanceof SimpleScope) {
////					
////				}
//				
////				else if (scope instanceof InterfaceScope) {
//					for(Declaration declaration : scope.getDeclarations()) {
//						if (declaration instanceof LocalReaction) {
//							Trigger decTrigger = ((LocalReaction) declaration).getTrigger();
//							EList<EventSpec> triggers = ((ReactionTrigger) decTrigger).getTriggers();
//							Effect effect = ((LocalReaction) declaration).getEffect();
//							if (effect instanceof ReactionEffect) {
//								for (Expression expression : ((ReactionEffect) effect).getActions()) {
//									if (expression instanceof EventRaisingExpression) {
//										for (EventSpec trigger : triggers) {
//											if (clazz.isInstance(trigger)) {
//												Expression event = ((EventRaisingExpression) expression).getEvent();
//												handledMessages.addAll(getHandledMessages(event));
//											}
////											if (trigger instanceof EntryEvent) {
////												
////											} else if (trigger instanceof AlwaysEvent) {
////												
////											} else if (trigger instanceof ExitEvent) {
////												
////											}
//										}
//
//									}
//								}
//							}
//						}
//					}
////				}
//
//			}
//
//		}
//		
//		return handledMessages;
//	}
	
//	private List<HandledMessage> getHandledMessages(Expression event){
//		
//		List<HandledMessage> handledMessages = new ArrayList<HandledMessage>();
//		
//		if (event instanceof FeatureCall) {
//
//			EObject feature = ((FeatureCall) event).getFeature();
//			if (feature instanceof EventDefinition) {
//				
//				HandledMessage handledMessage = new HandledMessage((InterfaceScope) feature.eContainer(), (EventDefinition) feature);
//				handledMessages.add(handledMessage);
//
//			} else if (feature instanceof VariableDefinition) {
//				/*
//				 * TODO: Fill variable definitions
//				 */
//			} else if (feature instanceof OperationDefinition) {
//				/*
//				 * TODO: Fill operation definitions
//				 */
//			}
//		}
//		
//		return handledMessages;
//		
//	}
	
	def private void addAndMergePortStates(IState target, ActivePortStates tempRule)	{
		var boolean rulesChanged = false
		if (activePortStates.containsKey(target)) {
//			println("   before merge of '" + target.name + "': " + mapToRules.get(target))
			rulesChanged = activePortStates.get(target).merge(tempRule)
			println("    merged to '" + target.name + "': " + activePortStates.get(target))
		} else {
			println("    initially set '" + target.name + "' to: " + tempRule)
			activePortStates.put(target, tempRule)
			rulesChanged = true
		}
		
		if (!visited.contains(target) || rulesChanged) {
			queue.add(target);
		}
	}
	
	def private void addAndMergePortStates(ITransition triggered, ActivePortStates tempRule)	{
		if (activePortStatesTr.containsKey(triggered)) {
//			println("   before merge of '" + target.name + "': " + mapToRules.get(target))
			activePortStatesTr.get(triggered).merge(tempRule)
			println("    merged to '" + triggered + "': " + activePortStatesTr.get(triggered))
		} else {
			println("    initially set '" + triggered + "' to: " + tempRule)
			activePortStatesTr.put(triggered, tempRule)
		}
	}
	
	def getActivePortStates(IState state) {
		if (activePortStates.containsKey(state))
			activePortStates.get(state)
		else
			null
	}

	def getActivePortStates(ITransition tr) {
		if (activePortStatesTr.containsKey(tr))
			activePortStatesTr.get(tr)
		else
			null
	}

}
