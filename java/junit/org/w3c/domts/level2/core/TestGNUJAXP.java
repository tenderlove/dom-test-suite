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


package org.w3c.domts.level2.core;

import junit.framework.*;
import java.lang.reflect.*;
import javax.xml.parsers.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.w3c.domts.*;

public class TestGNUJAXP extends TestSuite {

  public static TestSuite suite() throws Exception
  {
    Class testClass = ClassLoader.getSystemClassLoader().loadClass("org.w3c.domts.level2.core.alltests");
    Constructor testConstructor = testClass.getConstructor(new Class[] { DOMTestDocumentBuilderFactory.class });


    DocumentBuilderFactory gnujaxpFactory = (DocumentBuilderFactory)
      ClassLoader.getSystemClassLoader().
        loadClass("gnu.xml.dom.JAXPFactory").newInstance();

    DOMTestDocumentBuilderFactory factory =
        new JAXPDOMTestDocumentBuilderFactory(gnujaxpFactory,
          JAXPDOMTestDocumentBuilderFactory.getConfiguration1());


    Object test = testConstructor.newInstance(new Object[] { factory });

    return new JUnitTestSuiteAdapter((DOMTestSuite) test);
  }


}

