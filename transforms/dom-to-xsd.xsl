<?xml version="1.0" encoding="UTF-8"?>							  
<!--
 * Copyright (c) 2001 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
-->

<!--   
This transforms generates an XML Schema for a DOM test definition
language from  an DOM specification.

DOM recommendations are defined in XML and the XML source for these
specifications is available within the .zip version of the specification.

For example, the DOM Level 1 .zip file, 
http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/DOM.zip 
contains a nested file, xml-source.zip, which contains an
XML file, wd-dom.xml which expresses the DOM recommendation
in XML.  (Note: most of the other .xml files are external 
entities expanded by one enclosing document).


Usage:

saxon -o dom1-test.xsd wd-dom.xml dom-to-schema.xsl


-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<xsl:param name="schema-namespace">http://www.w3.org/2001/DOM-Test-Suite/Level-X</xsl:param>


	<!--   symbolic constant for schema namespace   -->
	<xsl:variable name="source" select="/spec/header/publoc/loc[1]/@href"/>
	<xsl:output method="xml" indent="yes" 
		doctype-system="http://www.w3.org/2001/XMLSchema.dtd" 
		doctype-public="-//W3C//DTD XMLSCHEMA 200102//EN"/>


	<!--  interfaces defined in DOM recommendation  -->
	<xsl:variable name="interfaces" select="//interface"/>
	<!--  attributes defined in DOM recommendation  -->
	<xsl:variable name="attributes" select="//attribute"/>
	<!--  methods defined in DOM recommendation  -->
	<xsl:variable name="methods" select="//method"/>

	<!--  interfaces keyed by super class -->
	<xsl:key name="bysuper" match="//interface[@inherits]" use="@inherits"/>
	<!--  attributes keyed by name        -->
	<xsl:key name="attrByName" match="//attribute[@name]" use="@name"/>
	<!--  methods keyed by name           -->
	<xsl:key name="methodByName" match="//method[@name]" use="@name"/>


	<!--   match document root   -->
	<xsl:template match="/">
		<xsd:schema targetNamespace="{$schema-namespace}" 
			_xmlns="{$schema-namespace}">
		<xsl:comment>
Copyright (c) 2001 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
</xsl:comment><xsl:text>

</xsl:text>
		<xsl:comment>This schema was generated from <xsl:value-of select="$source"/> by dom-to-xsd.xsl.</xsl:comment><xsl:text>

