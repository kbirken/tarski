package org.nanosite.tarski.psm.checker

import org.nanosite.tarski.psm.psmapi.IProtocolSM.IPSMTrigger

class TriggerUtils {
	
	def static getLabel(IPSMTrigger trigger) {
		trigger.event.label.replace(' ', '_')
	}
}
