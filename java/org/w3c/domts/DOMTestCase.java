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
 $Log: DOMTestCase.java,v $
 Revision 1.16  2003-12-23 03:27:25  dom-ts-4
 Adds fail construct (bug 445)

 Revision 1.15  2003/12/06 06:50:29  dom-ts-4
 More fixes for L&S (Bug 396)

 Revision 1.14  2003/11/18 08:14:55  dom-ts-4
 assertTrue does not accept Object's (bug 380)

 Revision 1.13  2002/07/01 03:57:31  dom-ts-4
 Added name parameter to assertURIEquals

 Revision 1.12  2002/06/03 23:48:48  dom-ts-4
 Support for Events tests

 Revision 1.11  2002/02/03 04:22:35  dom-ts-4
 DOM4J and Batik support added.
 Rework of parser settings

 Revision 1.10  2002/01/30 07:08:44  dom-ts-4
 Update for GNUJAXP

 Revision 1.9  2001/12/10 05:37:21  dom-ts-4
 Added xml_alltests, svg_alltests, and html_alltests suites to run all tests
 using a particular content type.

 Revision 1.8  2001/11/01 15:02:50  dom-ts-4
 Doxygen and Avalon support

 Revision 1.7  2001/10/18 07:58:17  dom-ts-4
 assertURIEquals added
 Can now run from dom1-core.jar

 Revision 1.6  2001/08/30 08:30:18  dom-ts-4
 Added metadata and Software licence (dropped in earlier processing) to test
 Enhanced test-matrix.xsl

 Revision 1.5  2001/08/22 22:12:49  dom-ts-4
 Now passing all tests with default settings

 Revision 1.4  2001/08/22 06:22:46  dom-ts-4
 Updated resource path for IDE debugging

 Revision 1.3  2001/08/20 06:56:35  dom-ts-4
 Full compile (-2 files that lock up Xalan 2.1)

 Revision 1.2  2001/07/23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import org.w3c.dom.*;
import org.w3c.domts.*;
import java.util.*;
import java.net.*;
import java.lang.reflect.*;

/**
 *    This is an abstract base class for generated DOM tests
 */
public abstract class DOMTestCase extends DOMTest  {
  private DOMTestFramework framework;

  /**
   * This constructor is for DOMTestCase's that
   * make specific demands for parser configuration.
   * setFactory should be called before the end of the
   * tests constructor to set the factory.
   */
  public DOMTestCase() {
    framework = null;
  }

  /**
   * This constructor is for DOMTestCase's that
   * do not add any requirements for parser configuration.
   */
  public DOMTestCase(DOMTestDocumentBuilderFactory factory) {
    super(factory);
    framework = null;
  }


  /**
   *   This method is called by the main() for each test and
   *      locates the appropriate test framework and runs the specified test
   */
  public static void doMain(Class testClass,String[] args) {
    //
    //   Attempt to load JUnitRunner
    //
    Class runnerClass = null;
    ClassLoader loader = ClassLoader.getSystemClassLoader();
    Exception classException = null;
    Constructor runnerFactory = null;
    try {
        runnerClass = loader.loadClass("org.w3c.domts.JUnitRunner");
        runnerFactory = runnerClass.getConstructor(new Class[] { Class.class });
    }
    catch(Exception ex) {
        classException = ex;
        try {
            runnerClass = loader.loadClass("org.w3c.domts.AvalonRunner");
            runnerFactory = runnerClass.getConstructor(new Class[] { Class.class });
        }
        catch(Exception ex2) {
            classException = ex2;
        }
    }
    if(runnerClass == null || runnerFactory == null) {
        System.out.println("junit-run.jar amd junit.jar or avalon-run.jar and testlet.jar\n must be in same directory or on classpath.");
        if(classException != null) {
            classException.printStackTrace();
        }
    }
    else {
        try
        {
            //
            //   create the JUnitRunner
            //
            Object junitRun = runnerFactory.newInstance(new Object[] { testClass });
            //
            //   find and call its execute method
            //
            Class argsClass = loader.loadClass("[Ljava.lang.String;");
            Method execMethod = runnerClass.getMethod("execute", new Class[] { argsClass });
            execMethod.invoke(junitRun, new Object[] { args });
        }
        catch(InvocationTargetException ex) {
            ex.getTargetException().printStackTrace();
        }
        catch(Exception ex) {
            ex.printStackTrace();
        }
    }
  }

  abstract public void runTest() throws Throwable;


  public void setFramework(DOMTestFramework framework) {
    this.framework = framework;
  }



  public void wait(int millisecond) {
    framework.wait(millisecond);
  }

  public void fail(String assertID) {
  	framework.fail(this, assertID);
  }
  
  public void assertTrue(String assertID, boolean actual) {
    framework.assertTrue(this,assertID,actual);
  }
  
  public void assertTrue(String assertID, Object actual) {
  	 framework.assertTrue(this, assertID, ((Boolean) actual).booleanValue());
  }

  public void assertFalse(String assertID, boolean actual) {
    framework.assertFalse(this,assertID,actual);
  }
  
  public void assertFalse(String assertID, Object actual) {
  	framework.assertFalse(this, assertID, ((Boolean) actual).booleanValue());
  }

  public void assertNull(String assertID, Object actual) {
    framework.assertNull(this,assertID,actual);
  }

  public void assertNotNull(String assertID, Object actual) {
    framework.assertNotNull(this,assertID,actual);
  }

  public void assertSame(String assertID, Object expected, Object actual) {
    framework.assertSame(this,assertID, expected, actual);
  }

