/*
 * Copyright (c) 2001-2004 World Wide Web Consortium, (Massachusetts Institute
 * of Technology, Institut National de Recherche en Informatique et en
 * Automatique, Keio University). All Rights Reserved. This program is
 * distributed under the W3C's Software Intellectual Property License. This
 * program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See W3C License
 * http://www.w3.org/Consortium/Legal/ for more details.
 */

/*
 * $Log: DOMTestCase.java,v $
 * Revision 1.17  2004-01-06 16:45:42  dom-ts-4
 * Removed obsolete avalon testlet support (bug 400)
 * Revision 1.16 2003/12/23 03:27:25 dom-ts-4 Adds
 * fail construct (bug 445)
 * 
 * Revision 1.15 2003/12/06 06:50:29 dom-ts-4 More fixes for L&S (Bug 396)
 * 
 * Revision 1.14 2003/11/18 08:14:55 dom-ts-4 assertTrue does not accept
 * Object's (bug 380)
 * 
 * Revision 1.13 2002/07/01 03:57:31 dom-ts-4 Added name parameter to
 * assertURIEquals
 * 
 * Revision 1.12 2002/06/03 23:48:48 dom-ts-4 Support for Events tests
 * 
 * Revision 1.11 2002/02/03 04:22:35 dom-ts-4 DOM4J and Batik support added.
 * Rework of parser settings
 * 
 * Revision 1.10 2002/01/30 07:08:44 dom-ts-4 Update for GNUJAXP
 * 
 * Revision 1.9 2001/12/10 05:37:21 dom-ts-4 Added xml_alltests, svg_alltests,
 * and html_alltests suites to run all tests using a particular content type.
 * 
 * Revision 1.8 2001/11/01 15:02:50 dom-ts-4 Doxygen and Avalon support
 * 
 * Revision 1.7 2001/10/18 07:58:17 dom-ts-4 assertURIEquals added Can now run
 * from dom1-core.jar
 * 
 * Revision 1.6 2001/08/30 08:30:18 dom-ts-4 Added metadata and Software
 * licence (dropped in earlier processing) to test Enhanced test-matrix.xsl
 * 
 * Revision 1.5 2001/08/22 22:12:49 dom-ts-4 Now passing all tests with default
 * settings
 * 
 * Revision 1.4 2001/08/22 06:22:46 dom-ts-4 Updated resource path for IDE
 * debugging
 * 
 * Revision 1.3 2001/08/20 06:56:35 dom-ts-4 Full compile (-2 files that lock
 * up Xalan 2.1)
 * 
 * Revision 1.2 2001/07/23 04:52:20 dom-ts-4 Initial test running using JUnit.
 *  
 */

package org.w3c.domts;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.NodeList;

/**
 * This is an abstract base class for generated DOM tests
 */
public abstract class DOMTestCase extends DOMTest {
	private DOMTestFramework framework;

	/**
	 * This constructor is for DOMTestCase's that make specific demands for
	 * parser configuration. setFactory should be called before the end of the
	 * tests constructor to set the factory.
	 */
	public DOMTestCase() {
		framework = null;
	}

	/**
	 * This constructor is for DOMTestCase's that do not add any requirements
	 * for parser configuration.
	 * 
	 * @param factory
	 *            document factory to be used by test, may not be null.
	 */
	public DOMTestCase(DOMTestDocumentBuilderFactory factory) {
		super(factory);
		framework = null;
	}

	/**
	 * This method is called by the main() for each test and locates the
	 * appropriate test framework and runs the specified test
	 * 
	 * @param testClass
	 *            test class
	 * @param args
	 *            arguments to test class
	 */
	public static void doMain(Class testClass, String[] args) {
		//
		//   Attempt to load JUnitRunner
		//
		ClassLoader loader = ClassLoader.getSystemClassLoader();
		try {
			Class runnerClass = loader.loadClass("org.w3c.domts.JUnitRunner");
			Constructor runnerFactory =
				runnerClass.getConstructor(new Class[] { Class.class });
			//
			//   create the JUnitRunner
			//
			Object junitRun =
				runnerFactory.newInstance(new Object[] { testClass });
			//
			//   find and call its execute method method
			//
			Class argsClass = loader.loadClass("[Ljava.lang.String;");
			Method execMethod =
				runnerClass.getMethod("execute", new Class[] { argsClass });
			execMethod.invoke(junitRun, new Object[] { args });
		} catch (InvocationTargetException ex) {
			ex.getTargetException().printStackTrace();
		} catch (Exception ex) {
			System.out.println(
				"junit-run.jar and junit.jar \n must be in same directory or on classpath.");
			ex.printStackTrace();
		}
	}

