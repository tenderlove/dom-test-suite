/*
Copyright (c) 2001-2003 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
*/
  function assertSize(descr, expected, actual) {
    var actualSize;
    actualSize = actual.length;
    assertEquals(descr, expected, actualSize);
  }

  
  function assertEqualsCollection(descr, expected, actual) {
    //
    //  if they aren't the same size, they aren't equal
    assertEquals(descr, expected.length, actual.length);
    //
    //  if there length is the same, then every entry in the expected list
    //     must appear once and only once in the actual list
    var expectedLen = expected.length;
    var expectedValue;
    var actualLen = actual.length;
    var i;
    var j;
    var matches;
    for(i = 0; i < expectedLen; i++) {
        matches = 0;
        expectedValue = expected[i];
        for(j = 0; j < actualLen; j++) {
            if(expectedValue == actual[j]) {
                matches++;
            }
        }
        if(matches == 0) {
            assert(descr + ": No match found for " + expectedValue,false);
        }
        if(matches > 1) {
            assert(descr + ": Multiple matches found for " + expectedValue, false);
        }
    }
  }


  function assertEqualsList(descr, expected, actual) {
    //
    //  if they aren't the same size, they aren't equal
    assertEquals(descr, expected.length, actual.length);
    //
    var actualLen = actual.length;
    var i;
    for(i = 0; i < actualLen; i++) {
        if(expected[i] != actual[i]) {
			assertEquals(descr, expected[i], actual[i]);
        }
    }
  }

  function assertInstanceOf(descr, type, obj) {
    if(type == "Attr") {
        assertEquals(descr,2,obj.nodeType);
        var specd = obj.specified;
    }
  }

  function assertSame(descr, expected, actual) {
    if(expected != actual) {
        assertEquals(descr, expected.nodeType, actual.nodeType);
        assertEquals(descr, expected.nodeValue, actual.nodeValue);
    }
  }

  function assertURIEquals(assertID, scheme, path, host, file, name, query, fragment, isAbsolute, actual) {
    //
    //  URI must be non-null
    assertNotNull(assertID, actual);

    var uri = actual;

    var lastPound = actual.lastIndexOf("#");
    var actualFragment = "";
    if(lastPound != -1) {
        //
        //   substring before pound
        //
        uri = actual.substring(0,lastPound);
        actualFragment = actual.substring(lastPound+1);
    }
    if(fragment != null) assertEquals(assertID,fragment, actualFragment);

    var lastQuestion = uri.lastIndexOf("?");
    var actualQuery = "";
    if(lastQuestion != -1) {
        //
        //   substring before pound
        //
        uri = actual.substring(0,lastQuestion);
        actualQuery = actual.substring(lastQuestion+1);
    }
    if(query != null) assertEquals(assertID, query, actualQuery);

    var firstColon = uri.indexOf(":");
    var firstSlash = uri.indexOf("/");
    var actualPath = uri;
    var actualScheme = "";
    if(firstColon != -1 && firstColon < firstSlash) {
        actualScheme = uri.substring(0,firstColon);
        actualPath = uri.substring(firstColon + 1);
    }

    if(scheme != null) {
        assertEquals(assertID, scheme, actualScheme);
    }

    if(path != null) {
        assertEquals(assertID, path, actualPath);
    }

    if(host != null) {
        var actualHost = "";
        if(actualPath.substring(0,2) == "//") {
            var termSlash = actualPath.substring(2).indexOf("/") + 2;
            actualHost = actualPath.substring(0,termSlash);
        }
        assertEquals(assertID, host, actualHost);
    }

    if(file != null || name != null) {
        var actualFile = actualPath;
        var finalSlash = actualPath.lastIndexOf("/");
        if(finalSlash != -1) {
            actualFile = actualPath.substring(finalSlash+1);
        }
        if (file != null) {
            assertEquals(assertID, file, actualFile);
        }
        if (name != null) {
            var actualName = actualFile;
            var finalDot = actualFile.lastIndexOf(".");
            if (finalDot != -1) {
                actualName = actualName.substring(0, finalDot);
            }
            assertEquals(assertID, name, actualName);
        }
    }

    if(isAbsolute != null) {
        assertEquals(assertID, isAbsolute, actualPath.substring(0,1) == "/");
    }
  }

