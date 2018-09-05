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

class SimpleProvidedPortTests extends ContractCheckerTestBase {
	
	val FrancaSimplePSM psm = new FrancaSimplePSM

	var TestComponent comp = null
	var IPort port1 = null 

	val idle = new TestFSM.State("idle")
	val busy = new TestFSM.State("busy")

	@Before
	def void init() {
		// create a port (server provides an interface)
		port1 = createPort("port1", psm.wrap, true)
		
		// build a test implementation FSM and component 
		val fsm = new TestFSM(idle)
		fsm.addState(busy)
		comp = new TestComponent("SimpleServer1", port1, fsm)
	}

	@Test
	def void testServerNoMethodCall() {
		prepare(comp, "NoMethodCall")
		idle.check(port1, #[], #["call_m1"])
	}

	@Test
	def testServerInvalidSet() {
		// event "set_a" is not allowed in idle state
		val tr1 = new TestFSM.Transition(busy, port1, psm.set_a)
		idle.addOutgoing(tr1)

		prepare(comp, "InvalidSet")
		idle.check(port1, #[], #["call_m1"])
		tr1.check(port1, true)
		busy.check(port1, #[], #[])
	}

	@Test
	def testServerOneMethodCall() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		idle.addOutgoing(tr1)

		prepare(comp, "OneMethodCall")
		idle.check(port1, #[], #[])
		busy.check(port1, #["respond_m1"], #[])
	}

	@Test
	def testServerOneMethodHandshake1() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		tr1.addActionEvent(port1, psm.respond_m1)
		idle.addOutgoing(tr1)

		prepare(comp, "OneMethodHandshake1")
		idle.check(port1, #[], #[])
		busy.check(port1, #["update_a", "signal_b"], #["set_a"])
	}

	@Test
	def testServerOneMethodHandshake2() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		idle.addOutgoing(tr1)
		busy.addEntryEvent(port1, psm.respond_m1)

		prepare(comp, "OneMethodHandshake2")
		idle.check(port1, #[], #[])
		busy.check(port1, #["update_a", "signal_b"], #["set_a"])
	}

	@Test
	def testServerOneMethodInvalidAction() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		
		// add invalid event to transition action
		tr1.addActionEvent(port1, psm.signal_b)
		idle.addOutgoing(tr1)

		prepare(comp, "OneMethodInvalidAction")
		idle.check(port1, #[], #[])
		tr1.check(port1, #["respond_m1"], #[], #["signal_b"], false)
		busy.check(port1, #["respond_m1"], #[])
	}

	@Test
	def testServerMethodAndSignal() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		tr1.addActionEvent(port1, psm.respond_m1)
		idle.addOutgoing(tr1)

		// send signalB in entry action of 'busy' state
		busy.addEntryEvent(port1, psm.signal_b)

		prepare(comp, "MethodAndSignal")
		idle.check(port1, #[], #[])
		busy.check(port1, #["update_a"], #["set_a"])
	}

	@Test
	def testServerMethodAndInvalidSignal() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		tr1.addActionEvent(port1, psm.respond_m1)
		idle.addOutgoing(tr1)

		// send (invalid) updateU in entry action of 'busy' state
		busy.addEntryEvent(port1, psm.update_u)

		prepare(comp, "MethodAndInvalidSignal")
		idle.check(port1, #[], #[])
		busy.check(port1, #["update_a", "signal_b"], #["set_a"], #["update_u"])
	}

	@Test
	def testServerMethodAndSet() {
		val tr1 = new TestFSM.Transition(busy, port1, psm.call_m1)
		tr1.addActionEvent(port1, psm.respond_m1)
		idle.addOutgoing(tr1)

		// self-transition on 'busy'
		val tr2 = new TestFSM.Transition(busy, port1, psm.set_a)
		busy.addOutgoing(tr2)

		prepare(comp, "MethodAndSet")
		idle.check(port1, #[], #[])
		busy.check(port1, #["update_a", "signal_b"], #["call_m2"])
	}
}
