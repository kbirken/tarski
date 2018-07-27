package org.nanosite.tarski.psm.viewer

import java.util.List
import java.util.Map
import java.util.Set
import org.nanosite.tarski.psm.checker.ContractCheckResults
import org.nanosite.tarski.psm.checker.ContractCheckResults.ICheckResults
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IAction
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IEvent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IState
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.ITransition
import org.nanosite.tarski.psm.fsmapi.IPort
import org.nanosite.tarski.psm.psmapi.IProtocolSM.ICommEvent

/**
 * Generate graphical representation of an IExecutionFSM in graphviz/dot format.
 * 
 * @author Klaus Birken - initial contribution and API  
 */
class ExecutionFSMDotGenerator {
	
	var ContractCheckResults results = null
	var int nID = 0
	
	/**
	 * Generate graphical representation of an IExecutionFSM in graphviz/dot format.
	 * 
	 * @param fsm the (execution) FSM
	 * @param title an optional title for the diagram (or null)
	 * @param a configured proposal generator (or null)
	 * @return the generated dot representation as CharSequence 
	 */
	def generate (IExecutionFSM fsm, String title, ContractCheckResults results) {
		this.results = results
		this.nID = 1000
		
		'''
			digraph ExecutionFSM {
				rankdir=LR;
				node [shape=Mrecord,fontsize=10];
				edge [fontsize=9];
				
				«IF title!==null»
					label="«title»"
					
				«ENDIF»
				«FOR s : fsm.states»
					«s.genState»
				«ENDFOR»
				
				I«nID=nID+1» [shape=point]
				I«nID» -> «fsm.initial.id»
				
				«FOR s : fsm.states»
					«FOR tr : s.outgoing»
						«s.id» -> «tr.to.id» [«tr.genTrDetails»]
					«ENDFOR»
					«IF results!==null»
						«s.genProposals»
					«ENDIF»
				«ENDFOR»
				
			}
		'''
	}
	
	def private genState(IState state) {
		val table = new LabelTable
		table.add(state.name, LabelTable.Style.PLAIN)
		val check = results?.getCheckResults(state)
		table.addActions(state, check)
		'''«state.id» [label=«table.generate»]'''
	}
		
	def private genTrDetails (ITransition tr) {
		val res = results?.getCheckResults(tr)
		val isDead = res!==null && res.hasDeadTrigger
		val table = new LabelTable
		val trigger =
			if (tr.trigger!==null)
				tr.trigger.toString
			else
				"???"
		table.add(trigger, if (isDead) LabelTable.Style.ERROR else LabelTable.Style.PLAIN)
		if (tr.action.hasAction)
			table.addAction("", tr.action, res)

		// add send-event proposals
		table.addActions(tr, res)
		
		'''label=«table.generate»
           «IF isDead»«styleError»«ENDIF»
		'''
	}


	def private genProposals (IState state) {
		val res = results?.getCheckResults(state)
		if (res===null)
			return ""
			
		'''
			«FOR port : res.proposedReceives.keySet»
				«FOR ev : res.proposedReceives.get(port)»
					P«nID=nID+1» [shape=point,«styleInfo»]
					«state.id» -> P«nID» [label="«port.name».«ev.ID»",«styleInfo»]
				«ENDFOR»
			«ENDFOR»
		'''	
	}
	
	def private addActions(LabelTable table, IState state, ICheckResults check) {
		if (hasAction(state.entryAction)) {
			table.addAction("1 ", state.entryAction, check)
		}
		if (hasAction(state.exitAction)) {
			table.addAction("2 ", state.exitAction, check)
		}
		if (check!==null && !check.proposedSends.empty) {
			table.add(check.proposedSends)
		}
	}
	
	def private addActions(LabelTable table, ITransition tr, ICheckResults check) {
		if (check!==null && !check.proposedSends.empty) {
			table.add(check.proposedSends)
		}
	}
	
	def private hasAction(IAction action) {
		action!==null && ! (action.mightSend.empty && action.willSend.empty)
	}
	
	def private addAction(LabelTable table, String tag, IAction action, ICheckResults check) {
		if (! action.mightSend.empty) {
			table.addEvents(tag + "&gt;", action.mightSend, check)
		}
		if (! action.willSend.empty) {
			table.addEvents(tag + "&gt;&gt;", action.willSend, check)
		}
	}

	def private addEvents(LabelTable table, String tag, List<IEvent> events, ICheckResults check) {
		val invalid = check?.invalidEventWarnings?.values?.toSet
		for(ev : events) {
			val style =
				if (invalid!==null && invalid.contains(ev))
					LabelTable.Style.ERROR
				else
					LabelTable.Style.PLAIN
			table.add(tag, ev.toString, style)
		}
	}
	
	def private add(LabelTable table, Map<IPort, Set<ICommEvent>> proposedSends) {
		for(p : proposedSends.keySet) {
			for(ev : proposedSends.get(p)) {
				table.add("*", p.name + "." + ev.ID, LabelTable.Style.PLAIN)
			}
		}
	}

	def private getId (IState state) {
		'_' + state.name.toUpperCase.replace(' ', '_')
	}

	def private styleInfo() '''color="blue",fontcolor="blue"'''

	def private styleError() '''color="red"'''
}
