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
 $Log: AvalonTestCaseAdapter.java,v $
 Revision 1.1  2001-08-02 04:45:16  dom-ts-4
 Adapter for Avalon test framework.


 */


package org.w3c.domts;

import org.w3c.domts.*;
import org.apache.testlet.*;
import java.lang.reflect.*;
import javax.xml.parsers.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;


public class AvalonTestCaseAdapter extends AbstractTestlet implements DOMTestFramework, TestCase {

  private DOMTestCase test;

  public AvalonTestCaseAdapter(DOMTestCase test) {
    test.setFramework(this);
    this.test = test;
    super.m_name = test.getTargetURI();
  }

  public void runTest() throws Throwable {
    test.runTest();
  }

  public TestSuite getTestSuite() {
    DefaultTestSuite suite = new DefaultTestSuite(m_name);
    suite.addTestCase(this);
    return suite;
  }


  public boolean getImplementationAttribute(DocumentBuilderFactory factory,
    String name) throws Exception {
    Object val = factory.getAttribute(name);
    return ((Boolean) val).booleanValue();
  }

  public boolean hasFeature(DocumentBuilder docBuilder,
        String feature,
        String version)  {
     return docBuilder.getDOMImplementation().hasFeature(feature,version);
  }

  public void wait(int millisecond) {
  }

  public void assertTrue(String assertID, boolean actual)  {
    super.assert(assertID,actual);
  }

  public void assertTrue(DOMTestCase test, String assertID, boolean actual) throws TestFailedException{
    assertTrue(assertID,actual);
  }

  public void assertEquals(String assertID, String expected, String actual)  {
    super.assertEquality(assertID,expected,actual);
  }

  public void assertFalse(DOMTestCase test, String assertID, boolean actual)  {
    super.assert(assertID,!actual);
  }


  public void assertNull(DOMTestCase test, String assertID, Object actual) {
    super.assertNull(assertID,actual);
  }


  public void assertNotNull(DOMTestCase test, String assertID, Object actual) throws TestFailedException {
    super.assertNotNull(assertID,actual);
  }

  public void assertEquals(String assertID, Object expected, Object actual) throws TestFailedException {
    super.assertEquality(assertID,expected,actual);
  }

  public void assertSame(DOMTestCase test, String assertID, Object expected, Object actual) {
    super.assertSame(assertID, expected, actual);
  }

  public void assertInstanceOf(DOMTestCase test, String assertID, Object obj, Class cls)  {
    super.assert(assertID,cls.isInstance(obj));
  }

  public void assertEquals(String assertID, int expected, int actual)  {
    super.assertEquality(assertID,expected,actual);
  }

  public void assertSize(DOMTestCase test, String assertID, int expectedSize, NodeList collection)  {
    super.assertEquality(assertID,expectedSize, collection.getLength());
  }

  public void assertSize(DOMTestCase test, String assertID, int expectedSize, NamedNodeMap collection) {
    super.assertEquality(assertID, expectedSize, collection.getLength());
  }

  public void assertSize(DOMTestCase test, String assertID, int expectedSize, Collection collection)  {
    super.assertEquality(assertID, expectedSize, collection.size());
  }

  public void assertEqualsIgnoreCase(DOMTestCase test, String assertID, String expected, String actual)  {
    if(!expected.equalsIgnoreCase(actual)) {
      super.assertEquality(assertID,expected,actual);
    }
  }

