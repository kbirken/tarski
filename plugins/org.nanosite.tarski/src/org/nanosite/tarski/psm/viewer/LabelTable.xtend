package org.nanosite.tarski.psm.viewer

import java.util.List

/**
 * Helper class which can produce a HTML table from a list of texts.
 * 
 * This is used by the DOT generator in order to produce complex HTML-style labels with graphviz.
 *  
 * @author Klaus Birken - initial contribution and API
 */
class LabelTable {
	
	/**
	 * The available styles for table rows.
	 */
	enum Style {
		PLAIN,
		ERROR
	}
	
	/**
	 * Private helper class, represents one row in the table.
	 */
	static private class Entry {
		val String text1
		val String text2
		val Style style
		
		new (String text1, String text2) {
			this.text1 = text1
			this.text2 = text2
			this.style = Style.PLAIN
		}

		new (String text1, String text2, Style style) {
			this.text1 = text1
			this.text2 = text2
			this.style = style
		}

		def generate() {
			val e = style==Style.ERROR
			val ec = '<font color="red">'
			
			'''
				<td border="0"«IF text2==null» colspan="2"«ENDIF»>«IF e»«ec»«ENDIF»«text1»«IF e»</font>«ENDIF»</td>
				«IF text2!=null»
				<td border="0">«IF e»«ec»«ENDIF»«text2»«IF e»</font>«ENDIF»</td>
				«ENDIF»
			'''
		}
	}


	val List<Entry> items = newArrayList
	
	/**
	 * Add single string row with default style.
	 */
	def add(String text) {
		items.add(new Entry(text, null))
	}

	/**
	 * Add single string row with configurable style.
	 */
	def add(String text, Style style) {
		items.add(new Entry(text, null, style))
	}

	/**
	 * Add two-string row with default style.
	 */
	def add(String text1, String text2) {
		items.add(new Entry(text1, text2))
	}

	/**
	 * Add two-string row with configurable style.
	 */
	def add(String text1, String text2, Style style) {
		items.add(new Entry(text1, text2, style))
	}

	/**
	 * Generate HTML-style table from all collected entries.
	 */
	def generate() '''
		<<table border="0" cellspacing="0">
			«FOR i : items»
			<tr>«i.generate»</tr>
			«ENDFOR»
		</table>>
	'''
	
}