function toUpperCaseArray(expected) {
    var upperCased = new Array(expected.length);
    for(var i = 0; i < expected.length; i++) {
        if (expected[i].substring(0,1) != "#") {
            upperCased[i] = expected[i].toUpperCase();
        } else {
            upperCased[i] = expected[i];
        }
    }
    return upperCased;
}

function getSuffix(contentType) {
    switch(contentType) {
        case "text/html":
        return ".html";

        case "text/xml":
        return ".xml";

        case "application/xhtml+xml":
        return ".xhtml";

        case "image/svg+xml":
        return ".svg";

        case "text/mathml":
        return ".mml";
    }
    return ".html";
}

function IFrameBuilder() {
    this.contentType = "text/html";
    this.supportedContentTypes = [ "text/html", 
        "text/xml", 
        "image/svg+xml", 
        "application/xhtml+xml",
        "text/mathml" ];    

    this.supportsAsyncChange = false;
    this.async = true;
    this.fixedAttributeNames = [
        "validating",  "expandEntityReferences", "coalescing", 
        "signed", "hasNullString", "ignoringElementContentWhitespace", "namespaceAware" ];

    this.fixedAttributeValues = [false,  true, false, true, true , false, false ];
    this.configurableAttributeNames = [ ];
    this.configurableAttributeValues = [ ];
    this.exception = null;
}

IFrameBuilder.prototype.hasFeature = function(feature, version) {
    return document.implementation.hasFeature(feature, version);
}

IFrameBuilder.prototype.getImplementation = function() {
    return document.implementation;
}


IFrameBuilder.prototype.preload = function(frame, varname, url) {
  if (this.contentType == "text/html") {
  	if (url == "staff" || url == "nodtdstaff") {
    	throw "Tests using staff or nodtdstaff are not supported by HTML processors";
  	}  
  	return 1;
  }
  var iframe = document.createElement("iframe");
  var srcname = url + getSuffix(this.contentType);
  iframe.setAttribute("name", srcname);
  iframe.setAttribute("src", fileBase + srcname);
  iframe.addEventListener("load", loadComplete, false);  
  document.getElementsByTagName("body").item(0).appendChild(iframe);
  return 0; 
}

IFrameBuilder.prototype.load = function(frame, varname, url) {
	if (this.contentType == "text/html") {
    	return frame.document;
    }
    var name = url + getSuffix(this.contentType);
    var iframes = document.getElementsByTagName("iframe");
    for(var i = 0; i < iframes.length; i++) {
       if (iframes.item(i).getAttribute("name") == name) {
           return iframes.item(i).contentDocument;
       }
    }
    return null;
}

IFrameBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }
    throw "Unrecognized implementation attribute: " + attr;
}


IFrameBuilder.prototype.toAutoCase = function(s) {
    if (this.contentType == "text/html") {
        return s.toUpperCase();
    }
    return s;
}

IFrameBuilder.prototype.toAutoCaseArray = function(s) {
    if (this.contentType == "text/html") {
        return toUpperCaseArray(s);
    }
    return s;
}

IFrameBuilder.prototype.setImplementationAttribute = function(attribute, value) {
    var supported = this.getImplementationAttribute(attribute);
    if (supported != value) {
        throw "IFrame loader does not support " + attribute + "=" + value;
    }
}




