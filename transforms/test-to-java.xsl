<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (c) 2001 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<!--   
This transform generates Java source code from a language independent
test representation.

This transform requires an auxiliary file "interfaces.xml" that 
is produced by applying "extract.xsl" to the appropriate DOM
specificiation.


Usage:

saxon -o someTest.java someTest.xml test-to-java.xsl


-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--  relative to transform   -->
	<xsl:param name="interfaces-docname"/>

<xsl:output method="text"/>
<xsl:variable name="domspec" select="document($interfaces-docname)"/>

<xsl:template match="/">
	<xsl:apply-templates/>
</xsl:template>

<!--   when encountering a test   -->
<xsl:template match="*[local-name()='test']">
<xsl:choose>
	<xsl:when test="@package">
package <xsl:value-of select="@package"/>;
	</xsl:when>
	<xsl:otherwise>
package org.w3c.domts.level1.core;
	</xsl:otherwise>
</xsl:choose>

import org.w3c.dom.*;
<xsl:if test="*[local-name() = 'hasFeature' and @feature='Events']">
import org.w3c.dom.events;
</xsl:if>
import org.w3c.domts.*;
import javax.xml.parsers.*;
import java.util.*;

<!--  if there is a metadata child element then
          produce documentation comments    -->
<xsl:for-each select="*[local-name()='metadata']">
/**
* <xsl:value-of select="*[local-name()='description']"/><xsl:text>
</xsl:text>

<xsl:for-each select="*[local-name()='creator']">
<xsl:text>* @author </xsl:text><xsl:value-of select="."/><xsl:text>
</xsl:text>
</xsl:for-each>

<xsl:for-each select="*[local-name()='contributor']">
<xsl:text>* @author </xsl:text><xsl:value-of select="."/><xsl:text>
</xsl:text>
</xsl:for-each>

<xsl:for-each select="*[local-name()='subject']">
<xsl:text>* @see &lt;a href="</xsl:text><xsl:value-of select="@resource"/>"&gt;<xsl:value-of select="@resource"/><xsl:text>&lt;/a&gt;
</xsl:text>
</xsl:for-each>

<xsl:for-each select="*[local-name()='source']">
<xsl:text>* @see &lt;a href="</xsl:text><xsl:value-of select="@resource"/>"&gt;<xsl:value-of select="@resource"/><xsl:text>&lt;/a&gt;
</xsl:text>
</xsl:for-each>
<xsl:text>*/
</xsl:text>
</xsl:for-each>
public class <xsl:value-of select="@name"/> extends DOMTestCase {
   public void runTest(DOMTestFramework _framework) throws java.lang.Throwable {
	<xsl:apply-templates mode="body"/>
   }
   public static void buildSuite(DocumentBuilderFactory factory,DOMImplementation domImpl,DOMTestSuite suite) {
	 DOMTestCase test = new <xsl:value-of select="@name"/>();
	 if(test.isCompatible(factory,domImpl)) {
	 	suite.addTest(test);
	 } 
   }
   public boolean isCompatible(DocumentBuilderFactory factory, DOMImplementation domImpl) {
	  boolean retval = true;
	  <xsl:apply-templates mode="testConditions">
	      <xsl:with-param name="operator"></xsl:with-param>
	  </xsl:apply-templates>
      return retval;
   }
   public void setAttributes(DocumentBuilderFactory factory) {
	  <xsl:apply-templates mode="setAttributes">
	      <xsl:with-param name="value">true</xsl:with-param>
	  </xsl:apply-templates>
   }
   public String getTargetURI() {
		return "<xsl:value-of select="@targetURI"/>";
   }
}
</xsl:template>

<!--   
		The following templates generate the body of isCompatible()
       function which returns true if the test is compatible
	   with the current settings of the DocumentBuilderFactory
	   and the implementation.

	   If isCompatible() returns false, the test will not be run.
	   
-->

<!--  in the conditions mode, almost everything emits no code  -->
<xsl:template match="*" mode="testConditions"/>
<xsl:template match="text()" mode="testConditions"/>

<xsl:template match="*[local-name()='validating']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isValidating();
</xsl:template>

<xsl:template match="*[local-name()='coalescing']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isCoalescing();
</xsl:template>

<xsl:template match="*[local-name()='expandEntityReferences']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isExpandEntityReferences();
</xsl:template>

<xsl:template match="*[local-name()='ignoringElementContentWhitespace']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isIgnoringElementContentWhitespace();
</xsl:template>

<xsl:template match="*[local-name()='ignoringComments']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isIgnoringComments();
</xsl:template>

<xsl:template match="*[local-name()='namespaceAware']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>factory.isNamespaceAware();
</xsl:template>

<xsl:template match="*[local-name()='hasFeature']" mode="testConditions">
	<!--
	       This should not produce if has-feature appears in the body of the test
	-->
	<xsl:param name="operator"/>
	<xsl:if test="not(preceding-sibling::var)">
	retval &amp;= <xsl:value-of select="$operator"/>domImpl.hasFeature("<xsl:value-of select="@feature"/>"
	<xsl:choose>
		<xsl:when test="@version">
			<xsl:text>,"</xsl:text><xsl:value-of select="@version"/><xsl:text>");
