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
This transforms builds a composite of the DOM 2 Specs.

DOM recommendations are defined in XML and the XML source for these
specifications is available within the .zip version of the specification.


Usage:

saxon -o dom2-interfaces.xml core/dom-spec.xml combine-dom2.xsl


-->

<!--
$Log: dom2-combine.xsl,v $
Revision 1.3  2003-01-20 06:14:36  dom-ts-4
Move change of Element.getElementByTagName from patch file to here.

Revision 1.2  2001/07/20 05:44:32  dom-ts-4
Initial SVG support.  multiply renamed mult,
All implementation conditions combined into implementationAttribute element

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:variable name="specTitle" select="/spec/header/title"/>

	<!--  match document root    -->
	<xsl:template match="/">
		<xsl:comment>
Copyright (c) 2001 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Document
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
</xsl:comment>
		<xsl:comment>This file is an extract of interface definitions from <xsl:value-of select="$specTitle"/></xsl:comment>
		<!--  must enclose interface elements in
		       some container, chose library ala COM 
			   Type Library   -->
		<library>
			<!--   walk through all child elements  -->
			<xsl:apply-templates select="*"/>
			<xsl:apply-templates select="document('../views/dom-spec.xml',.)/spec/*"/>
			<xsl:apply-templates select="document('../events/dom-spec.xml',.)/spec/*"/>
			<xsl:apply-templates select="document('../style/dom-spec.xml',.)/spec/*"/>
			<xsl:apply-templates select="document('../traversal-range/dom-spec.xml',.)/spec/*"/>
			<xsl:apply-templates select="document('../html/dom-spec.xml',.)/spec/*"/>
		</library>
	</xsl:template>
	
	<!--   replicate attributes   -->
	<xsl:template match="@*">
		<xsl:attribute name="{local-name(.)}" namespace="{namespace-uri(.)}"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	
	<!--   if unrecognized element, apply templates to children  -->	       
	<xsl:template match="*">
		<xsl:apply-templates select="*"/>
	</xsl:template>

	<!--   if interface element
	          produce <interface> element    -->	
	<xsl:template match="interface">
		<interface>
			<!--   replicate attributes   -->
			<xsl:apply-templates select="@*"/>
			<!--   process children and text content in "interface" mode  -->				
			<xsl:apply-templates select="*|text()" mode="interface"/>
		</interface>
	</xsl:template>

	<xsl:template match="exception[@id]">
		<exception>
			<!--   replicate attributes   -->
			<xsl:apply-templates select="@*"/>
			<!--   process children and text content in "interface" mode  -->				
			<xsl:apply-templates select="*|text()" mode="interface"/>
		</exception>
		<!--  must also bring following group element  -->
		<xsl:apply-templates select="following-sibling::group[1]" mode="interface"/>
	</xsl:template>


	<!--    if interface mode, replicate any element   -->
	<xsl:template match="*" mode="interface">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="*|text()" mode="interface"/>
		</xsl:element>
	</xsl:template>
	
	<!--    if interface mode, replicate any text    -->
	<xsl:template match="text()" mode="interface">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="xspecref" mode="interface">
		<xsl:apply-templates select="*" mode="interface"/>
	</xsl:template>

	<xsl:template match="loc" mode="interface">
		<xsl:apply-templates select="*" mode="interface"/>
	</xsl:template>


    <!--  change parameter 'name' to 'tagname' on Elements.getElementByTagName'   -->
    <xsl:template match="param[@name='name' and ancestor::method/@name='getElementsByTagName']" mode="interface">
        <param> 
            <!--  element all existing attributes    -->
			<xsl:apply-templates select="@*"/>
            <!--  overwrite the name attribute  -->
            <xsl:attribute name="name">tagname</xsl:attribute>
            <!--  produce the element content   -->
			<xsl:apply-templates select="*|text()" mode="interface"/>
		</param>
    </xsl:template>

</xsl:stylesheet>