function SVGPluginBuilder() {
    this.contentType = "image/svg+xml";
    this.supportedContentTypes = [ "image/svg+xml" ];

    this.supportsAsyncChange = false;
    this.async = true;
    this.fixedAttributeNames = [
        "validating",  "expandEntityReferences", "coalescing", 
        "signed", "hasNullString", "ignoringElementContentWhitespace", "namespaceAware" ];

    this.fixedAttributeValues = [false,  true, false, true, true , false, false ];
    this.configurableAttributeNames = [ ];
    this.configurableAttributeValues = [ ];
    this.exception = null;
}

SVGPluginBuilder.prototype.hasFeature = function(feature, version) {
    if (feature == "XML") {
        if (version == null || version == "1.0" || version == "2.0") {
            return true;
        }
    }
}

SVGPluginBuilder.prototype.getImplementation = function() {
  var embed = document.createElement("embed");
  embed.src = fileBase + url + getSuffix(this.contentType);
  embed.height = 100;
  embed.width = 100;
  embed.type = "image/svg+xml";
  embed.id = varname;
  var child = document.documentElement.firstChild;
  while(child != null) {
      if (child.nodeName != null && child.nodeName.toUpperCase() == "BODY") {
          child.appendChild(embed);
          return child.getSVGDocument.implementation;
      }
      child = child.nextSibling;
  }
  return null;
}

var svgloadcount = 0;
function SVGPluginBuilder_pollreadystate() {
  var newCount = 0;
  var child = document.documentElement.firstChild;
  while(child != null) {
      if (child.nodeName != null && child.nodeName.toUpperCase() == "BODY") {
          var grand = child.firstChild;
          while (grand != null) {
             if (grand.nodeName.toUpperCase() == 'EMBED' && grand.readystate == 4) {
                newCount++;
             }
             grand = grand.nextSibling;
          }
          break;
      }
      child = child.nextSibling;
  }
  if (newCount > svgloadcount) {
    svgloadcount++;
    loadComplete();
    if (setUpPageStatus == 'complete') {
        return;
    }
  }
  setTimeout(SVGPluginBuilder_pollreadystate, 100);
}

SVGPluginBuilder.prototype.preload = function(frame, varname, url) {
  var embed = document.createElement("embed");
  embed.src = fileBase + url + getSuffix(this.contentType);
  embed.height = 100;
  embed.width = 100;
  embed.type = "image/svg+xml";
  embed.id = varname;
  var child = document.documentElement.firstChild;
  while(child != null) {
      if (child.nodeName != null && child.nodeName.toUpperCase() == "BODY") {
          child.appendChild(embed);
          break;
      }
      child = child.nextSibling;
  }
  //
  //   if unable to monitor ready state change then
  //     check if load is complete every in 0.1 second
  setTimeout(SVGPluginBuilder_pollreadystate , 100);
  return 0;
}

SVGPluginBuilder.prototype.load = function(frame, varname, url) {
  var child = document.documentElement.firstChild;
  while(child != null) {
      if (child.nodeName != null && child.nodeName.toUpperCase() == "BODY") {
		  var grand = child.firstChild;
		  while (grand != null) {
			if (grand.id == varname) {
				return grand.getSVGDocument();
			}
			grand = grand.nextSibling;
		  }
	  }
      child = child.nextSibling;
   }
   return null;
}

SVGPluginBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }
    throw "Unrecognized implementation attribute: " + attr;
}


SVGPluginBuilder.prototype.toAutoCase = function(s) {
    return s;
}

SVGPluginBuilder.prototype.toAutoCaseArray = function(s) {
    return s;
}

SVGPluginBuilder.prototype.setImplementationAttribute = function(attribute, value) {
    var supported = this.getImplementationAttribute(attribute);
    if (supported != value) {
        throw "SVG Plugin loader does not support " + attribute + "=" + value;
    }
}





