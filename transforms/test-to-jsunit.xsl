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
    <xsl:import href="test-to-ecmascript.xsl"/>
    <xsl:param name="testpath">../level1/core/</xsl:param>


<xsl:output method="html"/>

<xsl:template match="/">
    <xsl:apply-templates mode="jsunit"/>
</xsl:template>

<xsl:template match="*[local-name() = 'test']" mode="jsunit">
    <xsl:variable name="loads" select="*[local-name() = 'load' and not(@interface)]"/>
    <html>
        <xsl:call-template name="copyright"/>
        <head>
            <title><xsl:value-of select="@name"/></title>
            <link rel="stylesheet" href="../../jsunit/css/jsUnitStyle.css"/>
            <script language="JavaScript" src="../../jsunit/app/jsUnitCore.js"></script>
            <script language="JavaScript" src="DOMTestCase.js"></script>
            <script language="JavaScript">
// expose test function names
function exposeTestFunctionNames()
{
return ['<xsl:value-of select="@name"/>'];
}

var docsLoaded = -1000000;
var setUpException = null;

//
//   This function is called by the testing framework before
//      running the test suite.
//
//   If there are no configuration exceptions, asynchronous
//        document loading is started.  Otherwise, the status
//        is set to complete and the exception is immediately
//        raised when entering the body of the test.
//
function setUpPage() {
   setUpPageStatus = 'running';
   try {
     if (builder.exception != null) {
        throw builder.exception;
     }     
<xsl:for-each select="*[local-name() = 'hasFeature' and not(preceding-sibling::*[local-name()='var'])]">
    <xsl:text>       checkFeature(</xsl:text>
    <xsl:value-of select="@feature"/>
    <xsl:text>, </xsl:text>
    <xsl:choose>
        <xsl:when test="@version">
            <xsl:value-of select="@version"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>null</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:text>);
</xsl:text>
</xsl:for-each>
<xsl:for-each select="*[local-name() = 'implementationAttribute']">
    <xsl:text>       setImplementationAttribute("</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>", </xsl:text><xsl:value-of select="@value"/><xsl:text>);
</xsl:text>
</xsl:for-each>
       docsLoaded = 0;<xsl:for-each select="$loads">
       <xsl:text>
       docsLoaded += preload(this.</xsl:text><xsl:value-of select="@var"/>, "<xsl:value-of select="@var"/>", "<xsl:value-of select="@href"/>");</xsl:for-each>
       if (docsLoaded == <xsl:value-of select="count($loads)"/>) {
          setUpPage = 'complete';
       }
    } catch(ex) {
        setUpException = ex;
        setUpPage = 'complete';
    }
}

//
//   This method is called on the completion of 
//      each asychronous load started in setUpTests.
//
//   When every synchronous loaded document has completed,
//      the page status is changed which allows the
//      body of the test to be executed.
function loadComplete() {
    if (++docsLoaded == <xsl:value-of select="count($loads)"/>) {
        setUpPageStatus = 'complete';
    }
}

