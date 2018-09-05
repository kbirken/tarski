/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests.utils

import com.google.common.collect.Lists
import java.util.List
import org.nanosite.tarski.psm.fsmapi.IComponent
import org.nanosite.tarski.psm.fsmapi.IExecutionFSM
import org.nanosite.tarski.psm.fsmapi.IPort

class TestComponent implements IComponent {
	
	val String name
	val List<IPort> ports = Lists.newArrayList	

	val IExecutionFSM fsm
	
	new(String name, IPort p1, IExecutionFSM fsm) {
		this.name = name
		this.ports.add(p1)
		this.fsm = fsm
	}

	override getName() {
		name
	}

	override getPorts() {
		ports
	}

	override IExecutionFSM getExecutionFSM() {
		fsm
	}
	
}
