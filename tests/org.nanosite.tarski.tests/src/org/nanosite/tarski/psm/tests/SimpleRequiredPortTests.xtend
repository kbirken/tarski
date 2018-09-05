/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests

import org.junit.Before
import org.junit.Test
import org.nanosite.tarski.psm.fsmapi.IPort
import org.nanosite.tarski.psm.tests.utils.ContractCheckerTestBase
import org.nanosite.tarski.psm.tests.utils.TestComponent
import org.nanosite.tarski.psm.tests.utils.TestFSM

class SimpleRequiredPortTests extends ContractCheckerTestBase {

	val FrancaSimplePSM psm = new FrancaSimplePSM

	var TestComponent comp = null
	var IPort port1 = null 

	val start = new TestFSM.State("start")
	val ready = new TestFSM.State("ready")

	@Before
	def void init() {
		// create a port (client requires an interface)
		port1 = createPort("port1", psm.wrap, false)
		
		// build a test implementation FSM and component 
		val fsm = new TestFSM(start)
		fsm.addState(ready)
		comp = new TestComponent("SimpleClient1", port1, fsm)
	}


	@Test
	def testClientNoMethodCall() {
		prepare(comp, "NoMethodCall")
		start.check(port1, #["call_m1"], #[])
	}

	@Test
	def testClientOneMethodCall() {
		start.addEntryEvent(port1, psm.call_m1)
		
		prepare(comp, "OneMethodCall")
		start.check(port1, #[], #["respond_m1"])
	}

	@Test
	def testClientOneMethodHandshake1() {
		start.addEntryEvent(port1, psm.call_m1)
		val tr1 = new TestFSM.Transition(ready, port1, psm.respond_m1)
		start.addOutgoing(tr1)

		prepare(comp, "OneMethodHandshake1")
		start.check(port1, #[], #[])
		ready.check(port1, #["set_a"], #["update_a", "signal_b"])
	}

}
