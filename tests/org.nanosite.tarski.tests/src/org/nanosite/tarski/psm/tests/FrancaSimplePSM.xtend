package org.nanosite.tarski.psm.tests

import org.nanosite.tarski.psm.tests.utils.TestPSM

/**
 * Example PSM used for checker tests.</p>
 * 
 * This PSM is an alternative representation of
 * Franca's 10-SimpleRefContract.fidl example.</p>
 */
class FrancaSimplePSM extends TestPSM {

	// declare all events used by this PSM
	
	public val call_m1 = "call_m1".fromClient
	public val respond_m1 = "respond_m1".fromServer

	public val call_m2 = "call_m2".fromClient
	public val respond_m2 = "respond_m2".fromServer
	public val error_m2 = "error_m2".fromServer

	public val call_r = "call_r".fromClient

	public val set_a = "set_a".fromClient
	public val update_a = "update_a".fromServer

	public val update_u = "update_u".fromServer

	public val signal_b = "signal_b".fromServer
	
	new() {
		// create states
		super("A", #["B", "C", "D", "E", "F"])

		// create transitions
		addTransition("A", "B", call_m1)
		addTransition("B", "C", respond_m1)
		addTransition("C", "C", update_a)
		addTransition("C", "C", signal_b)
		addTransition("C", "D", set_a)
		addTransition("D", "D", set_a)
		addTransition("D", "E", call_m2)
		addTransition("E", "C", respond_m2)
		addTransition("E", "F", error_m2)
		addTransition("F", "F", update_u)
		addTransition("F", "A", call_r)
	}
	
	
}
