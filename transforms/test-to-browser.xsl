<?xml version="1.0" encoding="UTF-8"?>
<!--
Copyright (c) 2002 World Wide Web Consortium,
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
This transform generates HTML page that will execute
the test or test suite
-->

<xsl:stylesheet version="1.0" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

    <xsl:import href="test-to-ecmascript.xsl"/>

     <xsl:param name="interfacesURL">../build/dom1-interfaces.xml</xsl:param>
     <xsl:param name="specURI">http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core#</xsl:param>
     <xsl:param name="specMetadataURL">../build/dom1-subjects.xml</xsl:param>
     <xsl:param name="buildPath">tests/</xsl:param>
     <xsl:param name="doxyPath">doxygen/html/class</xsl:param>


	<xsl:output method="html"/>



	<!--  match document root    -->
	<xsl:template match="/">
        <html>
		<head>
			<title>DOM Level 1 Core Test Suite Runner</title>
			<link href="http://www.w3.org/StyleSheets/activity-home.css" rel="stylesheet" type="text/css" />
            <script language="javascript" type="text/ecmascript" href="DOMTestSuite.js"/>
            <script language="javascript" type="text/ecmascript">

<!--  produce ECMAScript code using test-to-ecmascript  -->
<xsl:apply-templates/>


function getMediaType() {
    alert("enter media type");
	var mediaType = "text/xml";
	var mediaButtons = document.undertest.media;
	for(var i = 0; i &lt; mediaButtons.length; i++) {
		if(mediaButtons[i].checked) {
			mediaType = mediaButtons[i].value;
			break;
		}
	}
	alert("media type = " + mediaType);
    return mediaType;
}

function getFactory(mediaType) {
	alert("getFactory");
	var impl = "dom3";
	var implButtons = document.undertest.impl;
	for(var i = 0; i &lt; implButtons.length; i++) {
		if(implButtons[i].checked) {
			impl = implButtons[i].value;
			break;
		}
	}
	alert("impl = " + impl);
    alert("validating = " + document.undertest.validating.checked);
	alert("asych = " + document.undertest.asynch.checked);

    var extension = ".xml";
    switch(mediaType) {
        case "image/xml+svg":
        extension = ".svg";
        break;

        case "text/html":
        extension = ".html";
        break;
    }

    var features = new Array();
    var values = new Array();
    features[0] = "validating";
    values[0] = document.undertest.validating.checked;

    switch(impl) {
        case "docload":
        builder = new DocumentLoadDocumentBuilder(feature, values, extension, asynch);

        case "windowopen":
        builder = new WindowOpenDocumentBuilder(features, values, extension, asynch);
        break;

        case "msxml3":
        if(mediaType == "text/html") {
            throw "MSXML3 does not parse HTML";
        }
        builder = new MSXMLDocumentBuilder(features, values, "MSXML2.DOMDocument.3.0", asynch);
        break;

        case "msxml4":
        if(mediaType == "text/html") {
            throw "MSXML4 does not parse HTML";
        }
        builder = new MSXMLDocumentBuilder(features, values, "MSXML2.DOMDocument.4.0", asynch);
        break;

        case "adobesvg":
        if(mediaType != "image/xml+svg") {
            throw "Adobe SVG Viewer only parses SVG";
        }
        builder = new AdobeSVGDocumentBuilder(features, values, asynch);
    }
    return builder;
}


function runAll() {
    alert("Run All");
}


<xsl:apply-templates mode="funcRunTest"/>
            </script>
		</head>
        	<body>
		<h1>DOM Level 1 Core Test Suite Runner</h1>
        <table width="100%">
            <tr>    
                <form name="undertest" onsubmit="">
                    <table width="100%">
                        <tr>
                            <td width="40%">Implementation</td>
                            <td  width="20%">Media Type</td>
                            <td  width="20%">Configuration</td>
                            <td/>
                        </tr>
                        <tr>
                            <td>
                                <table width="100%">
                                    <tr><td><input type="radio" name="impl" enabled="false" checked="true" value="dom3">DOM L3 Load/Save</input></td></tr>
                                    <tr><td><input type="radio" name="impl" enabled="true" value="docload">document.load</input></td></tr>
                                    <tr><td><input type="radio" name="impl" enabled="true" value="windowopen">window.open</input></td></tr>
                                    <tr><td><input type="radio" name="impl" enabled="true" value="msxml3">MSXML2.DOMDocument.3.0</input></td></tr>
                                    <tr><td><input type="radio" name="impl" enabled="true" value="msxml4">MSXML2.DOMDocument.4.0</input></td></tr>
                                    <tr><td><input type="radio" name="impl" enabled="true" value="adobesvg">Adobe SVG Control</input></td></tr>
                                </table>
                            </td>
                            <td>
                                <table width="100%">
                                    <tr><td><input type="radio" name="media" enabled="true" checked="true" value="text/xml">XML</input></td></tr>
                                    <tr><td><input type="radio" name="media" enabled="false" value="html">HTML</input></td></tr>
                                    <tr><td><input type="radio" name="media" enabled="true" value="svg">SVG</input></td></tr>
                                </table>
                            </td>
                            <td>
                                <table width="100%">
                                    <tr><td><input type="checkbox" name="asynch">Asynchronous</input></td></tr>
                                    <tr><td><input type="checkbox" name="validating">Validating</input></td></tr>
                                </table>
                            </td>
                            <td align="center">
                                <input type="submit" value="Run All" onclick="runAll()"/>
                            </td>
                        </tr>
                    </table>
                </form>
            </tr>
            <tr>
                <table width="100%">
                    <tr>
                        <td width="80%">Test name</td>
                        <td align="center"></td>
                    </tr>
                    <xsl:apply-templates mode="testTable"/>
                </table>
            </tr>
        </table>
		
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

    <xsl:template match="*[local-name() = 'test']" mode="testTable">
        <tr id="{@name}">
            <td>
                <a href="{@name}.xml"><xsl:value-of select="@name"/></a>
            </td>
            <td align="center">
                <input type="submit" value="Run" onclick="runTest_{@name}()"/>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="*[local-name() = 'test']" mode="funcRunTest">
        <xsl:text>function runTest_</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>() {
    var test = new </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>(getFactory(), getMediaType());
    testRunner(test);
}
</xsl:text>
    </xsl:template>


    <xsl:template match="*[local-name() = 'suite']" mode="funcRunTest">
        <xsl:text>function runTest_</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>() {
    var mediaType = getMediaType();
    var test = new </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>(getFactory(mediaType), mediaType);
    testRunner(test);
}
</xsl:text>
    </xsl:template>

</xsl:stylesheet>
