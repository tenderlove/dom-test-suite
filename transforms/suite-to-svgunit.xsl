<!--
Copyright (c) 2004 World Wide Web Consortium,
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
This transform generates an Ant file that prepares SVG tests.


Usage:

saxon -o alltests.ant alltests.xml suite-to-svgunit.xsl


-->



<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
    <xsl:apply-templates mode="jsunit"/>
</xsl:template>


<xsl:template match="*[local-name() = 'suite']" mode="jsunit">
    <xsl:call-template name="copyright-comment"/>
    <project default="make-svg">
    <target name="make-svg">
    	<xsl:for-each select="*[local-name() = 'suite.member']">
    		<xsl:variable name="test" select="document(@href, .)"/>
    		<xsl:variable name="testname" select="$test/*/@name"/>
    		<xsl:variable name="loads" select="$test/*/*[local-name() = 'load']"/>
		    <xsl:variable name="testdst" select="concat('${svg.dir}/', concat($testname, '.svg'))"/>
    		<xsl:choose>
    			<xsl:when test="$loads">
		    		<xsl:for-each select="$loads">
		    			<xsl:if test="position() = 1">
		    				<xsl:variable name="testsrc" select="concat('${files.dir}/', concat(@href, '.svg'))"/>
		    				<copy tofile="{$testdst}" file="{$testsrc}" overwrite="yes"/>
		    			</xsl:if>
		    		</xsl:for-each>
		    	</xsl:when>
		    	<xsl:otherwise>
		    			<copy tofile="{$testdst}" overwrite="yes">
		    				<xsl:attribute name="file">${ecmascript.dir}/implementation.svg</xsl:attribute>
		    			</copy>
		    			<replace file="{$testdst}" token="svgtest.js" value="{$testname}.js"/>		    		
		    	</xsl:otherwise>
		    </xsl:choose>
		    <replace file="{$testdst}" token="svgtest.js" value="{$testname}.js"/>		    	
    	</xsl:for-each>
    </target>
    </project>
</xsl:template>



<xsl:template name="copyright-comment">
<xsl:comment>
Copyright (c) 2001-2004 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
</xsl:comment>
</xsl:template>


</xsl:stylesheet>
