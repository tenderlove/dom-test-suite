/*
 * Copyright (c) 2001 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import java.lang.*;
import java.util.*;

/**
 *    This interface provides services typically provided by a test framework
 */
public interface DOMTestFramework {
	boolean hasFeature(String feature,String version);
	void wait(int millisecond);
	Document load(String docURI);
	DOMImplementation getImplementation();
	void assertTrue(String testURI, String assertID, boolean actual);
	void assertFalse(String testURI, String assertID, boolean actual);
	void assertNull(String testURI, String assertID, Object actual);
	void assertNotNull(String testURI, String assertID, Object actual);
	void assertSame(String testURI, String assertID, Object expected, Object actual);
	void assertInstanceOf(String testURI, String assertID, Object obj, Class cls);
	void assertSize(String testURI, String assertID, int expectedSize, NodeList collection);
	void assertSize(String testURI, String assertID, int expectedSize, NamedNodeMap collection);
	void assertSize(String testURI, String assertID, int expectedSize, Collection collection);
	void assertEqualsIgnoreCase(String testURI, String assertID, String expected, String actual);
	void assertEquals(String testURI, String assertID, String expected, String actual);
	void assertEquals(String testURI, String assertID, int expected, int actual);
	void assertEquals(String testURI, String assertID, Collection expected, NodeList actual);
	void assertEquals(String testURI, String assertID, Collection expected, Collection actual);
	void assertNotEqualsIgnoreCase(String testURI, String assertID, String expected, String actual);
	void assertNotEquals(String testURI, String assertID, String expected, String actual);
	void assertNotEquals(String testURI, String assertID, int expected, int actual);


	boolean same(Object expected, Object actual);
	boolean equalsIgnoreCase(String expected, String actual);
	boolean equals(String expected, String actual);
	boolean equals(int expected, int actual);
	int size(Collection collection);
	int size(NamedNodeMap collection);
	int size(NodeList collection);
}