function checkSetUp() {
    if (setUpException != null) {
        throw setUpException;
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
        <xsl:call-template name="copyright"/>
        <head>
            <title><xsl:value-of select="@name"/></title>
            <link rel="stylesheet" href="../../jsunit/css/jsUnitStyle.css"/>
            <script language="JavaScript" src="../../jsunit/app/jsUnitCore.js"></script>
            <script language="JavaScript" src="DOMTestCase.js"></script>
            <script language="JavaScript" src="DOMTestSuite.js"></script>
            <script language="JavaScript">

//
//  This function evaluates all tests and suites that appear in
//     the suite definition.  Tests that are compatible
//     are added to the compatible array, other tests
//     to the incompatible.  Either array may be null
//     and they may be the same to collect all tests
//
function checkTests(compatible, incompatible) {
<xsl:for-each select="*[local-name()='suite.member']">
    <xsl:apply-templates select="document(@href,.)/*" mode="suite"/>
</xsl:for-each>
}

//
//   builds the test suite definition from all the
//       tests compatible with the current parser settings
//
function suite() {
    var newsuite = new top.jsUnitTestSuite(); 
    var compatible = new Array();
    checkTests(compatible, null);
    for (i = 0; i &lt; compatible.length; i++) {
        newsuite.addTestPage("<xsl:value-of select="$testpath"/>" + compatible[i] + ".html");
    }
    return newsuite;
}
</script>
        </head>
        <body>
            <form id="configuration" action="../../jsunit/testRunner.html" target="jsunit" onsubmit="fixTestPagePath()">
            <table width="100%" border="1">
                <tr><td>                    
                    <table width="100%">
                        <tr>
                            <td>Test: </td>
                            <td>
                                <select name="testpage" size="1">
                                    <option selected="selected" value="alltests.html">All applicable tests</option>
                                    <xsl:for-each select="*[local-name() = 'suite.member']">
                                        <option value="{substring-before(@href,'.')}.html"><xsl:value-of select="substring-before(@href, '.')"/></option>
                                    </xsl:for-each>
                                </select>
                            </td>
                            <td align="right">
                                <input type="submit" value="Load JSUnit"></input>
                            </td>
                        </tr>
                    </table>
                    </td>
                </tr>
                <tr>
                    <td>
                    <table border="1" width="100%">
                    <tr>
                    <td valign="top">
                        <table>
                            <tr><th>Implementation</th></tr>
                            <tr><td><input type="radio" name="implementation" value="iframe" checked="checked" onclick="onImplementationChange()">iframe</input></td></tr>
                            <tr><td><input disabled="true" type="radio" name="implementation" value="dom3" onclick="onImplementationChange()">DOM 3 Load/Save</input></td></tr>
                            <tr><td><input type="radio" name="implementation" value="mozillaXML" onclick="onImplementationChange()">Mozilla XML</input></td></tr>
                            <tr><td><input type="radio" name="implementation" value="msxml3" onclick="onImplementationChange()">MSXML 3.0</input></td></tr>
                            <tr><td><input type="radio" name="implementation" value="msxml4" onclick="onImplementationChange()">MSXML 4.0</input></td></tr>
                            <tr><td><input type="radio" name="implementation" value="svgplugin" onclick="onImplementationChange()">SVG Plugin</input></td></tr>
                        </table>
                    </td>
                    <td valign="top">
                        <table>
                            <tr><th>Configuration</th><th>True</th><th>False</th></tr>
<tr>
<td>Asynchronous</td><td align="center"><input onclick="setAsynchronous(true)" value="true" name="asynchronous" type="radio" checked="checked" disabled="disabled"/></td><td align="center"><input onclick="setAsynchronous(false)" disabled="disabled" value="false" name="asynchronous" type="radio"/></td>
</tr>

                            <tr>
                                <td>Expanding Entities</td>
                                <td align="center"><input type="radio" 
                                    name="expandEntityReferences" 
                                    value="true" 
                                    disabled="disabled"
                                    onclick="setImplementationAttribute('expandEntityReferences', true)"></input></td>
                                <td align="center"><input type="radio" name="expandEntityReferences" checked="checked" disabled="true" value="false" onclick="setImplementationAttribute('expandEntityReferences', false)"></input></td>
                            </tr>
                            <tr>
                                <td>Ignoring whitespace</td>
                                <td align="center"><input type="radio" name="ignoringElementContentWhitespace" value="true" disabled="disabled" onclick="setImplementationAttribute('ignoringElementContentWhitespace', true)"></input></td>
                                <td align="center"><input type="radio" name="ignoringElementContentWhitespace" value="false"  disabled="disabled" checked="checked" onclick="setImplementationAttribute('ignoringElementContentWhitespace', false)"></input></td>
                            </tr>
                            <tr>
                                <td>Validating</td>
                                <td align="center"><input type="radio" name="validating" value="true"  disabled="disabled" onclick="setImplementationAttribute('validating', true)"></input></td>
                                <td align="center"><input type="radio" name="validating" value="false"  disabled="disabled" checked="checked" onclick="setImplementationAttribute('validating', true)"></input></td>
                            </tr>
                            <tr>
                                <td>Coalescing</td>
                                <td align="center"><input type="radio" name="coalescing" value="true"  disabled="disabled" onclick="setImplementationAttribute('coalescing', true)"></input></td>
                                <td align="center"><input type="radio" name="coalescing" value="false"  disabled="disabled" checked="checked" onclick="setImplementationAttribute('coalescing', true)"></input></td>
                            </tr>
                            <tr>
                                <td>Namespace aware</td>
                                <td align="center"><input type="radio" name="namespaceAware" value="true"  disabled="disabled" onclick="setImplementationAttribute('namespaceAware', true)"></input></td>
                                <td align="center"><input type="radio" name="namespaceAware" value="false"  disabled="disabled" checked="checked" onclick="setImplementationAttribute('namespaceAware', true)"></input></td>
                            </tr>
                        </table>
                    </td>
                    <td valign="top">
                        <table>
                            <tr><th>Content Type</th></tr>
                            <tr><td><input type="radio" name="contentType" value="text/xml" onclick="setContentType('text/xml')">XML</input></td></tr>
                            <tr><td><input type="radio" name="contentType" value="text/html" checked="true" onclick="setContentType('text/html')">HTML</input></td></tr>
                            <tr><td><input type="radio" name="contentType" value="application/xhtml+xml" onclick="setContentType('application/xhtml+xml')">XHTML</input></td></tr>
                            <tr><td><input type="radio" name="contentType" value="image/svg+xml" onclick="setContentType('image/svg+xml')">SVG</input></td></tr>
                            <tr><td><input disabled="disabled" type="radio" name="contentType" value="text/mathml" onclick="setContentType('text/mathml')">MathML</input></td></tr>
                        </table>
                    </td>
                </tr>
                </table>
                <tr>
                    <td>
<table width="100%">
<tr><td>The following tests are incompatible with the current settings</td></tr>
<tr><td>
<select name="incompatible" size="10">
<option>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;</option>
</select></td></tr>
</table>
                    </td>
                </tr>
                </td>
                </tr>
            </table>
            </form>
        </body>
    </html>
</xsl:template>

<xsl:template match="*[local-name()='test']" mode="suite">
    <xsl:text>checkTest(compatible, incompatible, "</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>", </xsl:text>
    <xsl:variable name="loads" select="*[local-name() = 'load' and not(@interface)]"/>
    <xsl:choose>
        <xsl:when test="$loads">
            <xsl:text>[ </xsl:text>
            <xsl:for-each select="$loads">
                <xsl:if test="position() &gt; 1">, </xsl:if>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="@href"/>
                <xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:text> ], </xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>null, </xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="features" select="*[local-name() = 'hasFeature' and not(preceding-sibling::*[local-name()='var'])]"/>
    <xsl:choose>
        <xsl:when test="$features">
            <xsl:text>[ </xsl:text>
            <xsl:for-each select="$features">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="@feature"/>
            </xsl:for-each>
            <xsl:text> ], [</xsl:text>
            <xsl:for-each select="$features">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="@version">
                        <xsl:text>, "</xsl:text>
                        <xsl:value-of select="@version"/>
                        <xsl:text>" </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>, null </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:text>], </xsl:text>
         </xsl:when>
        <xsl:otherwise>
            <xsl:text>null, null, </xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="implAttrs" select="*[local-name() = 'implementationAttribute']"/>
    <xsl:choose>
        <xsl:when test="$implAttrs">
            <xsl:text>[ </xsl:text>
            <xsl:for-each select="$implAttrs">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:text>"</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>"</xsl:text>
            </xsl:for-each>
            <xsl:text>], [</xsl:text>
            <xsl:for-each select="$implAttrs">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="@value"/>
            </xsl:for-each>
            <xsl:text> ]);
</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>null, null);
</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="copyright">
<xsl:comment>
Copyright (c) 2001-2003 World Wide Web Consortium,
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
