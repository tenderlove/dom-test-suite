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

 /*
 $Log: DOMTestCase.java,v $
 Revision 1.2  2001-07-23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;
import org.xml.sax.*;
import java.util.*;
import java.net.*;

/**
 *    This is an abstract base class for generated DOM tests
 */
public abstract class DOMTestCase extends DOMTest implements org.xml.sax.ErrorHandler {
  private DocumentBuilder builder;
  private DocumentBuilderFactory factory;
  private DOMTestFramework framework;
  private SAXParseException parseException;

  public DOMTestCase() {
  }

  abstract public void runTest() throws Throwable;

  public void setBuilder(DocumentBuilder builder) {
    this.builder = builder;
  }

  public void setFactory(DocumentBuilderFactory factory) {
    this.factory = factory;
  }

  public void setFramework(DOMTestFramework framework) {
    this.framework = framework;
  }


  public boolean hasFeature(String feature,
        String version)  {
     return framework.hasFeature(builder,feature,version);
  }

  public boolean getImplementationAttribute(String name) throws Exception {
    return framework.getImplementationAttribute(factory,name);
  }


  public void wait(int millisecond) {
    framework.wait(millisecond);
  }

  public Document load(String docURI)
    throws SAXException, java.io.IOException {

    //
    //   build a URL for a test file in the JAR
    //
    URL resolvedURI = getClass().getResource("/" + docURI);
    if(resolvedURI == null) {
        //
        //   see if it is an absolute URI
        //
        int firstSlash = docURI.indexOf('/');
        if(firstSlash == 0 ||
            (firstSlash >= 1 && docURI.charAt(firstSlash-1) == ':')) {
            resolvedURI = new URL(docURI);
        }
        else {
            //
            //  try the files/level?/spec directory
            //
            String filename = getClass().getPackage().getName();
            filename = "../files/" + filename.substring(14).replace('.','/') + "/" + docURI;
            resolvedURI = new java.io.File(filename).toURL();
        }
    }

    if(resolvedURI == null) {
        throw new java.io.FileNotFoundException(docURI);
    }

    builder.setErrorHandler(this);
    parseException = null;
    Document doc = null;

    doc = builder.parse(resolvedURI.toString());

    if(parseException != null) {
      throw parseException;
    }
    return doc;
  }

  public void assertTrue(String assertID, boolean actual) {
    framework.assertTrue(this,assertID,actual);
  }

  public void assertFalse(String assertID, boolean actual) {
    framework.assertFalse(this,assertID,actual);
  }

  public void assertNull(String assertID, Object actual) {
    framework.assertNull(this,assertID,actual);
  }

  public void assertNotNull(String assertID, Object actual) {
    framework.assertNotNull(this,assertID,actual);
  }

  public void assertSame(String assertID, Object expected, Object actual) {
    framework.assertSame(this,assertID, expected, actual);
  }

  public void assertInstanceOf(String assertID, Object obj, Class cls) {
    framework.assertInstanceOf(this,assertID, obj,cls);
  }

  public void assertSize(String assertID, int expectedSize, NodeList collection) {
    framework.assertSize(this,assertID, expectedSize, collection);
  }

  public void assertSize(String assertID, int expectedSize, NamedNodeMap collection) {
    framework.assertSize(this, assertID, expectedSize, collection);
  }

  public void assertSize(String assertID, int expectedSize, Collection collection) {
    framework.assertSize(this, assertID, expectedSize, collection);
  }

  public void assertEqualsIgnoreCase(String assertID, String expected, String actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected, actual);
  }

  public void assertEqualsIgnoreCase(String assertID, Collection expected, Collection actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected,actual);
  }

  public void assertEqualsIgnoreCase(String assertID, List expected, List actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, String expected, String actual) {
    framework.assertEquals(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, int expected, int actual) {
    framework.assertEquals(this, assertID, expected, actual);
  }

  public void assertEquals(String assertID, double expected, double actual) {
    framework.assertEquals(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, Collection expected, NodeList actual) {
    Collection actualList = new ArrayList();
    int actualLen = actual.getLength();
    for(int i = 0; i < actualLen; i++) {
      actualList.add(actual.item(i));
    }
    framework.assertEquals(this, assertID, expected,actualList);
  }

  public void assertEquals(String assertID, Collection expected, Collection actual) {
    framework.assertEquals(this, assertID,expected,actual);
  }

  public void assertNotEqualsIgnoreCase(String assertID, String expected, String actual) {
    framework.assertNotEqualsIgnoreCase(this, assertID,expected,actual);
  }

  public void assertNotEquals(String assertID, String expected, String actual) {
    framework.assertNotEquals(this, assertID,expected,actual);
  }

  public void assertNotEquals(String assertID, int expected, int actual) {
    framework.assertNotEquals(this, assertID, expected,actual);
  }

  public void assertNotEquals(String assertID, double expected, double actual) {
    framework.assertNotEquals(this, assertID,expected,actual);
  }

  public boolean same(Object expected, Object actual) {
    return framework.same(expected,actual);
  }

  public boolean equalsIgnoreCase(String expected, String actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equalsIgnoreCase(Collection expected, Collection actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equalsIgnoreCase(List expected, List actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equals(String expected, String actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(int expected, int actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(double expected, double actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(Collection expected, Collection actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(List expected, List actual) {
    return framework.equals(expected,actual);
  }

  public int size(Collection collection) {
    return framework.size(collection);
  }

  public int size(NamedNodeMap collection) {
    return framework.size(collection);
  }

  public int size(NodeList collection) {
    return framework.size(collection);
  }

  public void error(SAXParseException ex) {
    if(parseException == null) {
      parseException = ex;
    }
  }

  public void warning(SAXParseException ex) {
  }

  public void fatalError(SAXParseException ex) {
    if(parseException == null) {
      parseException = ex;
    }
  }

}

