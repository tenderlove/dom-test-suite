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
 Revision 1.1  2001-07-23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */


package org.w3c.domts;
import javax.xml.parsers.*;

public class DOMTestIncompatibleException extends Exception {
  public Throwable initialException;

  public DOMTestIncompatibleException() {}
  public DOMTestIncompatibleException(String msg) {
    super(msg);
  }
  public DOMTestIncompatibleException(FactoryConfigurationError ex) {
    initialException = ex;
  }
  public DOMTestIncompatibleException(String feature, String version) {
    super("Test requires feature " + feature + ((version == null) ? "" : (", version " + version )));
  }

  public DOMTestIncompatibleException(java.lang.IllegalArgumentException ex) {
    initialException = ex;
  }
}