</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>,null);
</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	</xsl:if>
</xsl:template>

<!--  Java implementations are always signed   -->
<xsl:template match="*[local-name()='signed']" mode="testConditions">
	<xsl:param name="operator"/>
	retval &amp;= <xsl:value-of select="$operator"/>true;
</xsl:template>

<xsl:template match="*[local-name()='not']" mode="testConditions">
	<xsl:apply-templates mode="testConditions">
		<xsl:with-param name="operator">!</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>
	

<!--   
	   The following templates generate the body of setAttributes()
       function which attempts to change the properties of the
       DocumentBuilderFactory to be compatible with the test.	   
-->

<xsl:template match="*" mode="setAttributes"/>
<xsl:template match="text()" mode="setAttributes"/>

<xsl:template match="*[local-name()='validating']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setValidating(<xsl:value-of select="@value"/>);
</xsl:template>

<xsl:template match="*[local-name()='coalescing']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setCoalescing(<xsl:value-of select="@value"/>);
</xsl:template>

<xsl:template match="*[local-name()='expandEntityReferences']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setExpandEntityReferences(<xsl:value-of select="@value"/>);
</xsl:template>

<xsl:template match="*[local-name()='ignoringElementContentWhitespace']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setIgnoringElementContentWhitespace(<xsl:value-of select="@value"/>);
</xsl:template>

<xsl:template match="*[local-name()='ignoringComments']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setComments(<xsl:value-of select="@value"/>);
</xsl:template>

<xsl:template match="*[local-name()='namespaceAware']" mode="setAttributes">
	<xsl:param name="value"/>
	factory.setNamespaceAware(<xsl:value-of select="@value"/>);
</xsl:template>


<xsl:template match="*[local-name()='not']" mode="setAttributes">
	<xsl:apply-templates mode="setAttributes">
		<xsl:with-param name="value">false</xsl:with-param>
	</xsl:apply-templates>
</xsl:template>


<!--    
    The following templates generate the body of the test function   
    
-->

<!--

    Implementation conditions and metadata elements produce nothing
	in the body of the test method

-->
<xsl:template match="*[local-name()='metadata']" mode="body"/>
<xsl:template match="*[local-name()='validating']" mode="body"/>
<xsl:template match="*[local-name()='coalescing']" mode="body"/>
<xsl:template match="*[local-name()='expandEntityReferences']" mode="body"/>
<xsl:template match="*[local-name()='ignoringElementContentWhitespace']" mode="body"/>
<xsl:template match="*[local-name()='ignoringComments']" mode="body"/>
<xsl:template match="*[local-name()='namespaceAware']" mode="body"/>
<xsl:template match="*[local-name()='signed']" mode="body"/>
<xsl:template match="*[local-name()='not']" mode="body"/>

<!--  
     hasFeature is a little unusual as both an implementation
	 condition and a DOM function.  This template should only
	 produce code when used as a DOM function.
-->
<xsl:template match="*[local-name()='hasFeature']" mode="body">
	<!--  if it doesn't have a var then 
			it is part of the implementation conditions and
			should not be produced in the body of the function  -->
	<xsl:if test="@var">
		<xsl:value-of select="@var"/>
		<xsl:text> = </xsl:text>
		<!--  use @obj if provided, otherwise _framework   -->
		<xsl:choose>
			<xsl:when test="@obj">
				<xsl:value-of select="@obj"/> 
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>_framework</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>.hasFeature("</xsl:text>
		<xsl:value-of select="@feature"/>
		<xsl:text>",</xsl:text>
		<xsl:choose>
			<xsl:when test="@version">
				<xsl:text>"</xsl:text><xsl:value-of select="@version"/><xsl:text>"</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>null</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>);
</xsl:text>
	</xsl:if>
</xsl:template>


<!--    

	test framework constructs

-->
<xsl:template match="*[local-name()='var']" mode="body">
	<xsl:variable name="varname" select="@name"/>
	<xsl:apply-templates select="@type"/><xsl:text> </xsl:text><xsl:value-of select="$varname"/>
	<xsl:choose>
		<!--  explict value, just add it  -->
		<xsl:when test="@value"> = <xsl:apply-templates select="@value"/>;</xsl:when>
		<!--  member, allocate collection or list and populate it  -->
		<xsl:when test="@type='List' or @type='Collection'">
			<xsl:text> = new ArrayList();
</xsl:text>
			<xsl:for-each select="*[local-name()='member']">
     			<xsl:value-of select="$varname"/><xsl:text>.add(</xsl:text>
				<xsl:choose>
					<!--  member is not a number, just add it to collection  -->
					<xsl:when test="string(number(text())) = 'NaN'">
						<xsl:value-of select="text()"/>
					</xsl:when>
					<!--   if a decimal point, add it as a Double   -->
					<xsl:when test="contains(text(),'.')">
						<xsl:text>new Double(</xsl:text>
						<xsl:value-of select="text()"/>
						<xsl:text>)</xsl:text>
					</xsl:when>
					<!--   otherwise an Integer   -->
					<xsl:otherwise>
						<xsl:text>new Integer(</xsl:text>
						<xsl:value-of select="text()"/>
						<xsl:text>)</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text>);
