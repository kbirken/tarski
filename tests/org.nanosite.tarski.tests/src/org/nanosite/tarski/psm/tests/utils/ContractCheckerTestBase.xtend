/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests.utils

import java.util.List
import org.nanosite.tarski.psm.checker.ContractCheckResults
import org.nanosite.tarski.psm.checker.ContractCheckResults.ICheckResults
import org.nanosite.tarski.psm.checker.SemanticsChecker
import org.nanosite.tarski.psm.fsmapi.IComponent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.IState
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM.ITransition
import org.nanosite.tarski.psm.fsmapi.IPort
import org.nanosite.tarski.psm.psmapi.IContract
import org.nanosite.tarski.psm.psmapi.IInterface
import org.nanosite.tarski.psm.psmapi.IProtocolSM
import org.nanosite.tarski.psm.viewer.ExecutionFSMDotGenerator

import static org.junit.Assert.*

/**
 * Base class for contract-checker tests.</p>
 */
class ContractCheckerTestBase {
	
	val ExecutionFSMDotGenerator dotgen = new ExecutionFSMDotGenerator
	
	var ContractCheckResults results = null

	def protected createPort(String portName, IInterface api, boolean isProvided) {
		new IPort() {
			override getName() { portName }
			override getInterface() { api }
			override isServer() { isProvided }
		}
	}

	def protected wrap(IProtocolSM psm) {
		new IInterface() {
			override getContract() {
				new IContract() {
					override getPSM() { psm }
				}
			}
		}		
	}
	
	def protected void prepare(IComponent comp, String testname) {
		// create dot-file of input FSM
		writeDotFile(comp, testname + "_Input")

		// run semantics checker on test component
		val checker = new SemanticsChecker(comp)
		results = checker.update
		
		// create dot-file of result FSM
		writeDotFile(comp, testname + "_Results", results)
	}	


	def protected writeDotFile(IComponent comp, String testname) {
		writeDotFile(comp, testname, null)
	}
	
	def protected writeDotFile(IComponent comp, String testname, ContractCheckResults results) {
		val title = comp.name + " / " + testname
		val dot = dotgen.generate(comp.executionFSM, title, results)
		println(dot)
		FileHelper.save("dot-gen/" + comp.name, testname + ".dot", dot.toString)
	}


	
	def protected void check(
		IState s, IPort port,
		List<String> expectedSendProposals,
		List<String> expectedReceiveProposals
	) {
		check(s, port, expectedSendProposals, expectedReceiveProposals, #[])
	}
	
	def protected void check(
		IState s, IPort port,
		List<String> expectedSendProposals,
		List<String> expectedReceiveProposals,
		List<String> expectedInvalidEventWarnings
	) {
		assertNotNull(results)
		
		// get check results for this state
		val checkResults = results.getCheckResults(s)

		// check common part
		checkResults.checkCommon(port,
			expectedSendProposals,
			expectedReceiveProposals,
			expectedInvalidEventWarnings
		)
	}

	def protected void check(
		ITransition t, IPort port,
		boolean expectedDeadTriggerWarning
	) {
		check(t, port, #[], #[], #[], expectedDeadTriggerWarning)
	}

	def protected void check(
		ITransition t, IPort port,
		List<String> expectedSendProposals,
		List<String> expectedReceiveProposals,
		List<String> expectedInvalidEventWarnings,
		boolean expectedDeadTriggerWarning
	) {
		assertNotNull(results)
		
		// get check results for this transition
		val checkResults = results.getCheckResults(t)
		
		// check common part
		checkResults.checkCommon(port,
			expectedSendProposals,
			expectedReceiveProposals,
			expectedInvalidEventWarnings
		)

		// additionally check dead-trigger warning
		if (checkResults!==null) {
			val deadTrigger = checkResults.hasDeadTrigger
			if (expectedDeadTriggerWarning)
				assertTrue("Expected dead-trigger warning at transition " + t, deadTrigger)
			if (! expectedDeadTriggerWarning)
				assertFalse("Invalid dead-trigger warning at transition " + t, deadTrigger)
		}
	}
	
	def private checkCommon(
		ICheckResults checkResults, IPort port,
		List<String> expectedSendProposals,
		List<String> expectedReceiveProposals,
		List<String> expectedInvalidEventWarnings
	) {
		// check send proposals
		val proposedS = checkResults?.proposedSends?.get(port)
		if (proposedS===null) {
			assertEquals("Invalid number of send proposals:",
				expectedSendProposals.size, 0)
		} else {
			assertEquals("Invalid number of send proposals:",
				expectedSendProposals.size, proposedS.size)
			for(exp : expectedSendProposals) {
				assertNotNull(proposedS.findFirst[it.getID==exp])
			}
		}
		
		// check receive proposals
		val proposedR = checkResults?.proposedReceives?.get(port)
		if (proposedR===null) {
			assertEquals("Invalid number of receive proposals:",
				expectedReceiveProposals.size, 0)
		} else {
			assertEquals("Invalid number of receive proposals:",
				expectedReceiveProposals.size, proposedR.size)
			for(exp : expectedReceiveProposals) {
				assertNotNull(proposedR.findFirst[it.getID==exp])
			}
		}
		
		// check invalid-event warnings
		val warningsIE = checkResults?.invalidEventWarnings
		val nWarningsIE = if (warningsIE===null) 0 else warningsIE.size
		assertEquals("Invalid number of invalid-event warnings:",
			expectedInvalidEventWarnings.size, nWarningsIE
		)
		// TODO: implement actual check
//		for(exp : expectedInvalidEventWarnings) {
//			assertNotNull(warnings.findFirst[it.eventID==exp])
//		}		

	}
}