  public void assertEqualsIgnoreCase(DOMTestCase test, String assertID, Collection expected, Collection actual) {
    int size = expected.size();
    assertNotNull(assertID,expected);
    assertNotNull(assertID,actual);
    assertEquals(assertID,size, actual.size());
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      List expectedArray = new ArrayList(expected);
      String expectedString;
      String actualString;
      Iterator actualIter = actual.iterator();
      Iterator expectedIter;
      while(actualIter.hasNext() && equals) {
        actualString = (String) actualIter.next();
        expectedIter = expectedArray.iterator();
        equals = false;
        while(expectedIter.hasNext() && !equals) {
          expectedString = (String) expectedIter.next();
          if(actualString.equalsIgnoreCase(expectedString)) {
            equals = true;
            expectedArray.remove(expectedString);
          }
        }
      }
    }
    assertTrue(assertID,equals);
  }

  public void assertEqualsIgnoreCase(DOMTestCase test, String assertID, List expected, List actual)  {
    int size = expected.size();
    assertNotNull(assertID,expected);
    assertNotNull(assertID,actual);
    assertEquals(assertID,size, actual.size());
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      String expectedString;
      String actualString;
      for(int i = 0; i < size; i++) {
        expectedString = (String) expected.get(i);
        actualString = (String) actual.get(i);
        if(!expectedString.equalsIgnoreCase(actualString)) {
          assertEquals(assertID,expectedString,actualString);
          break;
        }
      }
    }
  }

  public void assertEquals(DOMTestCase test, String assertID, String expected, String actual) throws TestFailedException {
    super.assertEquality(assertID,expected,actual);
  }

  public void assertEquals(DOMTestCase test, String assertID, int expected, int actual) throws TestFailedException {
    super.assertEquality(assertID,expected,actual);
  }

  public void assertEquals(DOMTestCase test, String assertID, double expected, double actual) throws TestFailedException {
      super.assertEquality(assertID,expected, actual);
  }

  public void assertEquals(DOMTestCase test, String assertID, Collection expected, Collection actual)  {
    int size = expected.size();
    assertNotNull(assertID,expected);
    assertNotNull(assertID,actual);
    assertEquals(assertID,size, actual.size());
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      List expectedArray = new ArrayList(expected);
      Object expectedObj;
      Object actualObj;
      Iterator actualIter = actual.iterator();
      Iterator expectedIter;
      while(actualIter.hasNext() && equals) {
        actualObj = actualIter.next();
        expectedIter = expectedArray.iterator();
        equals = false;
        while(expectedIter.hasNext() && !equals) {
          expectedObj = expectedIter.next();
          if(expectedObj == actualObj || expectedObj.equals(actualObj)) {
            equals = true;
            expectedArray.remove(expectedObj);
          }
        }
      }
    }
    assertTrue(assertID,equals);
  }

  public void assertNotEqualsIgnoreCase(DOMTestCase test, String assertID, String expected, String actual)  {
    if(expected.equalsIgnoreCase(actual)) {
      super.assertInequality(assertID, expected,actual);
    }
  }

  public void assertNotEquals(DOMTestCase test, String assertID, String expected, String actual)  {
    super.assertInequality(assertID,expected,actual);
  }

  public void assertNotEquals(DOMTestCase test, String assertID, int expected, int actual) throws TestFailedException {
    super.assertInequality(assertID, expected, actual);
  }

  public void assertNotEquals(DOMTestCase test, String assertID, double expected, double actual) throws TestFailedException {
    if(expected == actual) {
      super.assertInequality(assertID,String.valueOf(expected),String.valueOf(actual));
    }
  }

  public boolean same(Object expected, Object actual) {
    boolean equals = (expected == actual);
    if(!equals && expected != null && expected instanceof Node &&
      actual != null && actual instanceof Node) {
      //
      //  can use Node.isSame eventually
    }
    return equals;
  }

  public boolean equalsIgnoreCase(String expected, String actual) {
    return expected.equalsIgnoreCase(actual);
  }

  public boolean equalsIgnoreCase(Collection expected, Collection actual) {
    int size = expected.size();
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      List expectedArray = new ArrayList(expected);
      String expectedString;
      String actualString;
      Iterator actualIter = actual.iterator();
      Iterator expectedIter;
      while(actualIter.hasNext() && equals) {
        actualString = (String) actualIter.next();
        expectedIter = expectedArray.iterator();
        equals = false;
        while(expectedIter.hasNext() && !equals) {
          expectedString = (String) expectedIter.next();
          if(actualString.equalsIgnoreCase(expectedString)) {
            equals = true;
            expectedArray.remove(expectedString);
          }
        }
      }
    }
    return equals;
  }

  public boolean equalsIgnoreCase(List expected, List actual) {
    int size = expected.size();
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      String expectedString;
      String actualString;
      for(int i = 0; i < size; i++) {
        expectedString = (String) expected.get(i);
        actualString = (String) actual.get(i);
        if(!expectedString.equalsIgnoreCase(actualString)) {
          equals = false;
          break;
        }
      }
    }
    return equals;
  }

  public boolean equals(String expected, String actual) {
    return expected.equals(actual);
  }

  public boolean equals(int expected, int actual) {
    return expected == actual;
  }

  public boolean equals(double expected, double actual) {
    return expected == actual;
  }

  public boolean equals(Collection expected, Collection actual) {
    int size = expected.size();
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      List expectedArray = new ArrayList(expected);
      Object expectedObj;
      Object actualObj;
      Iterator actualIter = actual.iterator();
      Iterator expectedIter;
      while(actualIter.hasNext() && equals) {
        actualObj = actualIter.next();
        expectedIter = expectedArray.iterator();
        equals = false;
        while(expectedIter.hasNext() && !equals) {
          expectedObj = expectedIter.next();
          if(expectedObj != actualObj && expectedObj.equals(actualObj)) {
            equals = true;
            expectedArray.remove(expectedObj);
          }
        }
      }
    }
    return equals;
  }

  public boolean equals(List expected, List actual) {
    int size = expected.size();
    boolean equals = (expected != null && actual != null && size == actual.size());
    if(equals) {
      Object expectedObj;
      Object actualObj;
      for(int i = 0; i < size; i++) {
        expectedObj = expected.get(i);
        actualObj = actual.get(i);
        if(!expectedObj.equals(actualObj)) {
          equals = false;
          break;
        }
      }
    }
    return equals;
  }

  public int size(Collection collection) {
    return collection.size();
  }

  public int size(NamedNodeMap collection) {
    return collection.getLength();
  }

  public int size(NodeList collection) {
    return collection.getLength();
  }



}