function MSXMLBuilder(progID) {
    this.progID = progID;
    this.configurableAttributeNames = [
        "validating", "ignoringElementContentWhitespace"];
    this.configurableAttributeValues = [ false, false ];
    this.fixedAttributeNames = [ "signed", "hasNullString", 
        "expandEntityReferences", "coalescing", "namespaceAware" ];
    this.fixedAttributeValues = [ true, true, false, false, false ];

    this.contentType = "text/xml";
    this.supportedContentTypes = [ 
        "text/xml", 
        "image/svg+xml", 
        "application/xhtml+xml",
        "text/mathml" ];

    this.async = false;
    this.supportsAsyncChange = true;
    this.parser = null;
    this.exception = null;
}

MSXMLBuilder.prototype.createMSXML = function() {
    var parser = new ActiveXObject(this.progID);
    parser.async = this.async;
    parser.preserveWhiteSpace = !this.configurableAttributeValues[1];
    parser.validateOnParse = this.configurableAttributeValues[0];
    return parser;
  }

MSXMLBuilder.prototype.preload = function(frame, varname, url) {
  if (this.async) {
     this.parser = this.createMSXML();
     parser.async = true;
     parser.onreadystatechange = MSXMLBuilder_onreadystatechange;
     parser.load(fileBase + url + getSuffix(this.contentType));
     if (parser.readystate != 4) {
        return 0;
     }
  }
  return 1;
}

MSXMLBuilder.prototype.load = function(frame, varname, url) {
    var parser = this.createMSXML();
	if(!parser.load(fileBase + url + getSuffix(this.contentType))) {
		throw parser.parseError.reason;
	}
    //
    //   if the first child of the document is a PI representing
    //      the XML Declaration, remove it from the tree.
    //
    //   According to the DOM FAQ, this behavior is not wrong,
    //      but the tests are written assuming that it is not there.
    //
    var xmlDecl = parser.firstChild;
    if(xmlDecl != null && xmlDecl.nodeType == 7 && xmlDecl.target.toLowerCase() == "xml") {
        parser.removeChild(xmlDecl);
    }
	return parser;
}

MSXMLBuilder.prototype.getImplementationAttribute = function(attr) {
    var i;
    for (i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }

    for (i = 0; i < this.configurableAttributeNames.length; i++) {
        if (this.configurableAttributeNames[i] == attr) {
            return this.configurableAttributeValues[i];
        }
    }

    throw "Unrecognized implementation attribute: " + attr;
}


MSXMLBuilder.prototype.toAutoCase = function(s) {
    return s;
}

MSXMLBuilder.prototype.toAutoCaseArray = function(s) {
    return s;
}

MSXMLBuilder.prototype.setImplementationAttribute = function(attribute, value) {
    var i;
    for (i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attribute) {
            if (this.fixedAttributeValues[i] != value) {
                throw "MSXML does not support " + attribute + "=" + value;
            }
            return;
        }
    }
    for (i = 0; i < this.configurableAttributeNames.length; i++) {
        if (this.configurableAttributeNames[i] == attribute) {
            this.configurableAttributeValues[i] = value;
            return;
        }
    }
    throw "Unrecognized implementation attribute: " + attr;
}
            

MSXMLBuilder.prototype.getImplementation = function() {
    var doc = this.CreateMSXML();
    return doc.implementation;
}

//
//   Only used to select tests compatible with implementation
//      not used on tests that actually test hasFeature()
//
MSXMLBuilder.prototype.hasFeature = function(feature, version) {
    //
    //   MSXML will take null, unfortunately 
    //      there is no way to get it to there from script
    //      without a type mismatch error
    if(version == null) {
		switch(feature.toUpperCase()) {
		   case "XML":
		   case "CORE":
		   return true;
		   
		   case "HTML":
		   case "ORG.W3C.DOM":
		   return false;
		}
		if(this.getDOMImplementation().hasFeature(feature,"1.0")) {
		   return true;
		}
		if(this.getDOMImplementation().hasFeature(feature,"2.0")) {
		   return true;
		}
		if(this.getDOMImplementation().hasFeature(feature,"3.0")) {
		   return true;
		}
    }
	return this.getDOMImplementation().hasFeature(feature,version);
  }



