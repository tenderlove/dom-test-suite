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
 $Log: BatikTestDocumentBuilderFactory.java,v $
 Revision 1.1  2002-02-03 04:22:35  dom-ts-4
 DOM4J and Batik support added.
 Rework of parser settings

 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;
import org.xml.sax.*;
import java.lang.reflect.*;

/**
 *   This class implements the generic parser and configuation
 *   abstract class for JAXP supporting parsers.
 */
public class BatikTestDocumentBuilderFactory
  extends DOMTestDocumentBuilderFactory {

  private /* org.dom4j.DocumentFactory */ Object domFactory;
  private org.xml.sax.XMLReader xmlReader;
  private Method createDocument;
  private DOMImplementation domImpl;


  /**
   * Creates a Batik implementation of DOMTestDocumentBuilderFactory.
   * @param settings array of settings, may be null.
   */
  public BatikTestDocumentBuilderFactory(DocumentBuilderSetting[] settings)
    throws DOMTestIncompatibleException {
    super(settings);
    domImpl = null;

    //
    //   get the JAXP specified SAX parser's class name
    //
    SAXParserFactory saxFactory = SAXParserFactory.newInstance();
    try {
      SAXParser saxParser = saxFactory.newSAXParser();
      xmlReader = saxParser.getXMLReader();
    }
    catch(Exception ex) {
      throw new DOMTestIncompatibleException(ex,null);
    }
    String xmlReaderClassName = xmlReader.getClass().getName();

    //
    //   can't change settings, so if not the same as
    //      the default SAX parser then throw an exception
    //
//    for(int i = 0; i < settings.length; i++) {
//      if(!settings[i].hasSetting(this)) {
      //        TODO
      //        throw new DOMTestIncompatibleException(null,settings[i]);
//      }
//    }
    //
    //   try loading Batik reflectively
    //
    try {
      ClassLoader classLoader = ClassLoader.getSystemClassLoader();
      Class domFactoryClass = classLoader.loadClass("org.apache.batik.dom.svg.SAXSVGDocumentFactory");

      Constructor domFactoryConstructor =
          domFactoryClass.getConstructor(new Class[] { String.class });
      domFactory = domFactoryConstructor.newInstance(
          new Object[] { xmlReaderClassName } );
      createDocument = domFactoryClass.getMethod("createDocument",
          new Class[] { String.class, java.io.InputStream.class });
    }
    catch(InvocationTargetException ex) {
      throw new DOMTestIncompatibleException(ex.getTargetException(),null);
    }
    catch(Exception ex) {
      throw new DOMTestIncompatibleException(ex,null);
    }
  }

  public DOMTestDocumentBuilderFactory newInstance(DocumentBuilderSetting[] newSettings)
    throws DOMTestIncompatibleException {
    if(newSettings == null) {
      return this;
    }
    DocumentBuilderSetting[] mergedSettings = mergeSettings(newSettings);
    return new BatikTestDocumentBuilderFactory(mergedSettings);
  }

  public Document load(java.net.URL url) throws DOMTestLoadException {
    try {
      java.io.InputStream stream = url.openStream();
      return (org.w3c.dom.Document)
        createDocument.invoke(domFactory, new Object[] { url.toString(), stream });
    }
    catch(InvocationTargetException ex) {
      ex.printStackTrace();
      throw new DOMTestLoadException(ex.getTargetException());
    }
    catch(Exception ex) {
      ex.printStackTrace();
      throw new DOMTestLoadException(ex);
    }
  }

  public DOMImplementation getDOMImplementation() {
      //
      //   get DOM implementation
      //
      if(domImpl == null) {
        try {
          Class svgDomImplClass = ClassLoader.getSystemClassLoader().loadClass("org.apache.batik.dom.svg.SVGDOMImplementation");
          Method getImpl = svgDomImplClass.getMethod("getDOMImplementation",new Class[0]);
          domImpl = (DOMImplementation) getImpl.invoke(null,new Object[0]);
        }
        catch(Exception ex) {
        }
      }
      return domImpl;
  }

  public boolean hasFeature(String feature, String version) {
    return getDOMImplementation().hasFeature(feature,version);
  }

  public String addExtension(String testFileName) {
    return testFileName + ".svg";
  }

    public boolean isCoalescing() {
      return false;
    }

    public boolean isExpandEntityReferences() {
      return false;
    }

    public boolean isIgnoringElementContentWhitespace() {
      return false;
    }

    public boolean isNamespaceAware() {
      return true;
    }

    public boolean isValidating() {
      return false;
    }


}

