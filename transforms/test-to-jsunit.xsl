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


<xsl:output method="html"/>

<xsl:template match="/">
    <html>
        <head>
            <title>JsUnit Assertion Tests</title>
            <script language="JavaScript" src="DOMTestCase.js"></script>
            <script language="JavaScript">
                <xsl:apply-templates/>
            </script>
        </head>
        <body>
            <p class="jsUnitHeading"><xsl:value-of select="/*/@name"/></p>
            <p class="jsUnitDefault">This page contains test "<xsl:value-of select="/*/@name"/>".</p>
            <xsl:for-each select="*[local-name() = 'test']">
                <xsl:for-each select="*[local-name() = 'load' and @href]">
                    <iframe id="{@var}.xml" src="{@href}.xml"></iframe>
                    <xsl:if test="@href != 'staff' and @href != 'nodtdstaff'">
                        <iframe id="{@var}.html" src="{@href}.html"></iframe>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </body>
    </html>
</xsl:template>


</xsl:stylesheet>