function MozillaXMLBuilder() {
    this.contentType = "text/xml";

    this.configurableAttributeNames = [ ];
    this.configurableAttributeValues = [ ];
    this.fixedAttributeNames = [ "validating", "ignoringElementContentWhitespace", "signed", 
        "hasNullString", "expandEntityReferences", "coalescing", "namespaceAware" ];
    this.fixedAttributeValues = [ false, false, true, true, false, false, false ];

    this.contentType = "text/xml";
    this.supportedContentTypes = [ 
        "text/xml", 
        "image/svg+xml", 
        "application/xhtml+xml",
        "text/mathml" ];

    this.async = true;
    this.supportsAsyncChange = false;

    this.docs = new Array();
    this.docnames = new Array();
    this.exception = null;
}

MozillaXMLBuilder.prototype.getImplementation = function() {
    return document.implementation;
}


MozillaXMLBuilder.prototype.preload = function(frame, varname, url) {
  var domimpl = document.implementation;
  var doc = domimpl.createDocument("", "temp", null);
  doc.addEventListener("load", loadComplete, false);
  doc.load(fileBase + url + getSuffix(this.contentType));
  this.docs[this.docs.length] = doc;
  this.docnames[this.docnames.length] = varname;
  return 0;
}

MozillaXMLBuilder.prototype.load = function(frame, varname, url) {
    for(i = 0; i < this.docnames.length; i++) {
        if (this.docnames[i] == varname) {
            return this.docs[i];
        }
    }
    return null;
}


MozillaXMLBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }
    return false;
}


MozillaXMLBuilder.prototype.toAutoCase = function(s) {
    return s;
}

MozillaXMLBuilder.prototype.toAutoCaseArray = function(s) {
    return s;
}


function DOM3LSBuilder() {
    this.contentType = "text/xml";

    this.configurableAttributeNames = [ ];
    this.configurableAttributeValues = [ ];
    this.fixedAttributeNames = [ "validating", "ignoringElementContentWhitespace", "signed", 
        "hasNullString", "expandEntityReferences", "coalescing", "namespaceAware" ];
    this.fixedAttributeValues = [ false, false, true, true, false, false, true ];

    this.contentType = "text/xml";
    this.supportedContentTypes = [ 
        "text/xml", 
        "image/svg+xml", 
        "application/xhtml+xml",
        "text/mathml" ];

    this.async = true;
    this.supportsAsyncChange = true;

    this.docs = new Array();
    this.docnames = new Array();
    this.exception = null;
}

DOM3LSBuilder.prototype.getImplementation = function() {
    return document.implementation;
}


DOM3LSBuilder.prototype.preload = function(frame, varname, url) {
  if (this.async) {
      var domimpl = document.implementation;
      var dombuilder = domimpl.createDOMBuilder(2, null);
      dombuilder.addEventListener("load", loadComplete, false);
      var uri = fileBase + url + getSuffix(this.contentType);
      var doc = dombuilder.parseURI(uri);
      this.docs[this.docs.length] = doc;
      this.docnames[this.docnames.length] = varname;
      return 0;
   }
   return 1;
}

DOM3LSBuilder.prototype.load = function(frame, varname, url) {
    if (this.async) {
        for(i = 0; i < this.docnames.length; i++) {
            if (this.docnames[i] == varname) {
                return this.docs[i];
            }
        }
        return null;
    }
    var dombuilder = document.implementation.createDOMBuilder(1, null);
    var uri = fileBase + url + getSuffix(this.contentType);
    return dombuilder.parseURI(uri);
}


DOM3LSBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i < this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }
}


DOM3LSBuilder.prototype.toAutoCase = function(s) {
    return s;
}

DOM3LSBuilder.prototype.toAutoCaseArray = function(s) {
    return s;
}

