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
 $Log: AvalonTestSuiteAdapter.java,v $
 Revision 1.1  2001-11-01 05:12:43  dom-ts-4
 Avalon testlet support

 Revision 1.1  2001/08/02 04:45:16  dom-ts-4
 Adapter for Avalon test framework.

 */

package org.w3c.domts;

import org.apache.testlet.*;
import java.lang.reflect.*;
import java.util.*;

public class AvalonTestSuiteAdapter extends AbstractTestlet implements DOMTestSink  {

  private DOMTestSuite suite;
  private DefaultTestSuite tests;

  public AvalonTestSuiteAdapter(DOMTestSuite suite) {
    super(suite.getTargetURI());
    this.suite = suite;
    tests = new DefaultTestSuite(m_name);
    suite.build(this);
  }

  public void addTest(Class testclass) {
    DOMTestDocumentBuilderFactory factory = suite.getFactory();
    try {
        Constructor testConstructor = testclass.getConstructor(
          new Class[] { DOMTestDocumentBuilderFactory.class } );
        Object domtest = testConstructor.newInstance(new Object[] { factory });
        if(domtest instanceof DOMTestCase) {
          TestCase test = new AvalonTestCaseAdapter((DOMTestCase) domtest);
          tests.addTestCase(test);
        }
        else {
          if(domtest instanceof DOMTestSuite) {
            DOMTestSuite domsuite = (DOMTestSuite) domtest;
            domsuite.build(this);
          }
        }
      }
      catch(Exception ex) {
        if(!(ex instanceof DOMTestIncompatibleException)) {
          ex.printStackTrace();
        }
      }
  }

  public TestSuite getTestSuite() {
    return tests;
  }

}
