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
This transform generates HTML pages for use with JSUnit.


Usage:

saxon -o someTest.html someTest.xml test-to-jsunit.xsl


-->



<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!--  relative to transform   -->

    <xsl:import href="test-to-ecmascript.xsl"/>
    <xsl:variable name="jsunitapp">../../../lib/jsunit/app/</xsl:variable>


<xsl:output method="html"/>

<xsl:template match="/">
    <html>
        <head>
            <link rel="stylesheet" href="{$jsunitapp}jsUnitStyle.css"/>
            <title>JsUnit Assertion Tests</title>
            <script language="JavaScript" src="{$jsunitapp}jsUnitCore.js"></script>
            <script language="JavaScript" src="{$jsunitapp}jsUnitUtility.js"></script>
            <script language="JavaScript" src="DOMTestCase.js"></script>
            <script language="JavaScript">
                <xsl:apply-templates/>
                <xsl:apply-templates select="*" mode="jsunit"/>
            </script>
        </head>
        <body>
            <p class="jsUnitHeading"><xsl:value-of select="/*/@name"/></p>
            <p class="jsUnitDefault">This page contains test "<xsl:value-of select="/*/@name"/>".</p>
        </body>
    </html>
</xsl:template>

<xsl:template match="*[local-name() = 'test']" mode="jsunit">
   function test<xsl:value-of select="@name"/>() {
       var test = null;
       try {
           test = new <xsl:value-of select="@name"/>(factory);
       }
       catch(ex) {
       }
       if(test != null) {
           test.runTest();
       }
   }
</xsl:template>

<xsl:template match="*[local-name() = 'suite']" mode="jsunit">
    <xsl:for-each select="*[local-name() = 'suite.member']">
        <xsl:apply-templates select="document(@href,.)/*" mode="jsunit"/>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
