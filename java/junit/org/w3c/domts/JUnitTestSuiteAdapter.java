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
 Revision 1.2  2002-06-03 23:48:48  dom-ts-4
 Support for Events tests

 Revision 1.1  2001/07/23 04:52:20  dom-ts-4
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
        //
        //   since this is done with reflection 
        //     any exception on construction is wrapped with
        //     an InvocationTargetException and must be unwrapped
      Object domtest;
      try {
        domtest = testConstructor.newInstance(new Object[] { factory });
      } catch(InvocationTargetException ex) {
        throw ex.getTargetException();
      } 

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
    catch(Throwable ex) {
      if(!(ex instanceof DOMTestIncompatibleException)) {
        ex.printStackTrace();
      }
    }
  }
}