</xsl:text>
			</xsl:for-each>
		</xsl:when>
		<!--  virtual method  -->
		<xsl:when test="*">
			<xsl:text> = new </xsl:text><xsl:apply-templates select="@type"/> {
				<xsl:apply-templates mode="anonInner"/>
			};
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>
    </xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='comment']" mode="body">
	<xsl:text>/* </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text> */
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='wait']" mode="body">
	<xsl:text>_framework.wait(</xsl:text>
	<xsl:value-of select="@milliseconds"/>
	<xsl:text>);
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='append']" mode="body">
	<xsl:value-of select="@collection"/>
	<xsl:text>.add(</xsl:text>
	<xsl:variable name="obj" select="@obj"/>
	<xsl:variable name="type" select="ancestor::*[local-name()='test']/*[local-name()='var' and @name=$obj]/@type"/>
	<xsl:choose>
		<xsl:when test="$type = 'int'">
			<xsl:text>new Integer(</xsl:text>
			<xsl:value-of select="@obj"/>
			<xsl:text>));</xsl:text>
		</xsl:when>
		<xsl:when test="$type = 'double'">
			<xsl:text>new Double(</xsl:text>
			<xsl:value-of select="@obj"/>
			<xsl:text>));</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="@obj"/>
			<xsl:text>);</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='assign']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:choose>
		<xsl:when test="substring(@value,1,1) = '&quot;' or string(number(@value)) != 'NaN'">
			<xsl:value-of select="@value"/>
			<xsl:text>;
</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="var" select="@var"/>
			<xsl:variable name="value" select="@value"/>
			<xsl:call-template name="retval-cast">
				<xsl:with-param name="variable" select="@var"/>
				<xsl:with-param name="vartype" select="ancestor::*[local-name()='test']/*[local-name() = 'var' and @name = $var]/@type"/>
				<xsl:with-param name="rettype" select="ancestor::*[local-name()='test']/*[local-name() = 'var' and @name = $value]/@type"/>
			</xsl:call-template>
			<xsl:text> </xsl:text>
			<xsl:value-of select="@value"/>
			<xsl:text>;
</xsl:text>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="*[local-name()='increment']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> += </xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>;
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='decrement']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> -= </xsl:text>
	<xsl:value-of select="@value"/>
	<xsl:text>;
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='plus']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:value-of select="@op1"/>
	<xsl:text> + </xsl:text>
	<xsl:value-of select="@op2"/>
	<xsl:text>;
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='subtract']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:value-of select="@op1"/>
	<xsl:text> - </xsl:text>
	<xsl:value-of select="@op2"/>
	<xsl:text>;
</xsl:text>
</xsl:template>


<xsl:template match="*[local-name()='multiply']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:value-of select="@op1"/>
	<xsl:text> * </xsl:text>
	<xsl:value-of select="@op2"/>
	<xsl:text>;
</xsl:text>
</xsl:template>


<xsl:template match="*[local-name()='divide']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:value-of select="@op1"/>
	<xsl:text> / </xsl:text>
	<xsl:value-of select="@op2"/>
	<xsl:text>;
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='handleEvent']" mode="anonInner">
<xsl:text>boolean handleEvent(
		org.w3c.dom.events.EventListener listener, 
		org.w3c.dom.events.Events evt,
		org.w3c.dom.events.EventTarget currentTarget,
		Object userObj) {
</xsl:text>
	<xsl:apply-templates mode="body"/>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='implementation']" mode="body">
	<xsl:value-of select="@var"/>
	<xsl:text> = </xsl:text>
	<xsl:choose>
		<xsl:when test="@obj">
			<xsl:value-of select="@obj"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>_framework</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>.getImplementation();
