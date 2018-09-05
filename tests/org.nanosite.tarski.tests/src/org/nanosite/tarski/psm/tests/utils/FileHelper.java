/*******************************************************************************
 * Copyright (c) 2018 Klaus Birken.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.nanosite.tarski.psm.tests.utils;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class FileHelper {

	/**
	 * Helper for saving a text to file
	 *
	 * @param targetDir   the target directory
	 * @param filename    the target filename
	 * @param textToSave  the content for the file
	 * @return true if ok
	 */
	public static boolean save (String targetDir, String filename, String textToSave) {
		// ensure that directory is available
		File dir = new File(targetDir);
		if (! (dir.exists() || dir.mkdirs())) {
			System.err.println("Error: couldn't create directory " + targetDir + "!");
			return false;
		}
		
		// delete file prior to saving
		File file = new File(targetDir + "/" + filename);
		file.delete();
		
		// save contents to file
	    try {
	        BufferedWriter out = new BufferedWriter(new FileWriter(file));
	        out.write(textToSave);
	        out.close();
	        System.out.println("Created file " + file.getAbsolutePath());
	    } catch (IOException e) {
	    	return false;
	    }
	    
	    return true;
	}
}
