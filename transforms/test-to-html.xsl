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
This transform generates an HTML pretty print representation
of a test file


-->

<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html"/>

<xsl:template match="/">
    <html>
        <head>
            <xsl:apply-templates mode="head"/>
        </head>
        <body>
            <xsl:apply-templates select="*|comment()" mode="body">
                <xsl:with-param name="indent"></xsl:with-param>
            </xsl:apply-templates>
        </body>
    </html>
</xsl:template>

<xsl:template match="*[local-name() = 'test']" mode="head">
    <title>Test <xsl:value-of select="@name"/></title>
</xsl:template>

<xsl:template match="*[local-name()='metadata']" mode="body">
    <xsl:param name="indent"/>
    <xsl:value-of select="$indent"/>
    <xsl:text>&lt;metadata&gt;</xsl:text>
    <br/>
    <xsl:apply-templates select="*" mode="metadata">
          <xsl:with-param name="indent" select="concat('&#160;&#160;&#160;&#160;&#160;',$indent)"/>
    </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="metadata">
    <xsl:param name="indent"/>
    <xsl:value-of select="$indent"/>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:apply-templates select="@*" mode="body"/>
    <xsl:choose>
        <xsl:when test="string-length(normalize-space(text())) &gt; 0">
            <xsl:text>&gt;</xsl:text>
            <xsl:value-of select="text()"/>
            <xsl:text>&lt;/</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>/&gt;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <br/>
</xsl:template>
        

<xsl:template match="*" mode="body">
    <xsl:param name="indent"/>
    <!--  indent the element   -->
    <xsl:value-of select="$indent"/>
    <!--  start the element   -->
    <xsl:text>&lt;</xsl:text>
    <!--  output the tag name   -->
    <xsl:value-of select="local-name()"/>
    <!--  output any attributes  -->
    <xsl:apply-templates select="@*" mode="body"/>

    <xsl:choose>
        <!--  if there are any child elements  -->

        <xsl:when test="*|comment()">
            <!--   then close the start tag  -->
            <xsl:text>&gt;</xsl:text>
            <br/>
            <!--    emit the child elements   -->
            <xsl:apply-templates select="*|comment()|text()" mode="body">
                <xsl:with-param name="indent" select="concat('&#160;&#160;&#160;&#160;&#160;',$indent)"/>
            </xsl:apply-templates>
            <!--  write the end tag   -->
            <xsl:value-of select="$indent"/>
            <xsl:text>&lt;/</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>&gt;</xsl:text>
            <br/>
        </xsl:when>

        <xsl:otherwise>
            <!--  close an empty tag   -->
            <xsl:text>/&gt;</xsl:text>
            <br/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@id" mode="body">
    <xsl:text> </xsl:text>
    <a id="{.}">
        <xsl:text>id='</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
    </a>
</xsl:template>

<xsl:template match="@resource" mode="body">
    <xsl:text> resource='</xsl:text>
    <a href="{.}">
    <xsl:value-of select="."/>
    </a>
    <xsl:text>'</xsl:text>
</xsl:template>

<xsl:template match="@*" mode="body">
    <xsl:text> </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text>='</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>'</xsl:text>
</xsl:template>

<xsl:template match="comment()" mode="body">
    <xsl:param name="indent"/>
    <xsl:value-of select="$indent"/>
    <xsl:text>&lt;!--</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>--&gt;</xsl:text>
    <br/>
</xsl:template>

<xsl:template match="text()">
    <xsl:param name="indent"/>
    <xsl:variable name="normedText" value="normalize-space(.)"/>
    <xsl:if test="string-length($normedText) &gt; 0">
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="$normedText"/>
        <br/>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>
