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
This transform generates a test matrix from the output of subjects.xsl
and combine-metadata.xsl


-->

<xsl:stylesheet version="1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
     <xsl:param name="interfacesURL">../build/dom1-interfaces.xml</xsl:param>
     <xsl:param name="specURI">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#</xsl:param>
     <xsl:param name="specMetadataURL">../build/dom1-subjects.xml</xsl:param>
     <xsl:param name="buildPath">tests/</xsl:param>
     <xsl:param name="doxyPath">doxygen/html/class</xsl:param>
     <xsl:param name="title">DOM Level 1 Core Test Suite Matrix</xsl:param>

	<xsl:output method="html"/>

    <!--   filter subjects by specification    -->
    <xsl:variable name="subjects" select="document($specMetadataURL,.)/rdf:RDF/rdf:Description[contains(@rdf:about,$specURI)]"/>

    <xsl:variable name="interfacesDoc" select="document($interfacesURL,.)"/>

    <xsl:variable name="interfaces" select="$interfacesDoc//interface[concat($specURI,@id) = $subjects/@rdf:about]"/>
    <xsl:variable name="methods" select="$interfaces/method"/>
    <xsl:variable name="attributes" select="$interfaces/attribute"/>
    <xsl:variable name="descriptions" select="/rdf:RDF/rdf:Description"/>

	<!--  match document root    -->
	<xsl:template match="/">
        <html>
		<head>
			<title><xsl:value-of select="$title"/></title>
			<link href="http://www.w3.org/StyleSheets/activity-home.css" rel="stylesheet" type="text/css" />
		</head>
        	<body>
		<h1><xsl:value-of select="$title"/></h1>
		<p>Below you will find a description of and pointer to each test in the DOM TS categorized under interface, attribute and method, 