</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='assertTrue']" mode="body">
	<xsl:param name="type"/>
	<xsl:choose>
		<xsl:when test="@actual">
			<xsl:text>_framework.assertTrue("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@actual"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(</xsl:text>
				<xsl:value-of select="@actual"/>
				<xsl:text>) {
</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
	_framework.assertTrue(
		"<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
		"<xsl:value-of select="@id"/>",
		<xsl:apply-templates select="*[1]" mode="condition"/><xsl:text>);
</xsl:text>
	<xsl:if test="count(*) &gt; 1">
	if(<xsl:apply-templates select="*[1]" mode="condition"/>) {
		<xsl:apply-templates select="*[position() &gt; 1]" mode="body"/>
	}
</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="*[local-name()='assertFalse']" mode="body">
	<xsl:param name="type"/>
	<xsl:choose>
		<xsl:when test="@actual">
			<xsl:text>_framework.assertFalse("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@actual"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(!</xsl:text>
				<xsl:value-of select="@actual"/>
				<xsl:text>) {</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			{
			<xsl:text>_framework.assertFalse("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:apply-templates select="*[1]" mode="condition"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="count(*) &gt; 1">
    if(!<xsl:apply-templates select="*[1]" mode="condition"/>) {
<xsl:apply-templates mode="body"/>
    }
</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[local-name()='assertNull']" mode="body">
	<xsl:text>_framework.assertNull("</xsl:text>
	<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>
	<xsl:text>",</xsl:text>
	"<xsl:value-of select="@id"/>",
	<xsl:value-of select="@actual"/>
	<xsl:text>);
</xsl:text>
	<xsl:if test="*">
		<xsl:text>if(</xsl:text>
		<xsl:value-of select="@actual"/>
		<xsl:text> == null) {</xsl:text>
		<xsl:apply-templates mode="body"/>
		<xsl:text>}
</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="*[local-name()='assertNotNull']" mode="body">
	<xsl:text>_framework.assertNotNull("</xsl:text>
	<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
	"<xsl:value-of select="@id"/>",
	<xsl:value-of select="@actual"/>
	<xsl:text>);
</xsl:text>
	<xsl:if test="*">
		<xsl:text>if(</xsl:text>
		<xsl:value-of select="@actual"/>
		<xsl:text> != null) {</xsl:text>
		<xsl:apply-templates mode="body"/>
		<xsl:text>}
</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="*[local-name()='assertSame']" mode="body">
	<xsl:text>_framework.assertSame(</xsl:text>
	<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
	"<xsl:value-of select="@id"/>",
	<xsl:value-of select="@expected"/>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="@actual"/>
	<xsl:text>);
</xsl:text>
	<xsl:if test="count(*) &gt; 0">
		<xsl:text>if(_framework.same(</xsl:text>
		<xsl:value-of select="@expected"/>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="@actual"/>
		<xsl:text>)) {</xsl:text>
		<xsl:apply-templates mode="body"/>
		<xsl:text>}
</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="*[local-name()='assertInstanceOf']" mode="body">
	<xsl:text>_framework.assertInstanceOf(</xsl:text>
	<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
	"<xsl:value-of select="@id"/>",
	<xsl:call-template name="produce-type">
		<xsl:with-param name="type" select="@expected"/>
	</xsl:call-template>
	<xsl:text>,</xsl:text>
	<xsl:value-of select="@actual"/>
	<xsl:text>);
</xsl:text>
	<xsl:if test="*">
		<xsl:text>if(</xsl:text>
		<xsl:value-of select="@actual"/>
		<xsl:text> instanceof </xsl:text>
		<xsl:call-template name="produce-type">
			<xsl:with-param name="type" select="@expected"/>
		</xsl:call-template>
		<xsl:text>) {</xsl:text>
		<xsl:apply-templates mode="body"/>
		<xsl:text>}
</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="*[local-name()='assertSize']" mode="body">
    _framework.assertSize(
		"<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
		"<xsl:value-of select="@id"/>",
		<xsl:value-of select="@size"/>,
		<xsl:value-of select="@collection"/>);
<xsl:if test="*">
    if(_framework.size(<xsl:value-of select="@collection"/>) == <xsl:value-of select="@size"/>) {
<xsl:apply-templates mode="body"/>
    }
</xsl:if>
</xsl:template>

<xsl:template match="*[local-name()='assertEquals']" mode="body">
	<xsl:choose>
		<xsl:when test="@ignoreCase = 'true'">
			<xsl:text>_framework.assertEqualsIgnoreCase("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@expected"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="@actual"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(_framework.equalsIgnoreCase(</xsl:text>
				<xsl:value-of select="@expected"/>
				<xsl:text>,</xsl:text>
				<xsl:value-of select="@actual"/>
				<xsl:text>)) {
</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>_framework.assertEquals("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>
			<xsl:text>",</xsl:text>
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@expected"/>,
			<xsl:value-of select="@actual"/><xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(_framework.equals(</xsl:text>
				<xsl:value-of select="@expected"/>,
				<xsl:value-of select="@actual"/>
				<xsl:text>)) {
</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="*[local-name()='assertNotEquals']" mode="body">
	<xsl:choose>
		<xsl:when test="@ignoreCase = 'true'">
			<xsl:text>_framework.assertNotEqualsIgnoreCase("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@expected"/>,
			<xsl:value-of select="@actual"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(!_framework.equals(</xsl:text>
				<xsl:value-of select="@expected"/>
				<xsl:text>,</xsl:text>
				<xsl:value-of select="@actual"/>
				<xsl:text>)) {
</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>_framework.assertNotEquals("</xsl:text>
			<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			<xsl:value-of select="@expected"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="@actual"/>
			<xsl:text>);
</xsl:text>
			<xsl:if test="*">
				<xsl:text>if(!_framework.equals(</xsl:text>
				<xsl:value-of select="@expected"/>
				<xsl:text>,</xsl:text>
				<xsl:value-of select="@actual"/>
				<xsl:text>)) {
</xsl:text>
				<xsl:apply-templates mode="body"/>
				<xsl:text>}
</xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[local-name()='assertEventCount']" mode="body">
	<xsl:text>{
	boolean _tmpBool = true;
</xsl:text>
	<xsl:if test="@atCount">
		<xsl:text>_tmpBool &amp;= (</xsl:text>
		<xsl:value-of select="@monitor"/>
		<xsl:text>.getAtCount() == </xsl:text>
		<xsl:value-of select="@atCount"/>
		<xsl:text>);
</xsl:text>
	</xsl:if>
	<xsl:if test="@captureCount">
		<xsl:text>_tmpBool &amp;= (</xsl:text>
		<xsl:value-of select="@monitor"/>
		<xsl:text>.getCaptureCount() == </xsl:text>
		<xsl:value-of select="@captureCount"/>
		<xsl:text>);
</xsl:text>
	</xsl:if>
	<xsl:if test="@bubbleCount">
		<xsl:text>_tmpBool &amp;= (</xsl:text>
		<xsl:value-of select="@monitor"/>
		<xsl:text>.getBubbleCount() == </xsl:text>
		<xsl:value-of select="@BubbleCount"/>
		<xsl:text>);
</xsl:text>
	</xsl:if>
	<xsl:if test="@totalCount">
		<xsl:text>_tmpBool &amp;= (</xsl:text>
		<xsl:value-of select="@monitor"/>
		<xsl:text>.getTotalCount() == </xsl:text>
		<xsl:value-of select="@totalCount"/>
		<xsl:text>);
</xsl:text>
	</xsl:if>
	<xsl:text>_framework.assertTrue("</xsl:text>
	<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
	"<xsl:value-of select="@id"/>"
	<xsl:text>,_tmpBool);
</xsl:text>
	<xsl:if test="*">
		<xsl:text>if(_tmpBool) {
</xsl:text>
		<xsl:apply-templates mode="body"/>
		<xsl:text>}
</xsl:text>
	</xsl:if>
	<xsl:text>}</xsl:text>
</xsl:template>


<xsl:template match="*[local-name()='if']" mode="body">
	if(
	<xsl:apply-templates select="*[1]" mode="condition"/>
	) {
	<xsl:apply-templates select="*[position() &gt; 1]" mode="body"/>
	}
	<xsl:for-each select="*[local-name()='else']">
		else {
			<xsl:apply-templates mode="body"/>
		}
	</xsl:for-each>
</xsl:template>

<xsl:template match="*[local-name()='while']" mode="body">
    while(
	<xsl:apply-templates select="*[1]" mode="condition"/>
	) {
	<xsl:apply-templates select="*[position() &gt; 1]" mode="body"/>
	}
</xsl:template>

<xsl:template match="*[local-name()='for-each']" mode="body">
    <xsl:text>for(int _index = 0; _index &lt; </xsl:text>
	<xsl:variable name="varname" select="@collection"/>
	<xsl:value-of select="@collection"/>
	<xsl:choose>
		<xsl:when test="ancestor::*[local-name()='test']/var[@name=$varname]/@type='Collection'">
			<xsl:text>.size();</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>.getLength();</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
    <xsl:text>_index++) {
</xsl:text>
	<xsl:value-of select="@member"/> = <xsl:value-of select="@collection"/>.item(_index);
	<xsl:apply-templates select="*" mode="body"/>
	}
</xsl:template>


<xsl:template match="*[local-name()='EventMonitor.setUserObj']" mode="body">
	<xsl:value-of select="@obj"/>.setUserObj(<xsl:value-of select="@userObj"/>);
</xsl:template>

<xsl:template match="*[local-name()='EventMonitor.getAtEvents']" mode="body">
	<xsl:value-of select="@var"/> = <xsl:value-of select="@monitor"/>.getAtEvents();
</xsl:template>


<xsl:template match="*[local-name()='EventMonitor.getCaptureEvents']" mode="body">
	<xsl:value-of select="@var"/> = <xsl:value-of select="@monitor"/>.getCaptureEvents();
</xsl:template>

<xsl:template match="*[local-name()='EventMonitor.getBubbleEvents']" mode="body">
	<xsl:value-of select="@var"/> = <xsl:value-of select="@monitor"/>.getBubbleEvents();
</xsl:template>


<xsl:template match="*[local-name()='EventMonitor.getAllEvents']" mode="body">
	<xsl:value-of select="@var"/> = <xsl:value-of select="@monitor"/>.getAddEvents();
</xsl:template>

<xsl:template name="produce-type">
	<xsl:param name="type"/>
	<xsl:choose>
		<xsl:when test="contains($type,'DOMString')">String</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$type"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@type">
	<xsl:call-template name="produce-type">
		<xsl:with-param name="type" select="."/>
	</xsl:call-template>
</xsl:template>

<!--  this builds an override for the handleEvent method of EventMonitor  -->
<xsl:template match="*[local-name()='handleEvent']" mode="anonInner">
void handleEvent(EventListener listener, Event event, Object userObj) {
<xsl:apply-templates mode="body"/>
}
</xsl:template>

<xsl:template match="*[local-name()='load']" mode="body">
	<xsl:value-of select="@var"/> = _framework.load("<xsl:value-of select="@href"/>");
</xsl:template>

<xsl:template match="*[local-name()='assertDOMException']" mode="body">
	{
		boolean success = false;
		try {
			<xsl:apply-templates select="*/*" mode="body"/>
		}
		catch(DOMException ex) {
			success = (ex.code == DOMException.<xsl:value-of select="name(*)"/>);
		}
		_framework.assertTrue(
			"<xsl:value-of select="ancestor::*[local-name()='test']/@targetURI"/>",
			"<xsl:value-of select="@id"/>",
			success);
	}
</xsl:template>

<xsl:template match="text()" mode="body"/>

<xsl:template match="*" mode="body">
	<xsl:variable name="feature" select="local-name(.)"/>
	<xsl:variable name="method" select="$domspec/library/interface/method[@name = $feature]"/>
	<xsl:choose>
		<xsl:when test="$method">
			<xsl:call-template name="produce-method">
				<xsl:with-param name="method" select="$method"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="attribute" select="$domspec/library/interface/attribute[@name = $feature]"/>
			<xsl:choose>
				<xsl:when test="$attribute">
					<xsl:call-template name="produce-attribute"/>
				</xsl:when>

				<xsl:otherwise>
					<xsl:message>Unrecognized element <xsl:value-of select="local-name(.)"/></xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>
    </xsl:text>
</xsl:template>

<xsl:template name="cast">
	<xsl:param name="var"/>
	<xsl:param name="vartype"/>
	<xsl:param name="reqtype"/>
	<xsl:choose>
		<!--  variable is already appropriate type  -->
		<xsl:when test="$vartype = $reqtype">
			<xsl:value-of select="$var"/>
		</xsl:when>
		<!--  if the vartype inherits from another interface, see if it matches the required type  -->
		<xsl:when test="$domspec/library/interface[@name = $vartype and @inherits]">
			<xsl:call-template name="cast">
				<xsl:with-param name="var" select="$var"/>
				<xsl:with-param name="vartype" select="$domspec/library/interface[@name = $vartype]/@inherits"/>
				<xsl:with-param name="reqtype" select="$reqtype"/>
			</xsl:call-template>
		</xsl:when>

		<!--  cast and hope for the best  -->		
		<xsl:otherwise>
			<xsl:text>((</xsl:text><xsl:value-of select="$reqtype"/>)<xsl:value-of select="$var"/><xsl:text>)</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="retval-cast">
	<xsl:param name="vartype"/>
	<xsl:param name="rettype"/>
	<xsl:param name="variable"/>
	<xsl:choose>
		<!--  left hand side variable not declared   -->
		<xsl:when test="not($vartype)">
			<xsl:message>Variable <xsl:value-of select="$variable"/> not defined.</xsl:message>
		</xsl:when>
		<!--  variable is already appropriate type, do nothing  -->
		<xsl:when test="$vartype = $rettype"/>
		<!--  if the vartype inherits from another interface, see if it matches the required type  -->
		<xsl:when test="$domspec/library/interface[@name = $rettype and @inherits]">
			<xsl:call-template name="retval-cast">
				<xsl:with-param name="variable" select="$variable"/>
				<xsl:with-param name="vartype" select="$vartype"/>
				<xsl:with-param name="rettype" select="$domspec/library/interface[@name = $rettype]/@inherits"/>
			</xsl:call-template>
		</xsl:when>

		<!--  cast and hope for the best  -->		
		<xsl:otherwise>
			<xsl:text>(</xsl:text><xsl:value-of select="$vartype"/><xsl:text>)</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template name="build-accessor">
	<xsl:param name="prefix"/>
	<xsl:param name="attribute"/>
	<xsl:value-of select="$prefix"/>
	<xsl:value-of select="translate(substring($attribute,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
	<xsl:value-of select="substring($attribute,2)"/>
</xsl:template>

<xsl:template name="produce-param">
	<xsl:param name="value"/>
	<xsl:param name="reqtype"/>
	
	<xsl:choose>
		<!--  if value is true, false or starts with a quote  -->
		<xsl:when test="$value = 'true' or $value = 'false' or substring($value,1,1) ='&quot;'">
			<!--  just copy the literal  -->
			<xsl:value-of select="$value"/>
		</xsl:when>
		<!--  if numeric literal  -->
		<xsl:when test="string(number($value)) != 'NaN'">
			<xsl:value-of select="$value"/>
		</xsl:when>
		<!--  is a declared variable, make sure that it is cast correctly  -->
		<xsl:when test="ancestor::*[local-name() = 'test']/*[local-name='var' and @name = $value]">
			<xsl:call-template name="cast">
				<xsl:with-param name="var" select="$value"/>
				<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name='var' and @name = $value]/@type"/>
				<xsl:with-param name="reqtype" select="$reqtype"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>/* undeclared */</xsl:text><xsl:value-of select="$value"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="produce-specific-attribute">
	<xsl:param name="attribute"/>
	<xsl:variable name="obj" select="@obj"/>
	<xsl:if test="@value">
		<xsl:call-template name="cast">
			<xsl:with-param name="var" select="$obj"/>
			<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name='var' and @name = $obj]/@type"/>
			<xsl:with-param name="reqtype" select="$attribute/parent::interface/@name"/>
		</xsl:call-template>
		<xsl:call-template name="build-accessor">
			<xsl:with-param name="prefix">.set</xsl:with-param>
			<xsl:with-param name="attribute" select="$attribute/@name"/>
		</xsl:call-template>
		<xsl:text>(</xsl:text>
			<xsl:call-template name="produce-param">
				<xsl:with-param name="value" select="@value"/>
				<xsl:with-param name="reqtype" select="$attribute/parent::interface/@name"/>
			</xsl:call-template>
		<xsl:text>);</xsl:text>
	</xsl:if>
	<xsl:if test="@var">
		<xsl:value-of select="@var"/>
		<xsl:variable name="var" select="@var"/>
		<xsl:text> = </xsl:text>
		<xsl:call-template name="retval-cast">
			<xsl:with-param name="variable" select="$var"/>
			<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name()='var' and @name = $var]/@type"/>
			<xsl:with-param name="rettype" select="$attribute/@type"/>
		</xsl:call-template>
		<xsl:call-template name="cast">
			<xsl:with-param name="var" select="$obj"/>
			<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name() = 'var' and @name = $obj]/@type"/>
			<xsl:with-param name="reqtype" select="$attribute/parent::interface/@name"/>
		</xsl:call-template>
		<xsl:call-template name="build-accessor">
			<xsl:with-param name="prefix">.get</xsl:with-param>
			<xsl:with-param name="attribute" select="$attribute/@name"/>
		</xsl:call-template>
		<xsl:text>();</xsl:text>
	</xsl:if>
</xsl:template>


<xsl:template name="produce-specific-method">
	<xsl:param name="method"/>
	<xsl:variable name="current" select="."/>
	<xsl:variable name="obj" select="@obj"/>
	<xsl:variable name="var" select="@var"/>
	<xsl:if test="@var">
		<xsl:value-of select="@var"/>
		<xsl:text> = </xsl:text>
		<xsl:call-template name="retval-cast">
			<xsl:with-param name="variable" select="$var"/>
			<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name() = 'var' and @name = $var]/@type"/>
			<xsl:with-param name="rettype" select="$method/returns/@type"/>
		</xsl:call-template>
	</xsl:if>
	<xsl:call-template name="cast">
		<xsl:with-param name="var" select="$obj"/>
		<xsl:with-param name="vartype" select="ancestor::*[local-name() = 'test']/*[local-name() = 'var' and @name = $obj]/@type"/>
		<xsl:with-param name="reqtype" select="$method/parent::interface/@name"/>
	</xsl:call-template>
	<xsl:text>.</xsl:text>
	<xsl:value-of select="$method/@name"/>
	<xsl:text>(</xsl:text>
	<xsl:for-each select="$method/parameters/param">
		<xsl:if test="position() &gt; 1">,</xsl:if>
		<xsl:variable name="paramDef" select="."/>
		<xsl:call-template name="produce-param">
			<xsl:with-param name="value" select="$current/@*[name() = $paramDef/@name]"/>
			<xsl:with-param name="reqtype" select="$paramDef/@type"/>
		</xsl:call-template>
	</xsl:for-each>
	<xsl:text>);</xsl:text>
</xsl:template>



<xsl:template name="produce-attribute">
	<xsl:variable name="attribName" select="local-name(.)"/>
	<xsl:choose>
		<!--  if interface is specified -->
		<xsl:when test="@interface">
			<xsl:variable name="interface" select="@interface"/>			
			<xsl:call-template name="produce-specific-attribute">
				<xsl:with-param name="attribute" select="$domspec/library/interface[@name = $interface]/attribute[@name = $attribName]"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="produce-specific-attribute">
				<xsl:with-param name="attribute" select="$domspec/library/interface/attribute[@name = $attribName]"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	
</xsl:template>

<xsl:template name="produce-method">
	<xsl:variable name="methodName" select="local-name(.)"/>
	<xsl:choose>
		<!--  if interface is specified -->
		<xsl:when test="@interface">
			<xsl:variable name="interface" select="@interface"/>			
			<xsl:call-template name="produce-specific-method">
				<xsl:with-param name="method" select="$domspec/library/interface[@name = $interface]/method[@name = $methodName]"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="methods" select="$domspec/library/interface/method[@name = $methodName]"/>
			<xsl:call-template name="produce-specific-method">
				<xsl:with-param name="method" select="$methods[1]"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*[local-name()='validating']" mode="condition">
	_factory.isValidating()
</xsl:template>

<xsl:template match="*[local-name()='coalescing']" mode="condition">
	_factory.isCoalescing()
</xsl:template>

<xsl:template match="*[local-name()='expandEntityReferences']" mode="condition">
	_factory.isExpandEntityReferences()
</xsl:template>

<xsl:template match="*[local-name()='ignoringElementContentWhitespace']" mode="condition">
	_factory.isIgnoringElementContentWhitespace()
</xsl:template>

<xsl:template match="*[local-name()='ignoringComments']" mode="condition">
	_factory.isComments()
</xsl:template>

<xsl:template match="*[local-name()='namespaceAware']" mode="condition">
	_factory.isNamespaceAware()
</xsl:template>

<xsl:template match="*[local-name()='signed']" mode="condition">
	true
</xsl:template>

<xsl:template match="*[local-name()='not']" mode="condition">
	!(<xsl:apply-templates mode="condition"/>)
</xsl:template>

<xsl:template match="*[local-name()='and']" mode="condition">
	(<xsl:apply-templates select="*[1]" mode="condition"/>
	<xsl:for-each select="*[position() &gt; 1]">
		<xsl:text> &amp; </xsl:text>
		<xsl:apply-templates select="." mode="condition"/>
	</xsl:for-each>)
</xsl:template>

<xsl:template match="*[local-name()='or']" mode="condition">
	(<xsl:apply-templates select="*[1]" mode="condition"/>
	<xsl:for-each select="*[position() &gt; 1]">
		<xsl:text> | </xsl:text>
		<xsl:apply-templates select="." mode="condition"/>
	</xsl:for-each>)
</xsl:template>

<xsl:template match="*[local-name()='xor']" mode="condition">
	(<xsl:apply-templates select="*[1]" mode="condition"/>
	<xsl:for-each select="*[position() &gt; 1]">
		<xsl:text> ^ </xsl:text>
		<xsl:apply-templates select="." mode="condition"/>
	</xsl:for-each>)
</xsl:template>


<xsl:template match="*[local-name()='isTrue']" mode="condition">
	<xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="*[local-name()='isFalse']" mode="condition">
	!<xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="*[local-name()='same']" mode="condition">
	_framework.same(<xsl:value-of select="@expected"/>,<xsl:value-of select="@actual"/>)
</xsl:template>

<xsl:template match="*[local-name()='equals']" mode="condition">
	<xsl:choose>
		<xsl:when test="@ignoreCase='true'">
			<xsl:text>_framework.equalsIgnoreCase(</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>_framework.equals(</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:value-of select="@expected"/>,<xsl:value-of select="@actual"/>
	<xsl:text>)</xsl:text>
</xsl:template>

<xsl:template match="*[local-name()='notEquals']" mode="condition">
	<xsl:choose>
		<xsl:when test="@ignoreCase='true'">
			<xsl:text>!_framework.equalsIgnoreCase(</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>!_framework.equals(</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:value-of select="@expected"/>,<xsl:value-of select="@actual"/>
	<xsl:text>)</xsl:text>
</xsl:template>


<xsl:template match="*[local-name()='less']" mode="condition">
	(<xsl:value-of select="@actual"/> &lt; <xsl:value-of select="expected"/>)
</xsl:template>

<xsl:template match="*[local-name()='lessOrEquals']" mode="condition">
	(<xsl:value-of select="@actual"/> &lt;= <xsl:value-of select="expected"/>)
</xsl:template>

<xsl:template match="*[local-name()='greater']" mode="condition">
	(<xsl:value-of select="@actual"/> &gt; <xsl:value-of select="expected"/>)
</xsl:template>

<xsl:template match="*[local-name()='greaterOrEquals']" mode="condition">
	(<xsl:value-of select="@actual"/> &gt;= <xsl:value-of select="expected"/>)
</xsl:template>

<xsl:template match="*[local-name()='isNull']" mode="condition">
	(<xsl:value-of select="@obj"/> == null>)
</xsl:template>


<xsl:template match="*[local-name()='notNull']" mode="condition">
	(<xsl:value-of select="@obj"/> != null)
</xsl:template>

<xsl:template match="*[local-name()='instanceOf']" mode="condition">
	(<xsl:value-of select="@obj"/> instanceOf <xsl:value-of select="@type"/>)
</xsl:template>


<xsl:template match="*[local-name()='hasSize']" mode="condition">
	(<xsl:value-of select="@obj"/>.size() == <xsl:value-of select="@expected"/>)
</xsl:template>

<xsl:template match="*[local-name()='hasFeature']" mode="condition">
	<xsl:choose>
		<xsl:when test="@obj">
			<xsl:value-of select="@obj"/>
		</xsl:when>
		<xsl:otherwise>
			_framework
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>.hasFeature(</xsl:text>
	<xsl:value-of select="@feature"/>,
	<xsl:choose>
		<xsl:when test="@version">
			<xsl:value-of select="@version"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>null</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>)</xsl:text>
</xsl:template>

</xsl:stylesheet>