	/**
	 * Body of test
	 * 
	 * @throws Throwable
	 */
	abstract public void runTest() throws Throwable;

	/**
	 * Sets test framework to be used by test.
	 * 
	 * @param framework
	 */
	public void setFramework(DOMTestFramework framework) {
		this.framework = framework;
	}

	/**
	 * Wait
	 * 
	 * @param millisecond
	 *            milliseconds to wait
	 */
	public void wait(int millisecond) {
		framework.wait(millisecond);
	}

	/**
	 * Fail test
	 * 
	 * @param assertID
	 *            identifier of assertion
	 */
	public void fail(String assertID) {
		framework.fail(this, assertID);
	}

	/**
	 * Asserts that actual==true
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertTrue(String assertID, boolean actual) {
		framework.assertTrue(this, assertID, actual);
	}

	/**
	 * Asserts that actual==true
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertTrue(String assertID, Object actual) {
		framework.assertTrue(this, assertID, ((Boolean) actual).booleanValue());
	}

	/**
	 * Asserts that actual==false
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertFalse(String assertID, boolean actual) {
		framework.assertFalse(this, assertID, actual);
	}

	/**
	 * Asserts that actual==false
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertFalse(String assertID, Object actual) {
		framework.assertFalse(
			this,
			assertID,
			((Boolean) actual).booleanValue());
	}

	/**
	 * Asserts that actual == null
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertNull(String assertID, Object actual) {
		framework.assertNull(this, assertID, actual);
	}

	/**
	 * Asserts that actual != null
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertNotNull(String assertID, Object actual) {
		framework.assertNotNull(this, assertID, actual);
	}

	/**
	 * Asserts that actual and expected are the same object
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 */
	public void assertSame(String assertID, Object expected, Object actual) {
		framework.assertSame(this, assertID, expected, actual);
	}

	/**
	 * Asserts that obj is an instance of cls
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param obj
	 *            object
	 * @param cls
	 *            class, may not be null.
	 */
	public void assertInstanceOf(String assertID, Class cls, Object obj) {
		framework.assertInstanceOf(this, assertID, obj, cls);
	}

	/**
	 * Asserts that the length of the collection is the expected size.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param expectedSize
	 *            expected size
	 * @param collection
	 *            collection
	 */
	public void assertSize(
		String assertID,
		int expectedSize,
		NodeList collection) {
		framework.assertSize(this, assertID, expectedSize, collection);
	}

	/**
	 * Asserts that the length of the collection is the expected size.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param expectedSize
	 *            expected size
	 * @param collection
	 *            collection
	 */
	public void assertSize(
		String assertID,
		int expectedSize,
		NamedNodeMap collection) {
		framework.assertSize(this, assertID, expectedSize, collection);
	}

	/**
	 * Asserts that the length of the collection is the expected size.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param expectedSize
	 *            expected size
	 * @param collection
	 *            collection
	 */
	public void assertSize(
		String assertID,
		int expectedSize,
		Collection collection) {
		framework.assertSize(this, assertID, expectedSize, collection);
	}