function createBuilder(implementation) {
  switch(implementation) {
    case "msxml3":
    return new MSXMLBuilder("Msxml.DOMDocument.3.0");
    
    case "msxml4":
    return new MSXMLBuilder("Msxml2.DOMDocument.4.0");

    case "mozilla":
    return new MozillaXMLBuilder();

    case "svgplugin":
    return new SVGPluginBuilder();

    case "dom3ls":
    return new DOM3LSBuilder();
  }
  return new IFrameBuilder();
}

var builder = null;

if (top && top.jsUnitParmHash)
{
    builder = createBuilder(top.jsUnitParmHash.implementation);
    try {
        if (top.jsUnitParmHash.asynchronous == 'true' && builder.supportAsync) {
            builder.async = true;
        }
        if (top.jsUnitParmHash.expandentityreferences) {
            if (top.jsUnitParmHash.expandEntityReferences == 'true') {
                builder.setImplementationAttribute('expandEntityReferences', true);
            } else {
                builder.setImplementationAttribute('expandEntityReferences', false);
            }
        }
        if (top.jsUnitParmHash.ignoringelementcontentwhitespace) {
            if (top.jsUnitParmHash.ignoringElementContentWhitespace == 'true') {
                builder.setImplementationAttribute('ignoringElementContentWhitespace', true);
            } else {
                builder.setImplementationAttribute('ignoringElementContentWhitespace', false);
            }
        }
        if (top.jsUnitParmHash.validating) {
            if (top.jsUnitParmHash.validating == 'true') {
                builder.setImplementationAttribute('validating', true);
            } else {
                builder.setImplementationAttribute('validating', false);
            }
        }
        if (top.jsUnitParmHash.coalescing) {
            if (top.jsUnitParmHash.coalescing == 'true') {
                builder.setImplementationAttribute('coalescing', true);
            } else {
                builder.setImplementationAttribute('coalescing', false);
            }
        }
        if (top.jsUnitParmHash.namespaceaware) {
            if (top.jsUnitParmHash.namespaceaware == 'true') {
                builder.setImplementationAttribute('namespaceAware', true);
            } else {
                builder.setImplementationAttribute('namespaceAware', false);
            }
        }
        var contentType = top.jsUnitParmHash.contenttype;
        if (contentType != null) {
            var contentTypeSet = false;
            for (var i = 0; i < builder.supportedContentTypes.length; i++) {
                if (builder.supportedContentTypes[i] == contentType) {
                    builder.contentType = contentType;
                    contentTypeSet = true;
                    break;
                }
            }
            if (!contentTypeSet) {
                builder.exception = "Builder does not support content type " + contentType;
            }
        }
    }
    catch(ex) {
        builder.exception = ex;
    }
} else {
    builder = new IFrameBuilder();
}


function preload(frame, varname, url) {
  return builder.preload(frame, varname, url);
}

function load(frame, varname, url) {
    return builder.load(frame, varname, url);
}

function getImplementationAttribute(attr) {
    return builder.getImplementationAttribute(attr);
}


function toAutoCase(s) {
    return builder.toAutoCase(s);
}

function toAutoCaseArray(s) {
    return builder.toAutoCaseArray(s);
}

function setImplementationAttribute(attribute, value) {
    builder.setImplementationAttribute(attribute, value);
}

function createXPathEvaluator(doc) {
    try {
        return doc.getFeature("XPath", null);
    }
    catch(ex) {
    }
    return doc;
}


function MSXMLBuilder_onreadystatechange() {
    if (builder.parser.readyState == 4) {
        loadComplete();
    }
}


var fileBase = location.href;
if (fileBase.indexOf('?') != -1) {
   fileBase = fileBase.substring(0, fileBase.indexOf('?'));
}
fileBase = fileBase.substring(0, fileBase.lastIndexOf('/') + 1) + "files/";

function getImplementation() {
    return builder.getImplementation();
}

