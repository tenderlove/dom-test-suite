<!--
Copyright (c) 2001-2003 World Wide Web Consortium,
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
    <xsl:param name="testpath">../level1/core/</xsl:param>
	<!--  relative to transform   -->

    <xsl:import href="test-to-ecmascript.xsl"/>


<xsl:output method="html"/>

<xsl:template match="/">
    <xsl:apply-templates mode="jsunit"/>
</xsl:template>

<xsl:template match="*[local-name() = 'test']" mode="jsunit">
    <xsl:variable name="loads" select="*[local-name() = 'load' and not(@interface)]"/>
    <html>
        <head>
            <title><xsl:value-of select="@name"/></title>
            <link rel="stylesheet" href="../../jsunit/css/jsUnitStyle.css"/>
            <script language="JavaScript" src="../../jsunit/app/jsUnitCore.js"></script>
            <script language="JavaScript">
var testURL = window.location.href;
var fileBase = testURL.substring(0, testURL.lastIndexOf("/")) + "/files/";
</script>
            <script language="JavaScript" src="DOMTestCase.js"></script>
            <script language="JavaScript">
// expose test function names
function exposeTestFunctionNames()
{
return ['<xsl:value-of select="@name"/>'];
}

var docsLoaded = -1000000;

function setUpPage() {
   setUpPageStatus = 'running';
   docsLoaded = 0;<xsl:for-each select="$loads">
   <xsl:text>
   docsLoaded += preload(this.</xsl:text><xsl:value-of select="@var"/>, "<xsl:value-of select="@var"/>", "<xsl:value-of select="@href"/>");</xsl:for-each>
   if (docsLoaded == <xsl:value-of select="count($loads)"/>) {
      setUpPage = 'complete';
   }
}

function loadComplete() {
    if (++docsLoaded == <xsl:value-of select="count($loads)"/>) {
        setUpPageStatus = 'complete';
    }
}

<xsl:apply-templates select="."/>
</script>
        </head>
        <body>
            <p class="jsUnitHeading"><xsl:value-of select="@name"/></p>
            <p class="jsUnitDefault">This page contains test "<xsl:value-of select="@name"/>".</p>
            <xsl:for-each select="$loads">
                <iframe name="{@var}" onload='loadComplete()'></iframe>
            </xsl:for-each>
        </body>
    </html>
</xsl:template>


<xsl:template match="*[local-name() = 'suite']" mode="jsunit">
    <html>
        <head>
            <title><xsl:value-of select="@name"/></title>
            <link rel="stylesheet" href="../../jsunit/css/jsUnitStyle.css"/>
            <script language="JavaScript" src="../../jsunit/app/jsUnitCore.js"></script>
            <script language="JavaScript">
            <xsl:text>
function suite() {
    var newsuite = new top.jsUnitTestSuite(); 
    </xsl:text>
    <xsl:for-each select="*[local-name()='suite.member']">
        <xsl:text>newsuite.addTestPage('</xsl:text>
        <xsl:value-of select="$testpath"/>
        <xsl:value-of select="substring-before(@href,'.')"/>
        <xsl:text>.html');
    </xsl:text>
    </xsl:for-each>
    <xsl:text>
    return newsuite;
}
</xsl:text>
</script>
        </head>
        <body>
            <p class="jsUnitHeading"><xsl:value-of select="@name"/></p>
            <p class="jsUnitDefault">This page contains test suite "<xsl:value-of select="@name"/>".</p>
        </body>
    </html>
</xsl:template>

</xsl:stylesheet>