	/**
	 * Asserts that expected.equalsIgnoreCase(actual) is true
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEqualsIgnoreCase(
		String assertID,
		String expected,
		String actual) {
		framework.assertEqualsIgnoreCase(this, assertID, expected, actual);
	}

	/**
	 * Asserts that each entry in actual is matched with an entry in expected
	 * that only differs by case. Order is not significant.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEqualsIgnoreCase(
		String assertID,
		Collection expected,
		Collection actual) {
		framework.assertEqualsIgnoreCase(this, assertID, expected, actual);
	}

	/**
	 * Asserts that each entry in actual is matched with an entry in expected
	 * that only differs by case. Order is significant.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEqualsIgnoreCase(
		String assertID,
		List expected,
		List actual) {
		framework.assertEqualsIgnoreCase(this, assertID, expected, actual);
	}

	/**
	 * Asserts that expected.equals(actual) is true
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(String assertID, String expected, String actual) {
		framework.assertEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(String assertID, int expected, int actual) {
		framework.assertEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(String assertID, double expected, double actual) {
		framework.assertEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(
		String assertID,
		boolean expected,
		boolean actual) {
		framework.assertEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that each entry in actual exactly matches with an entry in
	 * expected. Order is not significant.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(
		String assertID,
		Collection expected,
		NodeList actual) {
		Collection actualList = new ArrayList();
		int actualLen = actual.getLength();
		for (int i = 0; i < actualLen; i++) {
			actualList.add(actual.item(i));
		}
		framework.assertEquals(this, assertID, expected, actualList);
	}

	/**
	 * Asserts that each entry in actual exactly matches with an entry in
	 * expected. Order is not significant.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertEquals(
		String assertID,
		Collection expected,
		Collection actual) {
		framework.assertEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that expected.equalsIgnoreCase(actual) is false
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertNotEqualsIgnoreCase(
		String assertID,
		String expected,
		String actual) {
		framework.assertNotEqualsIgnoreCase(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are not equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertNotEquals(
		String assertID,
		String expected,
		String actual) {
		framework.assertNotEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are not equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertNotEquals(String assertID, int expected, int actual) {
		framework.assertNotEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts that values of expected and actual are not equal.
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param actual
	 *            actual value
	 * @param expected
	 *            Expected value, may not be null.
	 */
	public void assertNotEquals(
		String assertID,
		double expected,
		double actual) {
		framework.assertNotEquals(this, assertID, expected, actual);
	}

	/**
	 * Asserts aspects of a URI
	 * 
	 * @param assertID
	 *            identifier of assertion
	 * @param scheme
	 *            Expected scheme, for example, "file". If null, scheme is
	 *            ignored.
	 * @param path
	 *            Expected path, for example, "/DOM/Test". If null, path is
	 *            ignored.
	 * @param host
	 *            Expected host, for example, "www.w3.org". If null, host is
	 *            ignored.
	 * @param file
	 *            Expected file, for example, "staff.xml". If null, file is
	 *            ignored.
	 * @param name
	 *            Expected name, for example, "staff". If null, name is
	 *            ignored.
	 * @param name
	 *            Expected name, for example, "staff". If null, name is
	 *            ignored.
	 * @param isAbsolute
	 *            if Boolean.TRUE, URI must be absolute. Null indicates no
	 *            assertion.
	 * @param actual
	 *            URI to be tested.
	 */
	public void assertURIEquals(
		String assertID,
		String scheme,
		String path,
		String host,
		String file,
		String name,
		String query,
		String fragment,
		Boolean isAbsolute,
		String actual) {
		//
		//  URI must be non-null
		assertNotNull(assertID, actual);

		String uri = actual;

		int lastPound = actual.lastIndexOf("#");
		String actualFragment = "";
		if (lastPound != -1) {
			//
			//   substring before pound
			//
			uri = actual.substring(0, lastPound);
			actualFragment = actual.substring(lastPound + 1);
		}
		if (fragment != null)
			assertEquals(assertID, fragment, actualFragment);

		int lastQuestion = uri.lastIndexOf("?");
		String actualQuery = "";
		if (lastQuestion != -1) {
			//
			//   substring before pound
			//
			uri = actual.substring(0, lastQuestion);
			actualQuery = actual.substring(lastQuestion + 1);
		}
		if (query != null)
			assertEquals(assertID, query, actualQuery);

		int firstColon = uri.indexOf(":");
		int firstSlash = uri.indexOf("/");
		String actualPath = uri;
		String actualScheme = "";
		if (firstColon != -1 && firstColon < firstSlash) {
			actualScheme = uri.substring(0, firstColon);
			actualPath = uri.substring(firstColon + 1);
		}

		if (scheme != null) {
			assertEquals(assertID, scheme, actualScheme);
		}

		if (path != null) {
			assertEquals(assertID, path, actualPath);
		}

		if (host != null) {
			String actualHost = "";
			if (actualPath.startsWith("//")) {
				int termSlash = actualPath.indexOf("/", 2);
				actualHost = actualPath.substring(0, termSlash);
			}
			assertEquals(assertID, host, actualHost);
		}

		String actualFile = actualPath;
		if (file != null || name != null) {
			int finalSlash = actualPath.lastIndexOf("/");
			if (finalSlash != -1) {
				actualFile = actualPath.substring(finalSlash + 1);
			}
			if (file != null) {
				assertEquals(assertID, file, actualFile);
			}
		}

		if (name != null) {
			String actualName = actualFile;
			int finalPeriod = actualFile.lastIndexOf(".");
			if (finalPeriod != -1) {
				actualName = actualFile.substring(0, finalPeriod);
			}
			assertEquals(assertID, name, actualName);
		}

		if (isAbsolute != null) {
			//
			//   Jar URL's will have any actual path like file:/c:/somedrive...
			assertEquals(
				assertID,
				isAbsolute.booleanValue(),
				actualPath.startsWith("/") || actualPath.startsWith("file:/"));
		}
	}

