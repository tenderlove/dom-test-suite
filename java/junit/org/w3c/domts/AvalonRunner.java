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
$Log: AvalonRunner.java,v $
Revision 1.1  2001-08-02 04:45:16  dom-ts-4
Adapter for Avalon test framework.

*/

package org.w3c.domts;

import org.w3c.domts.*;
import org.apache.testlet.*;
import org.apache.testlet.engine.*;
import java.lang.reflect.*;
import javax.xml.parsers.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;

public class AvalonRunner extends TextTestEngine {

  private DOMTestDocumentBuilderFactory factory;

  public AvalonRunner() throws Exception {
//    super(args);
/*
    Constructor testConstructor = null;
    Class testClass = AvalonRunner.class.getClassLoader().loadClass(args[0]);
    testConstructor = testClass.getConstructor(
        new Class[] { DOMTestDocumentBuilderFactory.class});


    DOMTestDocumentBuilderFactory factory1 =
      new DOMTestDocumentBuilderFactory(attrNames, attrValues1);

    DOMTestDocumentBuilderFactory factory2 =
      new DOMTestDocumentBuilderFactory(attrNames, attrValues2);

//    printPrologue();
//    printImplementation(factory1);
//    printAttributes(factory1);
//    runTest(testConstructor, factory1);

//    printAttributes(factory2);
//    runTest(testConstructor, factory2);

*/
  }


