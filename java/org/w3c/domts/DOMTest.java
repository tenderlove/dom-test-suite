/*
 * Copyright (c) 2001-2003 World Wide Web Consortium,
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
 $Log: DOMTest.java,v $
 Revision 1.6  2003-04-24 05:02:05  dom-ts-4
 Xalan-J support for L3 XPath
 http://www.w3.org/Bugs/Public/show_bug.cgi?id=191

 Revision 1.5  2003/04/23 05:48:24  dom-ts-4
 DOMTSML and framework support for createXPathEvaluator
 http://www.w3.org/Bugs/Public/show_bug.cgi?id=190

 Revision 1.4  2003/04/03 07:18:23  dom-ts-4
 Added openStream method

 Revision 1.3  2002/08/13 04:44:46  dom-ts-4
 Added getImplementation()

 Revision 1.2  2002/02/03 04:22:35  dom-ts-4
 DOM4J and Batik support added.
 Rework of parser settings

 Revision 1.1  2001/07/23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;
import org.w3c.dom.*;
import java.io.*;
import java.net.*;


/**
 *    This is an abstract base class for generated DOM tests
 */
public abstract class DOMTest {
  private DOMTestDocumentBuilderFactory factory;

  /**
   * This is the appropriate constructor for tests that
   * make no requirements on the parser configuration.
   * @param factory must not be null
   */
  public DOMTest(DOMTestDocumentBuilderFactory factory) {
    if(factory == null) {
      throw new NullPointerException("factory");
    }
    this.factory = factory;
  }

  /**
   *  This constructor is used by tests that must create
   *  a modified document factory to meet requirements on
   *  the parser configuration.  setFactory should be called
   *  within the test's constructor.
   */
  public DOMTest() {
    factory = null;
  }

  /**
   * Should only be called in the constructor of a derived type.
   */
  protected void setFactory(DOMTestDocumentBuilderFactory factory) {
    this.factory = factory;
  }

  public boolean hasFeature(String feature,String version)  {
     return factory.hasFeature(feature,version);
  }

  public boolean hasSetting(DocumentBuilderSetting setting)  {
     return setting.hasSetting(factory);
  }


  protected DOMTestDocumentBuilderFactory getFactory() {
    return factory;
  }

  public DOMImplementation getImplementation() {
    return factory.getDOMImplementation();
  }

  private URL resolveURI(String baseURI) throws DOMTestLoadException {
    String docURI  = factory.addExtension(baseURI);

    URL resolvedURI = null;
    try {
        resolvedURI = new URL(docURI);
        if (resolvedURI.getProtocol() != null) {
            return resolvedURI;
        }
    } catch(MalformedURLException ex) {
//        throw new DOMTestLoadException(ex);
    }
    //
    //   build a URL for a test file in the JAR
    //
    resolvedURI = getClass().getResource("/" + docURI);
    if(resolvedURI == null) {
        //
        //   see if it is an absolute URI
        //
        int firstSlash = docURI.indexOf('/');
        try {
          if(firstSlash == 0 ||
            (firstSlash >= 1 && docURI.charAt(firstSlash-1) == ':')) {
              resolvedURI = new URL(docURI);
          }
          else {
            //
            //  try the files/level?/spec directory
            //
            String filename = getClass().getPackage().getName();
            filename = "tests/" + filename.substring(14).replace('.','/') + "/files/" + docURI;
            resolvedURI = new java.io.File(filename).toURL();
          }
        }
        catch(MalformedURLException ex) {
          throw new DOMTestLoadException(ex);
        }
    }

    if(resolvedURI == null) {
        throw new DOMTestLoadException(new java.io.FileNotFoundException(docURI));
    }
    return resolvedURI;
  }

  public Document load(String docURI) throws DOMTestLoadException {

    return factory.load(resolveURI(docURI));
  }

  public Object createXPathEvaluator(Document doc) {
    return factory.createXPathEvaluator(doc);
  }


  public InputStream openStream(String docURI) throws DOMTestLoadException, IOException {
    return resolveURI(docURI).openStream();
  }


  abstract public String getTargetURI();

  public final boolean isCoalescing() {
      return factory.isCoalescing();
  }

  public final boolean isExpandEntityReferences() {
      return factory.isExpandEntityReferences();
  }

  public final boolean isIgnoringElementContentWhitespace() {
      return factory.isIgnoringElementContentWhitespace();
  }

  public final boolean isNamespaceAware() {
      return factory.isNamespaceAware();
  }

  public final boolean isValidating() {
      return factory.isValidating();
  }

  public final boolean isSigned() {
    return true;
  }

  public final boolean isHasNullString() {
    return true;
  }

}

