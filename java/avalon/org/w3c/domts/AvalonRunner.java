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
Revision 1.3  2002-01-11 17:07:10  plehegar
cleaned the DOMImplementation features to match the recommendations.
Note that DOM Level 3 is still a WD

Revision 1.2  2001/11/01 15:02:50  dom-ts-4
Doxygen and Avalon support

Revision 1.1  2001/08/02 04:45:16  dom-ts-4
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
  private Class testClass = null;

  public AvalonRunner(Class testClass) {
    this.testClass = testClass;
  }

  public AvalonRunner(String[] args) throws Exception {
    testClass = AvalonRunner.class.getClassLoader().loadClass(args[0]);
  }
  
  
  public void execute(String[] args) throws Exception {
    Constructor testConstructor = null;
    testConstructor = testClass.getConstructor(
         new Class[] { DOMTestDocumentBuilderFactory.class});

      String[] attrNames = {
        "coalescing",
        "expandEntityReferences",
        "ignoringElementContentWhitespace",
        "namespaceAware",
        "validating" };
      boolean[] attrValues1 = { false, false, false, false, false };
      boolean[] attrValues2 = { false, true, true, true, true };

    DOMTestDocumentBuilderFactory factory1 =
      new DOMTestDocumentBuilderFactory(attrNames, attrValues1);

    DOMTestDocumentBuilderFactory factory2 =
      new DOMTestDocumentBuilderFactory(attrNames, attrValues2);

    printPrologue();
    printImplementation(factory1);
    printAttributes(factory1);
    factory = factory1;
    String[] classNames = new String[] { testClass.getName() };
    runEngine(classNames);

    printAttributes(factory2);
    factory = factory2;
    runEngine(classNames);


  }

  private static void printPrologue() {
    System.out.println("DOM Test Adapter for Avalon Testlet\n");
    System.out.println("Copyright (c) 2001 World Wide Web Consortium,");
    System.out.println("Massachusetts Institute of Technology, Institut National de");
    System.out.println("Recherche en Informatique et en Automatique, Keio University). All");
    System.out.println("Rights Reserved. This program is distributed under the W3C's Software");
    System.out.println("Intellectual Property License. This program is distributed in the");
    System.out.println("hope that it will be useful, but WITHOUT ANY WARRANTY; without even");
    System.out.println("the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR");
    System.out.println("PURPOSE.");
    System.out.println("See W3C License http://www.w3.org/Consortium/Legal/ for more details.\n");
  }

  private static void printHelp() {
    System.out.println("Usage:\n");
    System.out.println("java org.w3c.domts.JUnitRunner classname");
  }


  private static void printImplementation(DOMTestDocumentBuilderFactory factory) {
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

        printFeature(domimpl,"DOM Level 1 XML","XML","xml","1.0");
        printFeature(domimpl,"DOM Level 1 HTML","HTML","html","1.0");
        printFeature(domimpl,"DOM Level 2","CORE","core","2.0");
        printFeature(domimpl,"DOM Level 2 XML","XML","xml","2.0");
        printFeature(domimpl,"DOM Level 2 HTML", "HTML" , "html" , "2.0");
        printFeature(domimpl,"DOM Level 2 Views", "VIEWS" , "views" , "2.0");
        printFeature(domimpl,"DOM Level 2 Style Sheets", "STYLESHEETS" , "stylesheets" , "2.0");
        printFeature(domimpl,"DOM Level 2 CSS", "CSS" , "css" , "2.0");
        printFeature(domimpl,"DOM Level 2 CSS2", "CSS2" , "css2" , "2.0");
        printFeature(domimpl,"DOM Level 2 Events","EVENTS","events","2.0");
        printFeature(domimpl,"DOM Level 2 User Interface Events","UIEVENTS","uievents","2.0");
        printFeature(domimpl,"DOM Level 2 Mouse Events","MOUSEEVENTS","mouseevents","2.0");
        printFeature(domimpl,"DOM Level 2 Mutation Events","MUTATIONEVENTS","mutationevents","2.0");
        printFeature(domimpl,"DOM Level 2 HTML Events","HTMLEVENTS","htmlevents","2.0");
        printFeature(domimpl,"DOM Level 2 Traversal","TRAVERSAL","traversal","2.0");
        printFeature(domimpl,"DOM Level 2 Range","RANGE","range","2.0");
        printFeature(domimpl,"DOM Level 3","CORE","core","3.0");
        printFeature(domimpl,"DOM Level 3 XML","XML","xml","3.0");
        printFeature(domimpl,"DOM Level 3 Core","CORE","core","3.0");
        printFeature(domimpl,"DOM Level 3 XPath", "XPATH", "xpath", "3.0");
        printFeature(domimpl,"SVG Version 1.0", "org.w3c.dom.svg", "org.w3c.dom.svg", "1.0");
        printFeature(domimpl,"SVG Version 1.0 Static", "org.w3c.dom.svg.static", "org.w3c.dom.svg.static", "1.0");
        printFeature(domimpl,"SVG Version 1.0 Dynamic", "org.w3c.dom.svg.dynamic", "org.w3c.dom.svg.dynamic", "1.0");
        printFeature(domimpl,"SVG Version 1.0 Animation", "org.w3c.dom.svg.animation", "org.w3c.dom.svg.animation", "1.0");
        printFeature(domimpl,"SVG Version 1.0 (full support)", "org.w3c.dom.svg.all", "org.w3c.dom.svg.all", "1.0");
        printFeature(domimpl,"SMIL Animation", "TIMECONTROL", "timecontrol", null);
        printFeature(domimpl,"MathML Version 2.0", "org.w3c.dom.mathml", "org.w3c.dom.mathml", null);
      }
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
    System.out.println("\n");
  }

  private void printAttributes(DOMTestDocumentBuilderFactory dsFactory) {
    DocumentBuilderFactory factory = dsFactory.newInstance();
    System.out.println("isCoalescing() == " + String.valueOf(factory.isCoalescing()));
    System.out.println("isExpandEntityReferences() == " + String.valueOf(factory.isExpandEntityReferences()));
    System.out.println("isIgnoringComments() == " + String.valueOf(factory.isIgnoringComments()));
    System.out.println("isIgnoringElementContentWhitespace() == " + String.valueOf(factory.isIgnoringElementContentWhitespace()));
    System.out.println("isNamespaceAware() == " + String.valueOf(factory.isNamespaceAware()));
    System.out.println("isValidating() == " + String.valueOf(factory.isValidating()));
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

  protected void initialize() {
  }

  protected void usage() {
    System.out.println("Usage:\n");
    System.out.println("java org.w3c.domts.AvalonRunner classname");
  }



  public void runEngine(DOMTestDocumentBuilderFactory factory, String[] args) {
    this.factory = factory;
    runEngine(args);
  }

  public static void main (String[] args) {
    if(args.length != 1) {
      printPrologue();
      printHelp();
      return;
    }
    try {
      AvalonRunner runner = new AvalonRunner(args);
      runner.execute(args);
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
