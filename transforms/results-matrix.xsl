<?xml version="1.0" encoding="UTF-8"?>
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
     <xsl:param name="doxyPath">doxygen/html/</xsl:param>
     <xsl:param name="doxySuffix">_8java-source.html</xsl:param>
     <xsl:param name="title">DOM Level 1 Core Test Suite Matrix</xsl:param>
     <xsl:param name="resultsURL">../transforms/dom1-core-results.xml</xsl:param>
	<xsl:output method="html"/>

    <!--   filter subjects by specification    -->
    <xsl:variable name="subjects" select="document($specMetadataURL,.)/rdf:RDF/rdf:Description[contains(@rdf:about,$specURI)]"/>

    <xsl:variable name="interfacesDoc" select="document($interfacesURL,.)"/>

    <xsl:variable name="interfaces" select="$interfacesDoc//interface[concat($specURI,@id) = $subjects/@rdf:about]"/>
    <xsl:variable name="methods" select="$interfaces/method"/>
    <xsl:variable name="attributes" select="$interfaces/attribute"/>
    <xsl:variable name="descriptions" select="/rdf:RDF/rdf:Description"/>
    <xsl:variable name="results" select="document($resultsURL,.)//testsuite"/>
    <xsl:variable name="tests" select="$descriptions[not(contains(@rdf:about, 'alltests')) and substring(@rdf-about, string-length(@rdf:about)) != '/']"/>

	<!--  match document root    -->
	<xsl:template match="/">
        <html>
		<head>
			<title><xsl:value-of select="$title"/></title>
			<link href="http://www.w3.org/StyleSheets/activity-home.css" rel="stylesheet" type="text/css" />
		</head>
        	<body>
		<h1><xsl:value-of select="$title"/></h1>
		<p> 
</p>
				

        <table border="1" cols="{2 + count($results)}" width="100%">
        	<thead>Tests with failures</thead>
            <tr>
            	<th>Test</th>
            	<th>Description</th>
            	<xsl:for-each select="$results">
            		<th><xsl:value-of select="ancestor::implementation/@name"/></th>
            	</xsl:for-each>
            </tr>
            <xsl:for-each select="$descriptions">
                <xsl:sort select="dc:title"/>
                
                <xsl:choose>
                	<xsl:when test="contains(@rdf:about, 'alltests')"/>
                	<xsl:when test="substring(@rdf:about, string-length(@rdf:about)) = '/'"/> 
                
                <!--  if there aren't the same number of successes and implementations   -->
                <xsl:when test="count($results) != count($results/testcase[@name = current()/@rdf:about and not(failure) and not(error)])">

                <xsl:variable name="test" select="."/>
                <tr>
                    <td width="25%">
                    <xsl:variable name="testName"><xsl:value-of select="dc:title" /></xsl:variable>                             
                    <xsl:call-template name="emit-title"/>
                    <xsl:text> (</xsl:text> 
        		    <a href="{concat($buildPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.xml'))}" title="{dc:description}">XML</a>
                    <xsl:text> </xsl:text>
        		    <a href="{concat($doxyPath,concat(translate($testName, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),$doxySuffix))}" title="{dc:description}">Java</a>
                    <xsl:text>)</xsl:text>
                    </td>
                    <td>
                    	<xsl:value-of select="dc:description"/>
                    </td>
                    <xsl:for-each select="$results">
                    	<td>
                    		<xsl:variable name="test-result" select="testcase[@name = $test/@rdf:about]"/>
                    		<xsl:choose>
                    			<xsl:when test="$test-result/failure">
                    				<div title="{$test-result/failure[@message]}">Failure</div>
                    			</xsl:when>
                    			
                    			<xsl:when test="$test-result/error">
                    				<div title="{$test-result/error[@message]}">Error</div>
                    			</xsl:when>
                    			
                    			<xsl:when test="$test-result">
                    				<xsl:text>Success</xsl:text>
                    			</xsl:when>
                    			
                    			<xsl:otherwise>
                    				<xsl:text>Not run</xsl:text>
                    			</xsl:otherwise>
                    		</xsl:choose>
                    	</td>
                    </xsl:for-each>
                    	
                </tr>
                </xsl:when>
                <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </table>     



        <table border="1" cols="2" width="100%">
        	<thead>Tests passed by all implementations</thead>
            <tr>
            	<th>Test</th>
            	<th>Description</th>
            </tr>
            <xsl:for-each select="$descriptions">
                <xsl:sort select="dc:title"/>
                
                <xsl:choose>
                	<xsl:when test="contains(@rdf:about, 'alltests')"/>
                	<xsl:when test="substring(@rdf:about, string-length(@rdf:about)) = '/'"/> 
                
                <!--  if there aren't the same number of successes and implementations   -->
                <xsl:when test="count($results) = count($results/testcase[@name = current()/@rdf:about and not(failure) and not(error)])">
                <tr>
                    <td width="25%">
                    <xsl:variable name="testName"><xsl:value-of select="dc:title" /></xsl:variable>                             
                    <xsl:call-template name="emit-title"/>
                    <xsl:text> (</xsl:text> 
        		    <a href="{concat($buildPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'.xml'))}" title="{dc:description}">XML</a>
                    <xsl:text> </xsl:text>
        		    <a href="{concat($doxyPath,concat(translate($testName, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),$doxySuffix))}" title="{dc:description}">Java</a>
                    <xsl:text>)</xsl:text>
                    </td>
                    <td>
                    <xsl:value-of select="dc:description"/>
                    </td>
                </tr>
                </xsl:when>
                <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </table>     

                <!--  the copyright notice placed in the output file.    -->
		
			<br />
			<xsl:text>Tests in this table are released under the </xsl:text><a 
href="resources/COPYRIGHT.html">W3C Software 
Copyright Notice and License</a><xsl:text>:</xsl:text>
			<br />
			<xsl:text>Copyright (c) 2001-2003 World Wide Web Consortium,
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
		    <a href="{concat($doxyPath,concat(translate($testName,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),$doxySuffix))}" title="{dc:description}">Java</a>
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