  protected void initialize() {
    if(m_showBanner) {
      System.out.println("DOM Test Adapter for Avalon\n");
      System.out.println("Copyright (c) 2001 World Wide Web Consortium,");
      System.out.println("Massachusetts Institute of Technology, Institut National de");
      System.out.println("Recherche en Informatique et en Automatique, Keio University). All");
      System.out.println("Rights Reserved. This program is distributed under the W3C's Software");
      System.out.println("Intellectual Property License. This program is distributed in the");
      System.out.println("hope that it will be useful, but WITHOUT ANY WARRANTY; without even");
      System.out.println("the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR");
      System.out.println("PURPOSE.");
      System.out.println("See W3C License http://www.w3.org/Consortium/Legal/ for more details.\n");
      System.out.println("This product includes software developed by the");
      System.out.println("Apache Software Foundation (http://www.apache.org/).\n\n");
    }

    DocumentBuilderFactory docfactory = factory.newInstance();
    try {
      DocumentBuilder builder = docfactory.newDocumentBuilder();
      DOMImplementation domimpl = builder.getDOMImplementation();

      if(domimpl != null) {
        Class domimplClass = domimpl.getClass();
        Package domimplPackage = domimplClass.getPackage();
        String implTitle = domimplPackage.getImplementationTitle();
        if(implTitle != null) {
          System.out.println("Implementation title:" + implTitle);
        }
        String implVendor = domimplPackage.getImplementationVendor();
        if(implVendor != null) {
          System.out.println("Implementation vendor:" + implVendor);
        }
        String implVersion = domimplPackage.getImplementationVersion();
        if(implVersion != null) {
          System.out.println("Implementation version:" + implVersion);
        }
        if(implTitle == null && implVendor == null) {
          System.out.println("Class name for DOMImplementation:" + domimplClass.getName());
        }

        printFeature(domimpl,"DOM Level 1","XML","xml","1.0");
        printFeature(domimpl,"DOM Level 2","XML","xml","2.0");
        printFeature(domimpl,"DOM Level 2 Core","CORE","core","2.0");
        printFeature(domimpl,"DOM Level 2 HTML", "HTML" , "html" , "2.0");
        printFeature(domimpl,"DOM Level 2 Traversal","TRAVERSAL","traversal","2.0");
        printFeature(domimpl,"DOM Level 2 Events","EVENTS","events","2.0");
        printFeature(domimpl,"DOM Level 2 Mutation Events","MUTATIONEVENTS","mutationevents","2.0");
        printFeature(domimpl,"DOM Level 3","XML","xml","3.0");
        printFeature(domimpl,"DOM Level 3 Core","CORE","core","3.0");
        printFeature(domimpl,"DOM Level 3 XPath", "XPATH", "xpath", "3.0");
        printFeature(domimpl,"SVG", "org.w3c.svg", "org.w3c.svg", "1.0");
        printFeature(domimpl,"MathML", "org.w3c.dom.mathml", "org.w3c.dom.mathml", null);
      }
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
    System.out.println("\n");

  }

  protected void usage() {
    System.out.println("Usage:\n");
    System.out.println("java org.w3c.domts.AvalonRunner classname");
  }

  protected void testletPreamble( final Testlet testlet, final TestletContext context ) {
    DocumentBuilderFactory docfactory = factory.newInstance();
    System.out.println("isCoalescing() == " + String.valueOf(docfactory.isCoalescing()));
    System.out.println("isExpandEntityReferences() == " + String.valueOf(docfactory.isExpandEntityReferences()));
    System.out.println("isIgnoringComments() == " + String.valueOf(docfactory.isIgnoringComments()));
    System.out.println("isIgnoringElementContentWhitespace() == " + String.valueOf(docfactory.isIgnoringElementContentWhitespace()));
    System.out.println("isNamespaceAware() == " + String.valueOf(docfactory.isNamespaceAware()));
    System.out.println("isValidating() == " + String.valueOf(docfactory.isValidating()));
  }


  private static void printFeature(DOMImplementation impl,String desc, String upperFeature, String lowerFeature, String version) {
    try {
      boolean hasFeature = impl.hasFeature(upperFeature,version);
      if(!hasFeature) {
        hasFeature = impl.hasFeature(lowerFeature,version);
      }
      if(hasFeature) {
        System.out.println("Parser supports " + desc);
      }
      else {
        System.out.println("Parser does not support " + desc);
      }
    }
    catch(Exception ex) {
      System.out.println("Exception checking feature " + upperFeature);
      ex.printStackTrace();
    }
  }


  public void runEngine(DOMTestDocumentBuilderFactory factory, String[] args) {
    this.factory = factory;
    runEngine(args);
  }

  public static void main (String[] args) {
    try {
      AvalonRunner runner = new AvalonRunner();

      String[] attrNames = {
        "coalescing",
        "expandEntityReferences",
        "ignoringElementContentWhitespace",
        "namespaceAware",
        "validating" };
      boolean[] attrValues1 = { false, false, false, false, false };
      boolean[] attrValues2 = { false, true, true, true, true };

      DOMTestDocumentBuilderFactory factory1 = new DOMTestDocumentBuilderFactory(attrNames, attrValues1);
      runner.runEngine(factory1,args);

      DOMTestDocumentBuilderFactory factory2 = new DOMTestDocumentBuilderFactory(attrNames, attrValues2);
      runner.runEngine(factory2,args);
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }

    public Testlet getTestletNamed( final String testletName )
    {
        Testlet testlet = null;
        final TestletContext context = getContextFor( testletName );
        final String code = context.getInitParameter( "code", testletName );

        //
        //   failure to find test deserves an error
        //
        Constructor constructor = null;
        try
        {
            final Class c = Class.forName( code );
            constructor = c.getConstructor(
                new Class[] { DOMTestDocumentBuilderFactory.class });
        }
        catch(Exception ex) {
          m_isOk = false;
          ex.printStackTrace();
        }

        //
        //    failure to construct means that it is not compatible
        //       with the factory and should be silent
        //
        if(constructor != null) {
          try {
              Object domtest = constructor.newInstance(new Object[] { factory });
              if(domtest instanceof DOMTestCase) {
                testlet = new AvalonTestCaseAdapter((DOMTestCase) domtest);
              }
              else {
                if(domtest instanceof DOMTestSuite) {
                  testlet = new AvalonTestSuiteAdapter((DOMTestSuite) domtest);
                }
              }
            }
            catch(Exception ex) {
            }
        }

        return testlet;
    }


}