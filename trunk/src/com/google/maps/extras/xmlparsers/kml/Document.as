/*
* Copyright 2008 Google Inc. 
* Licensed under the Apache License, Version 2.0:
*  http://www.apache.org/licenses/LICENSE-2.0
*/
// todo: Support Schema, StyleSelector elements
package com.google.maps.extras.xmlparsers.kml
{
    import com.google.maps.extras.xmlparsers.Namespaces;
	import com.google.maps.extras.xmlparsers.ParsingTools;
	import com.google.maps.extras.xmlparsers.XmlElement;

	/**
	*	Class that represents a &lt;Document&gt; element within a KML file.
	* 
	* 	@see http://code.google.com/apis/kml/documentation/kmlreference.html#document
	*/
	public class Document extends Container
	{
		
		/**
		*	Constructor for class.
		* 
		*	@param x
		*/	
		public function Document(x:XMLList)
		{
			super(x);
		}
		
		public override function toString():String {
			return "Document: " + super.toString();
		}
	}
}