sorted alphabetically. 
</p>

                <xsl:variable name="untestedMethods" select="$methods[not(concat($specURI,@id) = $descriptions/dc:subject/@rdf:resource)]"/>
                <xsl:if test="$untestedMethods">
                    <table col="3" border="1">
                        <thead>Methods with no corresponding test metadata</thead>
                        <xsl:call-template name="rowmethods">
                            <xsl:with-param name="methods" select="$untestedMethods"/>
                            <xsl:with-param name="index">0</xsl:with-param>
                            <xsl:with-param name="columns">1</xsl:with-param>
                        </xsl:call-template>
                    </table>
                </xsl:if>
                <xsl:variable name="untestedAttributes" select="$attributes[not(concat($specURI,@id) = $descriptions/dc:subject/@rdf:resource)]"/>
                <xsl:if test="$untestedAttributes">
                    <table col="3" border="1">
                        <thead>Attributes with no corresponding test metadata</thead>
                        <xsl:call-template name="rowmethods">
                            <xsl:with-param name="methods" select="$untestedAttributes"/>
                            <xsl:with-param name="index">0</xsl:with-param>
                            <xsl:with-param name="columns">1</xsl:with-param>
                        </xsl:call-template>
                    </table>
                </xsl:if>


                <xsl:for-each select="$interfaces">
                    <xsl:sort select="@name"/>
                     <xsl:variable name="interface" select="."/>
			<h2>Interface <xsl:value-of select="@name" /></h2>
			<table border="1" cols="2">
                        <!-- tests which have the interface as a subject  -->
                        <xsl:variable name="interfacetests" select="$descriptions[dc:subject/@rdf:resource= concat($specURI,current()/@id)]"/>
                        <xsl:if test="$interfacetests">
                            <tr>
                                <td width="25%"/>
                                <td>
                                    <table>
                                        <xsl:call-template name="rowtests">
                                            <xsl:with-param name="tests" select="$interfacetests"/>
                                            <xsl:with-param name="index">0</xsl:with-param>
                                            <xsl:with-param name="columns">1</xsl:with-param>
                                        </xsl:call-template>
                                    </table>
                                </td>
                            </tr>
                        </xsl:if>            

                        <xsl:if test="attribute">
                            <tr><th width="25%">Attribute</th><th>Tests</th></tr>
                            <xsl:for-each select="attribute">
                                <xsl:sort select="@name"/>
                                <xsl:variable name="featureURI" select="concat($specURI,@id)"/>
                                <tr>
                                    <td>
                                        <a href="{$featureURI}" title="{descr}">
                                            <xsl:value-of select="@name"/>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:variable name="featuretests" select="$descriptions[dc:subject/@rdf:resource=$featureURI]"/>
                                        <xsl:if test="$featuretests">
                                            <table>
                                                <xsl:call-template name="rowtests">
                                                    <xsl:with-param name="tests" select="$featuretests"/>
                                                    <xsl:with-param name="index">0</xsl:with-param>
                                                    <xsl:with-param name="columns">1</xsl:with-param>
                                                </xsl:call-template>
                                            </table>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </xsl:if>

                        <xsl:if test="method">
                            <tr><th width="25%">Method</th><th>Tests</th></tr>
                            <xsl:for-each select="method">
                                <xsl:sort select="@name"/>
                                <xsl:variable name="featureURI" select="concat($specURI,@id)"/>
                                <tr>
                                    <td>
                                        <a href="$featureURI" title="{descr}">
                                            <xsl:value-of select="@name"/>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:variable name="featuretests" select="$descriptions[dc:subject/@rdf:resource=$featureURI]"/>
                                        <xsl:if test="$featuretests">
                                            <table>
                                                <xsl:call-template name="rowtests">
                                                    <xsl:with-param name="tests" select="$featuretests"/>
                                                    <xsl:with-param name="index">0</xsl:with-param>
                                                    <xsl:with-param name="columns">1</xsl:with-param>
                                                </xsl:call-template>
                                            </table>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </xsl:if>
                    </table>
                </xsl:for-each>

                <table border="1" cols="2">
                    <tr><th>Test</th><th>Subjects</th><th/><th/></tr>
                    <xsl:for-each select="$descriptions">
                        <xsl:sort select="dc:title"/>

                        <xsl:variable name="test" select="."/>
                        <tr>
                            <td width="25%">
		                    <xsl:variable name="testName"><xsl:value-of select="dc:title" /></xsl:variable>                             
                            <xsl:call-template name="emit-title"/>
                            <xsl:text> (</xsl:text> 
                		    <a href="{concat($buildPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.xml'))}" title="{dc:description}">XML</a>
                            <xsl:text> </xsl:text>
                		    <a href="{concat($doxyPath,concat(translate($testName, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.html'))}" title="{dc:description}">Java</a>
                            <xsl:text>)</xsl:text>
                            </td>
                            <td>
                                <xsl:variable name="testsubjects" select="$subjects[@rdf:about = $test/dc:subject/@rdf:resource]"/>
                                <xsl:choose>
                                    <xsl:when test="$testsubjects">
                                        <table>
                                            <xsl:call-template name="rowsubjects">
                                                <xsl:with-param name="subjects" select="$testsubjects"/>
                                                <xsl:with-param name="index">0</xsl:with-param>
                                                <xsl:with-param name="columns">1</xsl:with-param>
                                            </xsl:call-template>
                                        </table>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <p color="red">No subjects defined for test</p>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>     
                <!--  the copyright notice placed in the output file.    -->
		
			<br />
			<xsl:text>Tests in this table are released under the </xsl:text><a 
