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
 Revision 1.3  2002-06-03 23:48:48  dom-ts-4
 Support for Events tests

 Revision 1.2  2002/02/03 04:22:35  dom-ts-4
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
  private final String msg;


  /**
   *  Constructor from a ParserConfigurationException
   *  or reflection exception
   */
  public DOMTestIncompatibleException(Throwable ex,DocumentBuilderSetting setting) {
    if (ex != null) {
        msg = ex.toString();
    } else {
        if (setting != null) {
            msg = setting.toString();
        } else {
            msg = super.toString();
        }
    }
  }

  public DOMTestIncompatibleException(String feature, String version) {
    StringBuffer buf = new StringBuffer("Implementation does not support feature \"");
    buf.append(feature);
    buf.append("\" version=\"");
    buf.append(version);
    buf.append("\".");
    msg = buf.toString();
  }

  public String toString() {
    return msg;
  }

}

