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
 Revision 1.3  2002-01-30 07:08:44  dom-ts-4
 Update for GNUJAXP

 Revision 1.2  2001/08/22 22:12:49  dom-ts-4
 Now passing all tests with default settings

 Revision 1.1  2001/07/23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;
import java.lang.reflect.*;

/**
 *
 */
public class DOMTestDocumentBuilderFactory {
  private Class factoryClass;
  private DocumentBuilderFactory baseFactory;
  private String[] baseNames;
  private boolean[] baseValues;


  public DOMTestDocumentBuilderFactory(Class factoryClass,String[] baseNames, boolean[] baseValues) {
    this.factoryClass = factoryClass;
    baseFactory = null;
    this.baseNames = baseNames;
    this.baseValues = baseValues;
  }

  public DocumentBuilderFactory newInstance() 
    throws FactoryConfigurationError, InstantiationException,
           IllegalAccessException, IllegalArgumentException, 
           InvocationTargetException, NoSuchMethodException,
           SecurityException {
    if(baseFactory == null) {
      //
      //   if a specific implementation class was not specified then
      //      use the JAXP default parser
      if(factoryClass == null) {
        baseFactory = DocumentBuilderFactory.newInstance();
      }
      else {
        baseFactory = (DocumentBuilderFactory) factoryClass.getConstructor(new Class[] { }).newInstance(new Object[] {});
      }
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
    if(property.equals("signed") || property.equals("hasNullString")) {
      if(!value) {
        throw new IllegalArgumentException();
      }
    }
    else {
      try {
        String mutatorName = "set" +
          property.substring(0,1).toUpperCase() +
          property.substring(1);
        Method mutator = factory.getClass().getMethod(mutatorName,
          new Class[] { boolean.class });
        mutator.invoke(factory,new Object[] { new Boolean(value) } );
      }
      catch(Exception ex) {
        factory.setAttribute(property,new Boolean(value));
      }
    }
  }


}