href="resources/COPYRIGHT.html">W3C Software 
Copyright Notice and License</a><xsl:text>:</xsl:text>
			<br />
			<xsl:text>Copyright (c) 2001 World Wide Web Consortium,
			(Massachusetts Institute of Technology, Institut National de
			Recherche en Informatique et en Automatique, Keio University). All
			Rights Reserved. This program is distributed under the W3C's Software
			Intellectual Property License. This program is distributed in the
			hope that it will be useful, but WITHOUT ANY WARRANTY; without even
			the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
			PURPOSE.</xsl:text>
			<br />
			<xsl:text>See W3C License </xsl:text> <a href="http://www.w3.org/Consortium/Legal/">http://www.w3.org/Consortium/Legal/</a> 
			<xsl:text> for more details.</xsl:text>


	    </body>
        </html>
    </xsl:template>

    <xsl:template name="rowmethods">
        <xsl:param name="methods"/>
        <xsl:param name="index"/>
        <xsl:param name="columns"/>
        <tr>
            <xsl:for-each select="$methods[position() &gt; $index and position() &lt; ($index + $columns + 1)]"> 
                <td>
                    <a href="{concat($specURI,@id)}" title="{descr}">
                        <xsl:value-of select="ancestor::interface/@name"/>
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="@name"/>
                    </a>
                </td>
            </xsl:for-each>
        </tr>
        <xsl:if test="count($methods) &gt; $index + $columns">
            <xsl:call-template name="rowmethods">
                <xsl:with-param name="methods" select="$methods"/>
                <xsl:with-param name="index" select="$index + $columns"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <xsl:template name="rowtests">
        <xsl:param name="tests"/>
        <xsl:param name="index"/>
        <xsl:param name="columns"/>
        <tr>
            <xsl:for-each select="$tests[position() &gt; $index and position() &lt; ($index + $columns + 1)]"> 
                <td>
		    <xsl:variable name="testName"><xsl:value-of select="dc:title" /></xsl:variable>
            <xsl:call-template name="emit-title"/>
            <xsl:text> (</xsl:text>
		    <a href="{concat($buildPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.xml'))}" title="{dc:description}">XML</a>
            <xsl:text> </xsl:text>
		    <a href="{concat($doxyPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.html'))}" title="{dc:description}">Java</a>
            <xsl:text>) </xsl:text>
			<xsl:value-of select="dc:description" />
                </td>
            </xsl:for-each>
        </tr>
        <xsl:if test="count($tests) &gt; $index + $columns">
            <xsl:call-template name="rowtests">
                <xsl:with-param name="tests" select="$tests"/>
                <xsl:with-param name="index" select="$index + $columns"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>



    <xsl:template name="rowsubjects">
        <xsl:param name="subjects"/>
        <xsl:param name="index"/>
        <xsl:param name="columns"/>
        <tr>
            <xsl:for-each select="$subjects[position() &gt; $index and position() &lt; ($index + $columns + 1)]"> 
                <td>
                    <a title="{dc:description}">
						<xsl:call-template name="emit-href"/>
                        <xsl:call-template name="emit-title"/>
                    </a>
                </td>
            </xsl:for-each>
        </tr>
        <xsl:if test="count($subjects) &gt; $index + $columns">
            <xsl:call-template name="rowsubjects">
                <xsl:with-param name="subjects" select="$subjects"/>
                <xsl:with-param name="index" select="$index + $columns"/>
                <xsl:with-param name="columns" select="$columns"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


<xsl:template name="emit-title">
    <xsl:choose>
        <xsl:when test="dc:title">
            <xsl:value-of select="dc:title"/>
        </xsl:when>
		<xsl:when test="dc:description">
			<xsl:value-of select="substring-before(dc:description,':')"/>
		</xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="@rdf:about"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="emit-href">
	<xsl:choose>
		<!--  if we have an XPointer, change it to a fragment identifier -->
		<xsl:when test="contains(@rdf:about,'#xpointer(id(')">
			<xsl:attribute name="href">
				<xsl:value-of select="substring-before(@rdf:about,'#xpointer')"/>
				<xsl:text>#</xsl:text>
				<xsl:variable name="after" select="substring-after(@rdf:about,&quot;#xpointer(id(&apos;&quot;)"/>
				<xsl:value-of select="substring-before($after,&quot;')&quot;)"/>
			</xsl:attribute>
		</xsl:when>
		<xsl:otherwise>
			<xsl:attribute name="href">
				<xsl:value-of select="@rdf:about"/>
			</xsl:attribute>
		</xsl:otherwise>
	</xsl:choose>				
</xsl:template>

</xsl:stylesheet>
