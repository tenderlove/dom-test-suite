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
 $Log: JUnitTestSuiteAdapter.java,v $
 Revision 1.1  2001-07-23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import junit.framework.*;
import java.lang.reflect.*;

public class JUnitTestSuiteAdapter extends TestSuite implements DOMTestSink  {

  private DOMTestSuite test;

  public JUnitTestSuiteAdapter(DOMTestSuite test) {
    super(test.getTargetURI());
    this.test = test;
    test.build(this);
  }

  public void addTest(Class testclass) {
    DOMTestDocumentBuilderFactory factory = test.getFactory();
    try {
      Constructor testConstructor = testclass.getConstructor(
          new Class[] { DOMTestDocumentBuilderFactory.class } );
      Object domtest = testConstructor.newInstance(new Object[] { factory });
      if(domtest instanceof DOMTestCase) {
        TestCase test = new JUnitTestCaseAdapter((DOMTestCase) domtest);
        addTest(test);
      }
      else {
        if(domtest instanceof DOMTestSuite) {
          TestSuite test = new JUnitTestSuiteAdapter((DOMTestSuite) domtest);
          addTest(test);
        }
      }
    }
    catch(Exception ex) {
      if(!(ex instanceof DOMTestIncompatibleException)) {
        ex.printStackTrace();
      }
    }
  }
}