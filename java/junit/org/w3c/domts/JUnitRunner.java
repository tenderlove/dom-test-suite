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
$Log: JUnitRunner.java,v $
Revision 1.7  2002-02-03 04:22:35  dom-ts-4
DOM4J and Batik support added.
Rework of parser settings

Revision 1.6  2002/01/30 06:31:59  dom-ts-4
Changed main() to run Swing UI, added -noloading to args

Revision 1.5  2002/01/11 17:05:46  plehegar
cleaned the DOMImplementation features to match the recommendations.
Note that DOM Level 3 is still a WD

Revision 1.4  2001/11/01 15:02:50  dom-ts-4
Doxygen and Avalon support

Revision 1.3  2001/10/18 07:58:17  dom-ts-4
assertURIEquals added
Can now run from dom1-core.jar

Revision 1.2  2001/08/24 08:28:00  dom-ts-4
Test matrix generation.  Some Node.setValue() tests

Revision 1.1  2001/07/23 04:52:20  dom-ts-4
Initial test running using JUnit.

*/

package org.w3c.domts;

import junit.framework.*;
import java.lang.reflect.*;
import javax.xml.parsers.*;
import java.util.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import org.w3c.domts.*;

public class JUnitRunner {

  private Class testClass = null;


  public JUnitRunner(Class testClass) {
    this.testClass = testClass;
  }

  public JUnitRunner(String[] args) throws Exception {
      testClass = ClassLoader.getSystemClassLoader().loadClass(args[0]);
  }

  public void execute(String[] args) throws Exception {
    Constructor testConstructor = null;
    testConstructor = testClass.getConstructor(
         new Class[] { DOMTestDocumentBuilderFactory.class});


    DOMTestDocumentBuilderFactory factory1 =
      new JAXPDOMTestDocumentBuilderFactory(null,
      JAXPDOMTestDocumentBuilderFactory.getConfiguration1());


    printPrologue();
    printImplementation(factory1);
    printAttributes(factory1);
    runTest(testConstructor, factory1);

    DOMTestDocumentBuilderFactory factory2 =
      new JAXPDOMTestDocumentBuilderFactory(null,
      JAXPDOMTestDocumentBuilderFactory.getConfiguration2());

    printAttributes(factory2);
    runTest(testConstructor, factory2);
  }

  private void runTest(Constructor testConstructor,
    DOMTestDocumentBuilderFactory factory) throws Exception {
    TestSuite suite = new TestSuite();
    addTest(suite,factory, testConstructor);
    junit.textui.TestRunner.run (suite);
  }

  private void addTest(TestSuite suite,
    DOMTestDocumentBuilderFactory factory,
    Constructor testConstructor)  throws Exception {
      try {
        Object test = testConstructor.newInstance(new Object[] { factory });
//
//        If having a hard time debugging then
//            explicitly construct the test class here
//
//        Object test = new org.w3c.domts.level1.core.coreAll(factory);
        if(test instanceof DOMTestCase) {
          suite.addTest(new JUnitTestCaseAdapter((DOMTestCase) test));
        }
        else {
          if(test instanceof DOMTestSuite) {
            TestSuite newsuite = new JUnitTestSuiteAdapter((DOMTestSuite) test);
            suite.addTest(newsuite);
          }
        }
      }
      catch(Exception ex) {
        if(!(ex instanceof DOMTestIncompatibleException)) {
          throw ex;
        }
      }
  }

  private static void printPrologue() {
    System.out.println("DOM Test Adapter for JUnit\n");
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
    try {
      DOMImplementation domimpl = factory.getDOMImplementation();

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
    DocumentBuilderSetting[] settings = dsFactory.getActualSettings();
    for(int i = 0; i < settings.length; i++) {
      System.out.println(settings[i].toString());
    }
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



  public static void main (String[] args) {
    //
    //   SwingUI Test Runner needs -noloading attribute
    //       or there will be problems loading test case
    String[] withNoLoading = new String[args.length+1];
    for(int i = 0; i < args.length; i++) {
        withNoLoading[i+1] = args[i];
    }
    withNoLoading[0] = "-noloading";

    junit.swingui.TestRunner.main(withNoLoading);
  }


}