  public void assertInstanceOf(String assertID, Class cls, Object obj) {
    framework.assertInstanceOf(this,assertID, obj,cls);
  }


  public void assertSize(String assertID, int expectedSize, NodeList collection) {
    framework.assertSize(this,assertID, expectedSize, collection);
  }

  public void assertSize(String assertID, int expectedSize, NamedNodeMap collection) {
    framework.assertSize(this, assertID, expectedSize, collection);
  }

  public void assertSize(String assertID, int expectedSize, Collection collection) {
    framework.assertSize(this, assertID, expectedSize, collection);
  }

  public void assertEqualsIgnoreCase(String assertID, String expected, String actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected, actual);
  }

  public void assertEqualsIgnoreCase(String assertID, Collection expected, Collection actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected,actual);
  }

  public void assertEqualsIgnoreCase(String assertID, List expected, List actual) {
    framework.assertEqualsIgnoreCase(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, String expected, String actual) {
    framework.assertEquals(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, int expected, int actual) {
    framework.assertEquals(this, assertID, expected, actual);
  }

  public void assertEquals(String assertID, double expected, double actual) {
    framework.assertEquals(this, assertID, expected,actual);
  }

  public void assertEquals(String assertID, boolean expected, boolean actual) {
    framework.assertEquals(this, assertID, expected,actual);
  }



  public void assertEquals(String assertID, Collection expected, NodeList actual) {
    Collection actualList = new ArrayList();
    int actualLen = actual.getLength();
    for(int i = 0; i < actualLen; i++) {
      actualList.add(actual.item(i));
    }
    framework.assertEquals(this, assertID, expected,actualList);
  }

  public void assertEquals(String assertID, Collection expected, Collection actual) {
    framework.assertEquals(this, assertID,expected,actual);
  }

  public void assertNotEqualsIgnoreCase(String assertID, String expected, String actual) {
    framework.assertNotEqualsIgnoreCase(this, assertID,expected,actual);
  }

  public void assertNotEquals(String assertID, String expected, String actual) {
    framework.assertNotEquals(this, assertID,expected,actual);
  }

  public void assertNotEquals(String assertID, int expected, int actual) {
    framework.assertNotEquals(this, assertID, expected,actual);
  }

  public void assertNotEquals(String assertID, double expected, double actual) {
    framework.assertNotEquals(this, assertID,expected,actual);
  }

  public void assertURIEquals(String assertID, String scheme, String path, String host, String file, String name, String query, String fragment, Boolean isAbsolute, String actual) {
	//
	//  URI must be non-null
	assertNotNull(assertID, actual);

	String uri = actual;

	int lastPound = actual.lastIndexOf("#");
	String actualFragment = "";
	if(lastPound != -1) {
		//
		//   substring before pound
		//
		uri = actual.substring(0,lastPound);
		actualFragment = actual.substring(lastPound+1);
	}
	if(fragment != null) assertEquals(assertID,fragment, actualFragment);

	int lastQuestion = uri.lastIndexOf("?");
	String actualQuery = "";
	if(lastQuestion != -1) {
		//
		//   substring before pound
		//
		uri = actual.substring(0,lastQuestion);
		actualQuery = actual.substring(lastQuestion+1);
	}
	if(query != null) assertEquals(assertID, query, actualQuery);

	int firstColon = uri.indexOf(":");
	int firstSlash = uri.indexOf("/");
	String actualPath = uri;
	String actualScheme = "";
	if(firstColon != -1 && firstColon < firstSlash) {
		actualScheme = uri.substring(0,firstColon);
		actualPath = uri.substring(firstColon + 1);
	}

	if(scheme != null) {
		assertEquals(assertID, scheme, actualScheme);
	}

	if(path != null) {
		assertEquals(assertID, path, actualPath);
	}

	if(host != null) {
		String actualHost = "";
		if(actualPath.startsWith("//")) {
			int termSlash = actualPath.indexOf("/",2);
			actualHost = actualPath.substring(0,termSlash);
		}
		assertEquals(assertID, host, actualHost);
	}

	String actualFile = actualPath;
	if(file != null || name != null) {
		int finalSlash = actualPath.lastIndexOf("/");
		if(finalSlash != -1) {
			actualFile = actualPath.substring(finalSlash+1);
		}
		if (file != null) {
			assertEquals(assertID, file, actualFile);
		}
	}

	if(name != null) {
		String actualName = actualFile;
		int finalPeriod = actualFile.lastIndexOf(".");
		if(finalPeriod != -1) {
			actualName = actualFile.substring(0, finalPeriod);
		}
		assertEquals(assertID, name, actualName);
	}


	if(isAbsolute != null) {
		//
		//   Jar URL's will have any actual path like file:/c:/somedrive...   
		assertEquals(assertID, isAbsolute.booleanValue(), actualPath.startsWith("/") || actualPath.startsWith("file:/"));
	}
  }
  


  public boolean same(Object expected, Object actual) {
    return framework.same(expected,actual);
  }

  public boolean equalsIgnoreCase(String expected, String actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equalsIgnoreCase(Collection expected, Collection actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equalsIgnoreCase(List expected, List actual) {
    return framework.equalsIgnoreCase(expected,actual);
  }

  public boolean equals(String expected, String actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(int expected, int actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(double expected, double actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(Collection expected, Collection actual) {
    return framework.equals(expected,actual);
  }

  public boolean equals(List expected, List actual) {
    return framework.equals(expected,actual);
  }

  public int size(Collection collection) {
    return framework.size(collection);
  }

  public int size(NamedNodeMap collection) {
    return framework.size(collection);
  }

  public int size(NodeList collection) {
    return framework.size(collection);
  }


}

