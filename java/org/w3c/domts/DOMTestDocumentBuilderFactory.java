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
 $Log: DOMTestDocumentBuilderFactory.java,v $
 Revision 1.1  2001-07-23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;

/**
 *
 */
public class DOMTestDocumentBuilderFactory {
  private DocumentBuilderFactory baseFactory;
  private String[] baseNames;
  private boolean[] baseValues;


  public DOMTestDocumentBuilderFactory(String[] baseNames, boolean[] baseValues) {
    baseFactory = null;
    this.baseNames = baseNames;
    this.baseValues = baseValues;
  }

  public DocumentBuilderFactory newInstance() throws FactoryConfigurationError {
    if(baseFactory == null) {
      baseFactory = DocumentBuilderFactory.newInstance();
      for(int i = 0; i < baseNames.length; i++) {
          setAttribute(baseFactory,baseNames[i],baseValues[i]);
      }
    }
    return baseFactory;
  }

  public DocumentBuilderFactory newInstance(String[] propNames, boolean[] propValues)
      throws java.lang.IllegalArgumentException, FactoryConfigurationError {

    DocumentBuilderFactory newFactory = baseFactory;
    if(baseFactory == null || (propNames != null && propNames.length > 0)) {
      newFactory = DocumentBuilderFactory.newInstance();
      for(int i = 0; i < baseNames.length; i++) {
          setAttribute(newFactory,baseNames[i],baseValues[i]);
      }
      if(propNames != null && propNames.length > 0) {
        for(int i = 0; i < propNames.length; i++) {
          setAttribute(newFactory,propNames[i], propValues[i]);
        }
      }
      else {
        baseFactory = newFactory;
      }
    }
    return newFactory;
  }

  private void setAttribute(DocumentBuilderFactory factory,
      String property,
      boolean value)
      throws IllegalArgumentException
  {
    if(property.equals("coalescing")) {
      factory.setCoalescing(value);
    }
    else {
      if(property.equals("validating")) {
        factory.setValidating(value);
      }
      else {
        if(property.equals("expandEntityReferences")) {
          factory.setExpandEntityReferences(value);
        }
        else {
          if(property.equals("ignoringElementContentWhitespace")) {
            factory.setIgnoringElementContentWhitespace(value);
          }
          else {
            if(property.equals("ignoringComments")) {
              factory.setIgnoringComments(value);
            }
            else {
              if(property.equals("namespaceAware")) {
                factory.setNamespaceAware(value);
              }
              else {
                factory.setAttribute(property,new Boolean(value));
              }
            }
          }
        }
      }
    }
  }
}