</xsl:text>

			<!--   produce fixed simpleType definitions    -->
			<xsl:call-template name="static-simpleTypes"/>
			<!--   produce simpleType definitions that depend on the source document  -->
			<xsl:call-template name="dynamic-simpleTypes"/>
			<!--   produce fixed element definitions        -->			
			<xsl:call-template name="static-elements"/>
			<!--   produce element definitions that depend on the source document    -->
			<xsl:call-template name="dynamic-elements"/>
			<!--   generate assertion elements that depend on the source document    -->
			<xsl:call-template name="dynamic-assertions"/>

			<!--   produce elements that correspond to DOM attributes   -->
			<xsl:call-template name="produce-properties"/>
			<!--   produce elements that correspond to DOM methods     -->
			<xsl:call-template name="produce-methods"/>
		</xsd:schema>
	</xsl:template>


	<!--    produce elements that correspond to DOM attributes    
			If the same attribute name is used in multiple contexts,
			for example, target is used both by Event and ProcessingInstruction,
			only one element will be created.  The interface attribute
			will be required to disambiguate.
	-->
    <xsl:template name="produce-properties">
			<!--   generate an schema element for each interface attribute    -->
			<xsl:for-each select="$attributes">
				<xsl:sort select="@name"/>

				<!--   Note: some DOM processors have had problems with current(),
				       so as a kludge, the current context is made an
					   explicit variable and used in place of current()   -->
				<xsl:variable name="current" select="."/>

				<!--  only the first entry creates an entry  -->
				<xsl:if test="not(preceding::attribute[@name=$current/@name]) and @name != 'implementation'">

					<!--  create an element whose tag name is the same as the attribute  -->
					<xsd:element name="{@name}">
						<xsd:complexType>
							<xsd:attribute name="id" type="xsd:ID" use="optional"/>
							<xsd:attribute name="obj" type="variable" use="required"/>
							<!--  if readonly, only the "var" attribute is produced.
							      Otherwise both a "var" and "value" attribute are produced  -->
							<xsl:choose>
								<xsl:when test="@readonly='yes'">
									<xsd:attribute name="var" type="variable" use="required"/>
								</xsl:when>
								<xsl:otherwise>
									<xsd:attribute name="var" type="variable" use="optional"/>

									<!--  produces a "value" attribute, 
									      the schema type is selected based on the attribute type   -->
									<xsl:call-template name="param-type">
										<xsl:with-param name="type" select="@type"/>
										<xsl:with-param name="paramName">value</xsl:with-param>
										<xsl:with-param name="use">optional</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>

							<!--  collect all attributes with this name   -->
							<xsl:variable name="dups" select="key('attrByName',@name)"/>

							<!--  produce the "interface" attribute       -->
							<xsd:attribute name="interface">
								<!--  choose whether interface is required based
								         on number of interfaces method is introduced by  -->
								<xsl:choose>
									<xsl:when test="count($dups) &gt; 1">
										<xsl:attribute name="use">required</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="use">optional</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>

								<!--   create the enumeration of appropriate interface values  -->
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsl:for-each select="$dups">
											<xsd:enumeration value="{parent::interface/@name}"/>
										</xsl:for-each>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
						</xsd:complexType>
					</xsd:element>
				</xsl:if>
			</xsl:for-each>
	</xsl:template>


	<!--   produce elements for all of the DOM methods.  Identically named
	       methods, for example, Document.getElementsByTagName and 
		   Element.getElementsByTag name will be represented by
		   one element.  Since these are much rarer than identically
		   named attributes and the function signatures are identical
		   for all known instances.  This template assumes that the
		   signature of the first instance is appropriate for all.
	-->
	<xsl:template name="produce-methods">

			<!--  produce an element for all methods  -->
			<xsl:for-each select="$methods">
				<xsl:sort select="@name"/>
				<xsl:variable name="current" select="."/>

				<!--   for only the first occurance of the name   -->
				<xsl:if test="not(preceding::method[@name=$current/@name]) and @name != 'hasFeature'">
					
					<!--   create an element whose tag name is the same as the method   -->
					<xsd:element name="{@name}">
						<xsd:complexType>
							<xsd:attribute name="id" type="xsd:ID" use="optional"/>
							<!--  the invocation target attribute is required   -->
							<xsd:attribute name="obj" type="variable" use="required"/>

							<!--  If the method has a (non-void) return value then
							      the var attribute is required to receive the return value  -->
							<xsl:if test="returns[@type!='void']">
								<xsd:attribute name="var" type="variable" use="required"/>
							</xsl:if>

							<!--  for each parameter    -->
							<xsl:for-each select="parameters/param">
								<!--  need to check that all the types are consistent  -->
								<xsl:call-template name="param-type">
									<xsl:with-param name="type" select="@type"/>
									<xsl:with-param name="paramName" select="@name"/>
									<xsl:with-param name="use">required</xsl:with-param>
								</xsl:call-template>
							</xsl:for-each>

							<!--  produce interface attribute   -->
							<xsl:variable name="dups" select="key('methodByName',@name)"/>
							<xsd:attribute name="interface">
								<xsl:choose>
									<xsl:when test="count($dups) &gt; 1">
										<xsl:attribute name="use">required</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="use">optional</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<xsd:simpleType>
									<xsd:restriction base="xsd:string">
										<xsl:for-each select="$dups">
											<xsd:enumeration value="{parent::interface/@name}"/>
										</xsl:for-each>
									</xsd:restriction>
								</xsd:simpleType>
							</xsd:attribute>
						</xsd:complexType>
					</xsd:element>
				</xsl:if>
			</xsl:for-each>
	</xsl:template>

	<!--  this template contains simple types that are indepenent
	      of the DOM recommendation.	
	-->
    <xsl:template name="static-simpleTypes">
            <xsd:simpleType name="absoluteURI">
			     <xsd:restriction base="xsd:anyURI">
				     <xsd:pattern value="[a-zA-Z]*:.*"/>
				 </xsd:restriction>
			</xsd:simpleType>

			<!--  all the pattern could be tighter   -->
			<xsd:simpleType name="variable">
				<xsd:annotation>
					<xsd:documentation>A variable name</xsd:documentation>
				</xsd:annotation>
				<xsd:restriction base="xsd:string">
					<xsd:pattern value="[A-Za-z][A-Za-z0-9]*"/>
				</xsd:restriction>
			</xsd:simpleType>

			<xsd:simpleType name="className">
				<xsd:annotation>
					<xsd:documentation>A class name</xsd:documentation>
				</xsd:annotation>
				<xsd:restriction base="xsd:string">
					<xsd:pattern value="[A-Za-z][A-Za-z0-9]*"/>
				</xsd:restriction>
			</xsd:simpleType>

			<xsd:simpleType name="packageName">
				<xsd:annotation>
					<xsd:documentation>A package name</xsd:documentation>
				</xsd:annotation>
				<xsd:restriction base="xsd:string">
					<xsd:pattern value="[A-Za-z][A-Za-z0-9\.]*"/>
				</xsd:restriction>
			</xsd:simpleType>

			<xsd:simpleType name="stringLiteral">
				<xsd:annotation>
					<xsd:documentation>A string literal.  Distinguished from a variable reference by the enclosing double quotes.</xsd:documentation>
				</xsd:annotation>
				<xsd:restriction base="xsd:string">
					<xsd:pattern value='"[^\"]*"'/>
				</xsd:restriction>
			</xsd:simpleType>

			<xsd:simpleType name="literal">
				<xsd:annotation>
					<xsd:documentation>The union of accepted literal types</xsd:documentation>
				</xsd:annotation>
				<xsd:union memberTypes="xsd:integer stringLiteral"/>
			</xsd:simpleType>
			<xsd:simpleType name="variableOrLiteral">
				<xsd:union memberTypes="literal variable"/>
			</xsd:simpleType>
			<xsd:simpleType name="variableOrStringLiteral">
				<xsd:union memberTypes="stringLiteral variable"/>
			</xsd:simpleType>
			<xsd:simpleType name="variableOrIntLiteral">
				<xsd:union memberTypes="xsd:integer variable"/>
			</xsd:simpleType>
			<xsd:simpleType name="variableOrBoolLiteral">
				<xsd:union memberTypes="xsd:boolean variable"/>
			</xsd:simpleType>
			<xsd:simpleType name="feature">
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="XML"/>
					<xsd:enumeration value="Core"/>
					<xsd:enumeration value="Events"/>
					<xsd:enumeration value="MutationEvents"/>
					<xsd:enumeration value="Traversal"/>
					<xsd:enumeration value="Range"/>
				</xsd:restriction>
			</xsd:simpleType>
			<xsd:simpleType name="version">
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="1.0"/>
					<xsd:enumeration value="2.0"/>
					<xsd:enumeration value="3.0"/>
				</xsd:restriction>
			</xsd:simpleType>
   </xsl:template>

	<!--   this template generates any simple types
	       that are dependent on the source document.  Currently only
		   the allowable types for variables    -->
	<xsl:template name="dynamic-simpleTypes">
			<xsd:simpleType name="variableType">
				<xsd:annotation>
					<xsd:documentation>All known DOM interfaces plus int, DOMString maybe some others.</xsd:documentation>
				</xsd:annotation>
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="int"/>
                    <xsd:enumeration value="boolean"/>
					<xsd:enumeration value="DOMString"/>
					<xsd:enumeration value="List">
						<xsd:annotation>
							<xsd:documentation>A List variable is used to compare two ordered collections, such as the expected and actual child element names.</xsd:documentation>
						</xsd:annotation>
					</xsd:enumeration>
					<xsd:enumeration value="Collection">
						<xsd:annotation>
							<xsd:documentation>A collection variable is used to compare two unordered collections, such as the expected and actual attribute names.</xsd:documentation>
						</xsd:annotation>
					</xsd:enumeration>
					<xsd:enumeration value="EventMonitor">
						<xsd:annotation>
							<xsd:documentation>An implementation of EventListener that will capture and store all events encountered.</xsd:documentation>
						</xsd:annotation>
					</xsd:enumeration>
					<xsl:for-each select="$interfaces">
						<xsl:sort select="@name"/>
						<xsd:enumeration value="{@name}"/>
					</xsl:for-each>
				</xsd:restriction>
			</xsd:simpleType>
	</xsl:template>

	<!--   This template contains the elements that are 
	       independent of the source document.  Examples of these
		   elements are <test>, <var>, <assign>, etc.
	-->
    <xsl:template name="static-elements">
			<xsd:element name="test">
				<xsd:annotation>
					<xsd:documentation>A test.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:choice minOccurs="0" maxOccurs="unbounded">
							<xsd:element ref="hasFeature"/>
							<xsd:element ref="implementationAttribute"/>
						</xsd:choice>
						<xsd:element ref="var" minOccurs="0" maxOccurs="unbounded"/>
						<xsd:choice>
							<xsd:element ref="load"/>
							<xsd:element ref="implementation"/>
						</xsd:choice>
						<xsd:group ref="statement" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="name" type="className" use="required">
						<xsd:annotation>
							<xsd:documentation>Used in method name in generated code.</xsd:documentation>
						</xsd:annotation>
					</xsd:attribute>
				</xsd:complexType>
			</xsd:element>

			<xsd:element name="suite.member">
				<xsd:annotation>
					<xsd:documentation>A member of a test suite, either a individual test or another suite.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="href" type="xsd:anyURI" use="required"/>
				</xsd:complexType>
			</xsd:element>

			<xsd:element name="suite">
				<xsd:annotation>
					<xsd:documentation>A suite of tests</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:choice minOccurs="0" maxOccurs="unbounded">
							<xsd:element ref="hasFeature"/>
							<xsd:element ref="implementationAttribute"/>
						</xsd:choice>
						<xsd:choice minOccurs="0" maxOccurs="unbounded">
							<xsd:element ref="suite.member"/>
						</xsd:choice>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="name" type="className" use="required">
						<xsd:annotation>
							<xsd:documentation>Used in method name in generated code.</xsd:documentation>
						</xsd:annotation>
					</xsd:attribute>
				</xsd:complexType>
			</xsd:element>

			<xsd:element name="package">
				<xsd:annotation>
					<xsd:documentation>A package of tests in one resource</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:choice minOccurs="0" maxOccurs="unbounded">
							<xsd:element ref="test"/>
							<xsd:element ref="suite"/>
						</xsd:choice>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>

			<xsd:element name="comment">
				<xsd:annotation>
					<xsd:documentation>Injects comment into generated code.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:simpleContent>
						<xsd:extension base="xsd:string">
							<xsd:attribute name="id" type="xsd:ID" use="optional"/>
						</xsd:extension>
					</xsd:simpleContent>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="wait">
				<xsd:annotation>
					<xsd:documentation>Attempts to pause for a specified period</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="milliseconds" type="xsd:positiveInteger" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="append">
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="collection" type="variable" use="required"/>
					<xsd:attribute name="obj" type="variable" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:complexType name="unaryAssignment">
				<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="var" type="variable" use="required"/>
				<xsd:attribute name="value" type="variableOrLiteral" use="required"/>
			</xsd:complexType>
			<xsd:element name="assign">
				<xsd:annotation>
					<xsd:documentation>Assigns the specified value or condition to the a variable.  If both are specified, the value will be AND'd with the condition.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:group ref="condition" minOccurs="0"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="var" type="variable" use="required"/>
					<xsd:attribute name="value" type="variableOrLiteral" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="increment" type="unaryAssignment"/>
			<xsd:element name="decrement" type="unaryAssignment"/>
			<xsd:complexType name="binaryAssignment">
				<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="var" type="variable" use="required"/>
				<xsd:attribute name="op1" type="variableOrLiteral" use="required"/>
				<xsd:attribute name="op2" type="variableOrLiteral" use="required"/>
			</xsd:complexType>
			<!--  can't be add since that conflicts with HTMLSelectElement.add  -->
			<xsd:element name="plus" type="binaryAssignment"/>
			<xsd:element name="subtract" type="binaryAssignment"/>
			<xsd:element name="mult" type="binaryAssignment"/>
			<xsd:element name="divide" type="binaryAssignment"/>
			<!--  can't be declare since that conflicts with HTMLObjectElement.declare --> 
			<xsd:element name="var">
				<xsd:annotation>
					<xsd:documentation>Declare and optionally initialize a variable.  [Tenative] All variables must be declared.  Use instanceOf for type assertions.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:choice minOccurs="0">
						<xsd:element ref="member" maxOccurs="unbounded"/>
						<xsd:element ref="handleEvent"/>
					</xsd:choice>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="name" type="variable" use="required"/>
					<xsd:attribute name="type" type="variableType" use="required"/>
					<xsd:attribute name="value" type="literal" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="member" type="literal">
				<xsd:annotation>
					<xsd:documentation>Member children are used to initialize List and Collection types.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="handleEvent">
				<xsd:annotation>
					<xsd:documentation>Defines the event handler for a EventMonitor with parameters "listener", "event", "currentTarget" and "userObj".</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="var" minOccurs="0" maxOccurs="unbounded"/>
						<xsd:group ref="statement" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="return" type="variable" use="optional">
						<xsd:annotation>
							<xsd:documentation>Declares and initializes to true a boolean variable that if false will prevent handleEvent being called on future events.</xsd:documentation>
						</xsd:annotation>
					</xsd:attribute>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="load">
				<xsd:annotation>
					<xsd:documentation>Loads the document declared in the corresponding document element.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="var" type="variable" use="required"/>
					<xsd:attribute name="href" type="xsd:anyURI" use="required"/>
					<xsd:attribute name="willBeModified" type="xsd:boolean" use="required">
						<xsd:annotation>
							<xsd:documentation>If true then this test may modify the document, so a fresh copy should be loaded instead of a cached copy.</xsd:documentation>
						</xsd:annotation>
					</xsd:attribute>
					<xsd:attribute name="documentElementTagName" type="variable" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="implementation">
				<xsd:annotation>
					<xsd:documentation>Gets a DOMImplementation.  If the obj attribute is not specified, it creates a default implementation as determined by the test framework.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="var" type="variable" use="required"/>
					<xsd:attribute name="obj" type="variable" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="metadata">
				<xsd:complexType>
					<xsd:choice minOccurs="0" maxOccurs="unbounded">
						<xsd:element ref="metadata"/>						
						<!-- xsd:any namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" processContents="lax"/ -->
						<!--  omitted a few DC elements that seemed extraneous  -->
						<!--  title is done locally to avoid conflicts with the HTMLDocument.title   -->
						<xsd:element name="title" type="rdf-statement">
							<xsd:annotation>
								<xsd:documentation>Name given to the test.</xsd:documentation>
							</xsd:annotation>
						</xsd:element>
						<xsd:element ref="creator"/>
						<xsd:element ref="subject"/>
						<xsd:element ref="description"/>
						<xsd:element ref="contributor"/>
						<xsd:element ref="date"/>
						<xsd:element ref="source"/>
						<xsd:element ref="relation"/>
					</xsd:choice>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="about" type="xsd:anyURI" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<!--   this is patterned after RDF's representation in XML   -->
			<xsd:complexType name="rdf-statement">
				<xsd:simpleContent>
				    <xsd:extension base="xsd:string">
						<xsd:attribute name="id" type="xsd:ID" use="optional"/>
						<xsd:attribute name="resource" type="absoluteURI" use="optional"/>
						<xsd:attribute name="type" type="absoluteURI" use="optional"/>
					</xsd:extension>
				</xsd:simpleContent>
			</xsd:complexType>
			<!--   the semantics of these elements are based on Dublin Core  -->
			<xsd:element name="creator" type="rdf-statement">
				<xsd:annotation>
					<xsd:documentation>Entity primarily responsible for making the test definition.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="subject" type="rdf-statement">
				<xsd:annotation>
					<xsd:documentation>One topic of the test.  May be repeated.  Preferably, a URI identifing a particular section of the DOM specification.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>

			<xsd:element name="description" type="rdf-statement">
				<xsd:annotation>
					<xsd:documentation>A free-text account of the test.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="contributor" type="rdf-statement">
				<xsd:annotation>
					<xsd:documentation>An entity responsible for making contributions to the test.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>

			<xsd:simpleType name="dateQualifier">
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="created"/>
					<xsd:enumeration value="valid"/>
					<xsd:enumeration value="available"/>
					<xsd:enumeration value="issued"/>
					<xsd:enumeration value="modified"/>
				</xsd:restriction>
			</xsd:simpleType>

			<xsd:element name="date">
				<xsd:annotation>
					<xsd:documentation>A reference to a rest from which the current test is derived.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:simpleContent>
						<xsd:extension base="xsd:date">
							<xsd:attribute name="id" type="xsd:ID" use="optional"/>
							<xsd:attribute name="qualifier" use="required" type="dateQualifier"/>
						</xsd:extension>
					</xsd:simpleContent>
				</xsd:complexType>
			</xsd:element>
							
			<xsd:element name="source" type="rdf-statement">
				<xsd:annotation>
					<xsd:documentation>A reference to a rest from which the current test is derived.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>

			<xsd:simpleType name="relationQualifier">
				<xsd:restriction base="xsd:string">
					<xsd:enumeration value="isVersionOf"/>
					<xsd:enumeration value="hasVersion"/>
					<xsd:enumeration value="isReplacedBy"/>
					<xsd:enumeration value="isRequiredBy"/>
					<xsd:enumeration value="requires"/>
					<xsd:enumeration value="isPartOf"/>
					<xsd:enumeration value="hasPart"/>
					<xsd:enumeration value="isReferenceBy"/>
					<xsd:enumeration value="references"/>
				</xsd:restriction>
			</xsd:simpleType>


			<xsd:element name="relation">
				<xsd:annotation>
					<xsd:documentation>A reference to a rest from which the current test is derived.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:simpleContent>
					    <xsd:extension base="xsd:string">
							<xsd:attribute name="id" type="xsd:ID" use="optional"/>
							<xsd:attribute name="resource" type="absoluteURI" use="optional"/>
							<xsd:attribute name="type" type="absoluteURI" use="optional"/>
							<xsd:attribute name="qualifier" use="required" type="relationQualifier"/>
						</xsd:extension>
					</xsd:simpleContent>
				</xsd:complexType>
			</xsd:element>

			<xsd:complexType name="assertTrueFalse">
				<xsd:sequence>
					<xsd:group ref="condition" minOccurs="0"/>
					<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
				</xsd:sequence>
				<xsd:attribute name="id" type="xsd:ID" use="required"/>
				<xsd:attribute name="actual" type="variable" use="optional"/>
			</xsd:complexType>
			<xsd:element name="assertTrue" type="assertTrueFalse">
				<xsd:annotation>
					<xsd:documentation>Will result in the test failing unless the condition expression content and  the value of the variable specified in the "actual" attribute are either absent or true.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="assertFalse" type="assertTrueFalse">
				<xsd:annotation>
					<xsd:documentation>Will result in the test failing unless the condition expression content or the value of the variable specified in the "actual" attribute is false.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:complexType name="unaryAssertion">
				<xsd:sequence>
					<xsd:element ref="metadata" minOccurs="0"/>
					<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
				</xsd:sequence>
				<xsd:attribute name="actual" type="variable" use="required"/>
				<xsd:attribute name="id" type="xsd:ID" use="required"/>
			</xsd:complexType>
			<xsd:element name="assertNull" type="unaryAssertion"/>
			<xsd:element name="assertNotNull" type="unaryAssertion"/>
			<xsd:complexType name="comparisonAssertion">
				<xsd:sequence>
					<xsd:element ref="metadata" minOccurs="0"/>
					<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
				</xsd:sequence>
				<xsd:attribute name="actual" type="variable" use="required"/>
				<xsd:attribute name="expected" type="variableOrLiteral" use="required"/>
				<xsd:attribute name="id" type="xsd:ID" use="required"/>
			</xsd:complexType>
			<xsd:element name="assertSame">
				<xsd:annotation>
					<xsd:documentation>This asserts that the parameters reference the same object.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="actual" type="variable" use="required"/>
					<xsd:attribute name="expected" type="variable" use="required"/>
					<xsd:attribute name="id" type="xsd:ID" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="assertInstanceOf">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="obj" type="variable" use="required"/>
					<xsd:attribute name="type" type="variableType" use="required"/>
					<xsd:attribute name="id" type="xsd:ID" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="assertSize">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="collection" type="variable" use="required"/>
					<xsd:attribute name="size" type="variableOrIntLiteral" use="required"/>
					<xsd:attribute name="id" type="xsd:ID" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:complexType name="comparisonAssertionWithCase">
				<xsd:sequence>
					<xsd:element ref="metadata" minOccurs="0"/>
					<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
				</xsd:sequence>
				<xsd:attribute name="actual" type="variable" use="required"/>
				<xsd:attribute name="expected" type="variableOrLiteral" use="required"/>
				<xsd:attribute name="id" type="xsd:ID" use="required"/>
				<xsd:attribute name="ignoreCase" type="xsd:boolean" use="required"/>
			</xsd:complexType>
			<xsd:element name="assertEquals" type="comparisonAssertionWithCase"/>
			<xsd:element name="assertNotEquals" type="comparisonAssertionWithCase"/>
			<xsd:element name="assertEventCount">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="atCount" type="variableOrIntLiteral" use="optional"/>
					<xsd:attribute name="captureCount" type="variableOrIntLiteral" use="optional"/>
					<xsd:attribute name="bubbleCount" type="variableOrIntLiteral" use="optional"/>
					<xsd:attribute name="totalCount" type="variableOrIntLiteral" use="optional"/>
					<xsd:attribute name="monitor" type="variable" use="required"/>
					<xsd:attribute name="id" type="xsd:ID" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:group name="framework-assertion">
				<xsd:choice>
					<xsd:element ref="assertTrue"/>
					<xsd:element ref="assertFalse"/>
					<xsd:element ref="assertNull"/>
					<xsd:element ref="assertNotNull"/>
					<xsd:element ref="assertEquals"/>
					<xsd:element ref="assertNotEquals"/>
					<xsd:element ref="assertSame"/>
					<xsd:element ref="assertInstanceOf"/>
					<xsd:element ref="assertSize"/>
					<xsd:element ref="assertEventCount"/>
				</xsd:choice>
			</xsd:group>
			<xsd:group name="framework-statement">
				<xsd:choice>
					<xsd:element ref="assign"/>
					<xsd:element ref="increment"/>
					<xsd:element ref="decrement"/>
					<xsd:element ref="append"/>
					<xsd:element ref="plus"/>
					<xsd:element ref="subtract"/>
					<xsd:element ref="mult"/>
					<xsd:element ref="divide"/>
					<xsd:element ref="load"/>
					<xsd:element ref="implementation"/>
					<xsd:element ref="hasFeature"/>
					<xsd:element ref="if"/>
					<xsd:element ref="while"/>
					<xsd:element ref="for-each"/>
					<xsd:element ref="comment"/>
					<xsd:element ref="EventMonitor.setUserObj"/>
					<xsd:element ref="EventMonitor.getAtEvents"/>
					<xsd:element ref="EventMonitor.getCaptureEvents"/>
					<xsd:element ref="EventMonitor.getBubbleEvents"/>
					<xsd:element ref="EventMonitor.getAllEvents"/>
					<xsd:element ref="wait"/>
				</xsd:choice>
			</xsd:group>

			<xsd:complexType name="comparison">
				<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="actual" type="variable" use="required"/>
				<xsd:attribute name="expected" type="variableOrLiteral" use="required"/>
			</xsd:complexType>
			<xsd:element name="same">
				<xsd:annotation>
					<xsd:documentation>Object identity comparison</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="actual" type="variable" use="required"/>
					<xsd:attribute name="expected" type="variable" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:complexType name="comparisonWithCase">
				<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="actual" type="variable" use="required"/>
				<xsd:attribute name="expected" type="variableOrLiteral" use="required"/>
				<xsd:attribute name="ignoreCase" type="xsd:boolean" use="required"/>
			</xsd:complexType>
			<xsd:element name="equals" type="comparisonWithCase">
				<xsd:annotation>
					<xsd:documentation>Value comparison, element-wise on collections.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="notEquals" type="comparisonWithCase"/>
			<xsd:element name="less" type="comparison">
				<xsd:annotation>
					<xsd:documentation>Actual is less than to expected.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="lessOrEquals" type="comparison">
				<xsd:annotation>
					<xsd:documentation>Actual is less than or equal to expected.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="greaterOrEquals" type="comparison">
				<xsd:annotation>
					<xsd:documentation>Actual is greater than or equal to expected.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:element name="greater" type="comparison">
				<xsd:annotation>
					<xsd:documentation>Actual is greater than expected.</xsd:documentation>
				</xsd:annotation>
			</xsd:element>
			<xsd:complexType name="unaryComparison">
				<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="obj" type="variable" use="required"/>
			</xsd:complexType>
			<xsd:element name="isNull" type="unaryComparison"/>
			<xsd:element name="notNull" type="unaryComparison"/>
			<xsd:element name="instanceOf">
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="obj" type="variable" use="required"/>
					<xsd:attribute name="type" type="variableType" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="hasSize">
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="obj" type="variable" use="required"/>
					<xsd:attribute name="expected" type="variableOrIntLiteral" use="required"/>
				</xsd:complexType>
			</xsd:element>


			<xsd:element name="implementationAttribute">
				<xsd:complexType>
					<xsd:attribute name="name" use="required">
						<xsd:simpleType>
							<xsd:restriction base="xsd:string">
								<xsd:enumeration>validating</xsd:enumeration>
								<xsd:enumeration>coalescing</xsd:enumeration>
								<xsd:enumeration>expandEntityReferences</xsd:enumeration>
								<xsd:enumeration>namespaceAware</xsd:enumeration>
								<xsd:enumeration>ignoreElementContentWhitespace</xsd:enumeration>
								<xsd:enumeration>signed</xsd:enumeration>
								<xsd:enumeration>hasNullString</xsd:enumeration>
							</xsd:restriction>
						</xsd:simpleType>
					</xsd:attribute>
					<xsd:attribute name="value" use="required" type="xsd:boolean"/>
					<xsd:attribute name="id" use="optional" type="xsd:ID"/>
				</xsd:complexType>
			</xsd:element>

			<xsd:element name="hasFeature">
				<xsd:annotation>
					<xsd:documentation>hasFeature is used both as a property of a DOMImplementation (when obj and var attributes are provided) and as a implementationCondition.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="feature" type="stringLiteral" use="required"/>
					<xsd:attribute name="version" type="stringLiteral" use="optional"/>
					<xsd:attribute name="var" type="variable" use="optional"/>
					<xsd:attribute name="obj" type="variable" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="not">
				<xsd:complexType>
					<xsd:group ref="condition"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="isTrue">
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="value" type="variable" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="isFalse">
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="value" type="variable" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="or">
				<xsd:complexType>
					<xsd:group ref="condition" minOccurs="2" maxOccurs="unbounded"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="and">
				<xsd:complexType>
					<xsd:group ref="condition" minOccurs="2" maxOccurs="unbounded"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="xor">
				<xsd:complexType>
					<xsd:group ref="condition" minOccurs="2" maxOccurs="2"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:group name="condition">
				<xsd:choice>
					<xsd:element ref="same"/>
					<xsd:element ref="equals"/>
					<xsd:element ref="notEquals"/>
					<xsd:element ref="less"/>
					<xsd:element ref="lessOrEquals"/>
					<xsd:element ref="greater"/>
					<xsd:element ref="greaterOrEquals"/>
					<xsd:element ref="isNull"/>
					<xsd:element ref="notNull"/>
					<xsd:element ref="and"/>
					<xsd:element ref="or"/>
					<xsd:element ref="xor"/>
					<xsd:element ref="instanceOf"/>
					<xsd:element ref="isTrue"/>
					<xsd:element ref="isFalse"/>
					<xsd:element ref="hasSize"/>
					<xsd:element ref="hasFeature"/>
					<xsd:element ref="implementationAttribute"/>
				</xsd:choice>
			</xsd:group>
			<xsd:element name="else">
				<xsd:complexType>
					<xsd:group ref="statement" maxOccurs="unbounded"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="if">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:group ref="condition"/>
						<xsd:group ref="statement" maxOccurs="unbounded"/>
						<xsd:element ref="else" minOccurs="0"/>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="while">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:group ref="condition"/>
						<xsd:group ref="statement" maxOccurs="unbounded"/>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="for-each">
				<xsd:complexType>
					<xsd:group ref="statement" minOccurs="0" maxOccurs="unbounded"/>
					<xsd:attribute name="collection" type="variable" use="required"/>
					<xsd:attribute name="member" type="variable" use="required"/>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:element name="EventMonitor.setUserObj">
				<xsd:annotation>
					<xsd:documentation>Assignes an object to a userObj variable that is accessible from the handleEvent handler of the specified EventMonitor.</xsd:documentation>
				</xsd:annotation>
				<xsd:complexType>
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					<xsd:attribute name="obj" type="variable" use="required"/>
					<xsd:attribute name="userObj" type="variable" use="required"/>
				</xsd:complexType>
			</xsd:element>
			<xsd:complexType name="EventMonitorAccessor">
					<xsd:attribute name="id" type="xsd:ID" use="optional"/>
				<xsd:attribute name="monitor" type="variable" use="required"/>
				<xsd:attribute name="var" type="variable" use="required"/>
			</xsd:complexType>
			<xsd:element name="EventMonitor.getAtEvents" type="EventMonitorAccessor"/>
			<xsd:element name="EventMonitor.getCaptureEvents" type="EventMonitorAccessor"/>
			<xsd:element name="EventMonitor.getBubbleEvents" type="EventMonitorAccessor"/>
			<xsd:element name="EventMonitor.getAllEvents" type="EventMonitorAccessor"/>

	</xsl:template>

	<!--   This template produces assertion elements for each
	       defined exception type   -->
    <xsl:template name="dynamic-assertions">

		<!--  checking for non-null id attributes gets exception definitions
		         not uses  -->
		<xsl:for-each select="//exception[@id]">		
			<xsl:variable name="exception" select="@name"/>
			<xsd:element name="assert{@name}">
				<xsd:complexType>
					<xsd:sequence>
						<xsd:element ref="metadata" minOccurs="0"/>
						<xsd:choice>
							<!--  the immediately following group defines the codes  -->
							<xsl:for-each select="following-sibling::group[1]/constant">
								<xsd:element ref="{@name}"/>
							</xsl:for-each>
						</xsd:choice>
					</xsd:sequence>
					<xsd:attribute name="id" type="xsd:ID" use="required"/>
				</xsd:complexType>
			</xsd:element>

			<!--  produce elements for each of the defined codes for
			        the exception.  The content model of these
					elements are the methods and attributes that
					raise that specific code.
			-->
			<xsl:for-each select="following-sibling::group[1]/constant">
				<xsl:variable name="constant" select="."/>
				<xsd:element name="{@name}">
					<xsd:complexType>
						<xsd:choice>
							<xsl:for-each select="$attributes/getraises/exception[@name=$exception]">
								<xsl:call-template name="produce-feature-if-raises-code">
									<xsl:with-param name="exception" select="."/>
									<xsl:with-param name="constant" select="$constant"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:for-each select="$attributes/setraises/exception[@name=$exception]">
								<xsl:call-template name="produce-feature-if-raises-code">
									<xsl:with-param name="exception" select="."/>
									<xsl:with-param name="constant" select="$constant"/>
								</xsl:call-template>
							</xsl:for-each>
							<xsl:for-each select="$methods/raises/exception[@name=$exception]">
								<xsl:call-template name="produce-feature-if-raises-code">
									<xsl:with-param name="exception" select="."/>
									<xsl:with-param name="constant" select="$constant"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsd:choice>
						<xsd:attribute name="id" type="xsd:ID" use="optional"/>
					</xsd:complexType>
				</xsd:element>
			</xsl:for-each>
		</xsl:for-each>
		<!--  generate assertion group  -->
		<xsd:group name="assertion">
			<xsd:choice>
				<xsd:group ref="framework-assertion"/>
				<xsl:for-each select="//exception[@id]">
					<xsd:element ref="assert{@name}"/>
				</xsl:for-each>
			</xsd:choice>
		</xsd:group>
	</xsl:template>

	<xsl:template name="produce-feature-if-raises-code">
		<!--   this is the exception block in a raises, setraises or getraises element  -->
		<xsl:param name="exception"/>
		<xsl:param name="constant"/>
		<xsl:if test="contains(string($exception),concat($constant/@name,':'))">
			<!--  change context to parent (which could be raises, setraises or getraises  -->
			<xsl:for-each select="parent::*">												  
				<xsd:element ref="{parent::*/@name}"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
			
	<!--  generate element that depend on the source document   -->				
    <xsl:template name="dynamic-elements">
			<xsd:group name="statement">
				<xsd:choice>
					<xsd:group ref="framework-statement"/>
					<xsd:group ref="assertion"/>
					<xsl:for-each select="$attributes">
						<xsl:sort select="@name"/>
						<xsl:variable name="current" select="."/>
						<xsl:if test="not(preceding::attribute[@name=$current/@name])">
							<xsl:if test="@name != 'implementation'">
								<xsd:element ref="{@name}"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<xsl:for-each select="$methods">
						<xsl:sort select="@name"/>
						<xsl:variable name="current" select="."/>
						<xsl:if test="not(preceding::method[@name=$current/@name])">
							<xsl:if test="@name != 'hasFeature'">
								<xsd:element ref="{@name}"/>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</xsd:choice>
			</xsd:group>
	</xsl:template>

	<!--  produce an attribute with the name specified by $paramName,
	      use specified by $use and whose type is appropriate for
		  the type of the param   -->
	<xsl:template name="param-type">
		<xsl:param name="paramName"/>
		<xsl:param name="type"/>
		<xsl:param name="use"/>
		<xsl:choose>
			<xsl:when test="$type='DOMString'">
				<xsd:attribute name="{$paramName}" type="variableOrStringLiteral" use="{$use}"/>
			</xsl:when>

			<xsl:when test="$type='long'">
				<xsd:attribute name="{$paramName}" type="variableOrIntLiteral" use="{$use}"/>
			</xsl:when>

			<xsl:when test="$type='unsigned long'">
				<xsd:attribute name="{$paramName}" type="variableOrIntLiteral" use="{$use}"/>
			</xsl:when>

			<xsl:when test="$type='boolean'">
				<xsd:attribute name="{$paramName}" type="variableOrBoolLiteral" use="{$use}"/>
			</xsl:when>

			<xsl:otherwise>
				<xsl:comment>type = <xsl:value-of select="$type"/></xsl:comment>
				<xsd:attribute name="{$paramName}" type="variable" use="{$use}"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
