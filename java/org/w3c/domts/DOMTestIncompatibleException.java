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
 $Log: DOMTestIncompatibleException.java,v $
 Revision 1.2  2002-02-03 04:22:35  dom-ts-4
 DOM4J and Batik support added.
 Rework of parser settings

 Revision 1.1  2001/07/23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */


package org.w3c.domts;
import javax.xml.parsers.*;
import java.lang.reflect.InvocationTargetException;

/**
 * This exception represents a mismatch between the
 * requirements of the test (for example, entity preserving)
 * and the capabilities of the parser under test.
 * @author Curt Arnold
 */
public class DOMTestIncompatibleException extends Exception {
  private final Throwable exception;
  private final DocumentBuilderSetting setting;


  /**
   *  Constructor from a ParserConfigurationException
   *  or reflection exception
   */
  public DOMTestIncompatibleException(Throwable ex,DocumentBuilderSetting setting) {
    exception = ex;
    this.setting = setting;
  }

  public String toString() {
    if(exception != null) {
      return exception.toString();
    }
    if(setting != null) {
      return setting.toString();
    }
    return super.toString();
  }

}