	/**
	 * Compares the identity of actual and expected.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are the same object.
	 */
	public boolean same(Object expected, Object actual) {
		return framework.same(expected, actual);
	}

	/**
	 * Compares the value of actual and expected ignoring case.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal ignoring case.
	 */
	public boolean equalsIgnoreCase(String expected, String actual) {
		return framework.equalsIgnoreCase(expected, actual);
	}

	/**
	 * Compares the values in actual and expected ignoring case and order.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal ignoring case.
	 */
	public boolean equalsIgnoreCase(Collection expected, Collection actual) {
		return framework.equalsIgnoreCase(expected, actual);
	}

	/**
	 * Compares the values in actual and expected ignoring case.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal ignoring case.
	 */
	public boolean equalsIgnoreCase(List expected, List actual) {
		return framework.equalsIgnoreCase(expected, actual);
	}

	/**
	 * Compares the values of actual and expected.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal.
	 */
	public boolean equals(String expected, String actual) {
		return framework.equals(expected, actual);
	}

	/**
	 * Compares the values of actual and expected.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal.
	 */
	public boolean equals(int expected, int actual) {
		return framework.equals(expected, actual);
	}

	/**
	 * Compares the values of actual and expected.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal.
	 */
	public boolean equals(double expected, double actual) {
		return framework.equals(expected, actual);
	}

	/**
	 * Compares the values in actual and expected ignoring order.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal.
	 */
	public boolean equals(Collection expected, Collection actual) {
		return framework.equals(expected, actual);
	}

	/**
	 * Compares the values in actual and expected.
	 * 
	 * @param expected
	 *            expected
	 * @param actual
	 *            actual
	 * @return true if actual and expected are equal.
	 */
	public boolean equals(List expected, List actual) {
		return framework.equals(expected, actual);
	}

	/**
	 * Gets the size of the collection
	 * 
	 * @param collection
	 *            collection, may not be null.
	 * @return size of collection
	 */
	public int size(Collection collection) {
		return framework.size(collection);
	}

	/**
	 * Gets the size of the collection
	 * 
	 * @param collection
	 *            collection, may not be null.
	 * @return size of collection
	 */
	public int size(NamedNodeMap collection) {
		return framework.size(collection);
	}

	/**
	 * Gets the size of the collection
	 * 
	 * @param collection
	 *            collection, may not be null.
	 * @return size of collection
	 */
	public int size(NodeList collection) {
		return framework.size(collection);
	}

}
