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
   <xsl:param name="contentType"/>
   function test<xsl:value-of select="@name"/>() {
       var test = null;
       try {
           test = new <xsl:value-of select="@name"/><xsl:text>(factory,</xsl:text>
           <xsl:value-of select="$contentType"/>
           <xsl:if test="not($contentType)">null</xsl:if>);
       }
       catch(ex) {
       }
       if(test != null) {
           test.runTest();
       } 
   }
</xsl:template>

<xsl:template match="*[local-name() = 'suite']" mode="jsunit">
    <xsl:param name="contentType"/>
    <xsl:choose>
        <!--  if a content type was specified at this level, use it   -->
        <xsl:when test="string-length(@contentType) &gt; 0">
            <xsl:variable name="suiteContentType" select="@contentType"/>
            <xsl:for-each select="*[local-name() = 'suite.member']">
                <xsl:apply-templates select="document(@href,.)/*" mode="jsunit">
                    <xsl:with-param name="contentType" select="concat(concat('&quot;',$suiteContentType),'&quot;')"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:when>
        <!--  if specified by an enclosing suite, use its specification   -->
        <xsl:when test="$contentType">
            <xsl:for-each select="*[local-name() = 'suite.member']">
                <xsl:apply-templates select="document(@href,.)/*" mode="jsunit">
                    <xsl:with-param name="contentType" select="$contentType"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:when>
        <!--  use the processors default    -->
        <xsl:otherwise>
            <xsl:for-each select="*[local-name() = 'suite.member']">
                <xsl:apply-templates select="document(@href,.)/*" mode="jsunit">
                    <xsl:with-param name="contentType">null</xsl:with-param>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
