/*
Copyright (c) 2001 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
*/
  function assertTrue(descr, boo) {
    top.assertTrue(descr, boo);
  }

  function assertFalse(descr, boo) {
    top.assertFalse(descr, boo);
  }

  function assertEquals(descr, expected, actual) {
     top.assertEquals(descr, expected, actual);
  }

  function assertNotEquals(descr, expected, actual) {
     top.assertNotEquals(descr, expected, actual);
  }

  function assertNull(descr, obj) {
    top.assertNull(descr, obj);
  }

  function assertNotNull(descr, obj) {
    top.assertNotNull(descr, obj);
  }

  function assertSize(descr, expected, actual) {
    var actualSize;
    actualSize = actual.length;
    assertEquals(descr, expected, actualSize);
  }

  
  function assertEqualsCollection(descr, expected, actual) {
    //
    //  if they aren't the same size, they aren't equal
    top.assertEquals(descr, expected.length, actual.length);
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
            top.assert(descr + ": No match found for " + expectedValue,false);
        }
        if(matches > 1) {
            top.assert(descr + ": Multiple matches found for " + expectedValue, false);
        }
    }
  }


  function assertEqualsList(descr, expected, actual) {
    //
    //  if they aren't the same size, they aren't equal
    top.assertEquals(descr, expected.length, actual.length);
    //
    var actualLen = actual.length;
    var i;
    for(i = 0; i < actualLen; i++) {
        if(expected[i] != actual[i]) {
			top.assertEquals(descr, expected[i], actual[i]);
        }
    }
  }

  function assertInstanceOf(descr, type, obj) {
    if(type == "Attr") {
        top.assertEquals(descr,2,obj.nodeType);
        var specd = obj.specified;
    }
  }

  function assertSame(descr, expected, actual) {
    if(expected != actual) {
        top.assertEquals(descr, expected.nodeType, actual.nodeType);
        top.assertEquals(descr, expected.nodeValue, actual.nodeValue);
    }
  }

  function assertURIEquals(assertID, scheme, path, host, file, query, fragment, isAbsolute, actual) {
    //
    //  URI must be non-null
    top.assertNotNull(assertID, actual);

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
    if(fragment != null) top.assertEquals(assertID,fragment, actualFragment);

    var lastQuestion = uri.lastIndexOf("?");
    var actualQuery = "";
    if(lastQuestion != -1) {
        //
        //   substring before pound
        //
        uri = actual.substring(0,lastQuestion);
        actualQuery = actual.substring(lastQuestion+1);
    }
    if(query != null) top.assertEquals(assertID, query, actualQuery);

    var firstColon = uri.indexOf(":");
    var firstSlash = uri.indexOf("/");
    var actualPath = uri;
    var actualScheme = "";
    if(firstColon != -1 && firstColon < firstSlash) {
        actualScheme = uri.substring(0,firstColon);
        actualPath = uri.substring(firstColon + 1);
    }

    if(scheme != null) {
        top.assertEquals(assertID, scheme, actualScheme);
    }

    if(path != null) {
        top.assertEquals(assertID, path, actualPath);
    }

    if(host != null) {
        var actualHost = "";
        if(actualPath.startsWith("//")) {
            var termSlash = actualPath.substring(2).indexOf("/") + 2;
            actualHost = actualPath.substring(0,termSlash);
        }
        top.assertEquals(assertID, host, actualHost);
    }

    if(file != null) {
        var actualFile = actualPath;
        var finalSlash = actualPath.lastIndexOf("/");
        if(finalSlash != -1) {
            actualFile = actualPath.substring(finalSlash+1);
        }
        top.assertEquals(assertID, file, actualFile);
    }

    if(isAbsolute != null) {
        top.assertEquals(assertID, isAbsolute.booleanValue(), actualPath.startsWith("/"));
    }
  }

  var currentBuilder = null;

  function MSXMLBuilder(test, contentType, attributes, features, progid) {
    this.test = test;
    this.progid = progid;
    this.async = false;
    this.domImpl = new ActiveXObject(progid).domImplementation;
    this.attributes = attributes;
    this.features = features;
    this.contentType = contentType;
    if (this.attributes != null) {
        for (var i = 0; i < this.attributes.length; i++) {
            if(this.attributes[i][0] == 'expandEntityReferences' && 
                this.attributes[i][1]) {
                test.ignored = true;
                break;
            }
        }
    }
  }

  MSXMLBuilder.prototype.createMSXML = function() {
    var parser = new ActiveXObject(this.progid);
    parser.async = false;
    parser.preserveWhiteSpace = true;
    if (this.attributes != null) {
        var supported = true;
        for (var i = 0; i < this.attributes.length; i++) {
            if(this.attributes[i][0] == "validating") {
                parser.validateOnParse = this.attributes[i][1];
                break;
            }
			if(this.attributes[i][0] == "ignoreElementContentWhitespace") {
				parser.preserveWhiteSpace = !this.attributes[i][1];
			}
        }
    }
    return parser;
  }

  MSXMLBuilder.prototype.startLoad = function(varname, file) {
    var extension = ".xml";
    //
    //   if trying to ready HTML or some other content with
    //     the MSXML parser, then ignore the test
    if (this.contentType != null) {
        if (this.contentType == 'text/xml') {
        } else {
            if(this.contentType == 'image/svg+xml') {
                extension = '.svg';
            } else { 
                this.test.ignored = true;
                this.test.ready = true;
                return null;
            }
        }
    }
    var parser = this.createMSXML();
	if(!parser.load(file + ".xml")) {
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

  //
  //   document was fully loaded in startLoad,
  //      just return existing document reference
  //
  MSXMLBuilder.prototype.load = function (doc, varname, file) {
    return doc;
  }

  MSXMLBuilder.prototype.close = function(doc) {
  }

  MSXMLBuilder.prototype.toAutoCase = function(expected) {
    return expected;
  }


  MSXMLBuilder.prototype.toAutoCaseArray = function(expected) {
    return expected;
  }

  MSXMLBuilder.prototype.getDOMImplementation = function() {
    return this.domImpl;
  }

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

  MSXMLBuilder.prototype.getImplementationAttribute = function(attr) {
    if (this.attributes != null) {
        for (var i = 0; i < this.attributes.length; i++) {
            if(attr == this.attributes[i][0]) {
                return this.attributes[i][1];
            }
        }
    }
    if (attr == "expandEntityReferences" || 
        attr == "signed" || 
        attr == "hasNullString") {
        return true;
    }
    if (attr == "validating" || attr == "ignoreElementContentWhitespace") {
        return false;
    }
    return false;
  }


  function DOM3XMLBuilder(test, contentType, attrNames, attrValues) {
    this.test = test;
    this.contentType = contentType;
    this.async = true;
    this.domImpl = null;
    this.attrNames = attrNames;
    this.attrValues = attrValues;
  }

  DOM3XMLBuilder.prototype.startLoad = function(varname, file) {
    var extension = ".xml";
    //
    //   if trying to ready HTML or some other content with
    //     the DOM 3 LS parser, then ignore the test
    if (this.contentType != null) {
        if (this.contentType == 'text/xml') {
        } else {
            if(this.contentType == 'image/svg+xml') {
                extension = '.svg';
            } else { 
                this.test.ignored = true;
                this.test.ready = true;
                return null;
            }
        }
    }
    if (this.async) {
       var domimpl = document.implementation;
       var builder = domimpl.getDOMBuilder(1, null);
       builder.addEventListener("load", this, false);
       builder.addEventListener("error", this, false);
       return builder.parseURI(file + extension);
    } 
    var builder = document.implementation.getDOMBuilder(2, null);
    return builder.parseURI(file + extension);
  }

  DOM3XMLBuilder.prototype.load = function (doc, varname, file) {
    return doc;
  }

  DOM3XMLBuilder.prototype.handleEvent = function(evt) {
    if (evt.type == "load") {
        this.test.onLoadComplete(evt.newDocument);
    } else {
        if (evt.type == "error") {
            this.test.onLoadError("Load error " + evt.error);
        }
    }
  }

  DOM3XMLBuilder.prototype.close = function(doc) {
  }

  DOM3XMLBuilder.prototype.toAutoCase = function(expected) {
    return expected;
  }

  DOM3XMLBuilder.prototype.toAutoCaseArray = function(expected) {
    return expected;
  }


  DOM3XMLBuilder.prototype.getDOMImplementation = function() {
    return document.implementation;
  }

  DOM3XMLBuilder.prototype.hasFeature = function(feature, version) {
    return document.implementation.hasFeature(feature, version);
  }

  DOM3XMLBuilder.prototype.getImplementationAttribute = function(attr) {
    return false;
  }


  function MozillaXMLBuilder(test, contentType, attrNames, attrValues) {
    this.test = test;
    this.contentType = contentType;
    this.async = true;
    this.domImpl = null;
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    if (attrNames != null) {
        var supported = true;
        for (var i = 0; i < attrNames.length; i++) {
            if(attrNames[i] == 'validating' && attrValues[i]) {
                supported = false;
                break;
            }
        }
        if (!supported) {
            test.ignored = true;
        }
    }
  }

  function MozillaXMLBuilder_onLoadComplete(evt) {
      alert("onLoad");
      currentBuilder.test.onLoadComplete(evt.currentTarget);
  }


  MozillaXMLBuilder.prototype.startLoad = function(varname, file) {
    var extension = ".xml";
    //
    //   if trying to ready HTML or some other content with
    //     the DOM 3 LS parser, then ignore the test
    if (this.contentType != null) {
        if (this.contentType == 'text/xml') {
        } else {
            if(this.contentType == 'image/svg+xml') {
                extension = '.svg';
            } else { 
                this.test.ignored = true;
                this.test.ready = true;
                return null;
            }
        }
    }
    var domimpl = document.implementation;
    var doc = domimpl.createDocument("", "temp", null);
    doc.addEventListener("load", MozillaXMLBuilder_onLoadComplete, false);
    currentBuilder = this;
    this.test.deferredDocs++;
    alert("startLoad");
    doc.load(file + extension);
    return doc;
  }

  MozillaXMLBuilder.prototype.load = function (doc, varname, file) {
    return doc;
  }

  MozillaXMLBuilder.prototype.close = function(doc) {
  }

  MozillaXMLBuilder.prototype.toAutoCase = function(expected) {
    return expected;
  }

  MozillaXMLBuilder.prototype.toAutoCaseArray = function(expected) {
    return expected;
  }


  MozillaXMLBuilder.prototype.getDOMImplementation = function() {
    return document.implementation;
  }

  MozillaXMLBuilder.prototype.hasFeature = function(feature, version) {
    return document.implementation.hasFeature(feature, version);
  }

  MozillaXMLBuilder.prototype.getImplementationAttribute = function(attr) {
    return false;
  }

  function IFrameBuilder(test, contentType, attributes, features) {
    this.test = test;
    this.contentType = contentType;
    this.async = false;
    this.supportedAttributes = [
        [ "validating", false ],
        [ "expandEntityReferences", true],
        [ "coalescing", false],
        [ "signed", true],
        [ "hasNullString", true ],
        [ "ignoringElementContentWhitespace", false] ];

    var supported = true;

    for (var i = 0; i < attributes.length && supported; i++) {
        for (var j = 0; j < this.supportedAttributes.length; j++) {
            if (attributes[i][0] == this.supportedAttributes[j][0] &&
                attributes[i][1] != this.supportedAttributes[j][1]) {
                supported = false;
                break;
            }
        }
    }

    if (supported) {
        for (var i = 0; i < features.length; i++) {
            if (features[i][0].toUpperCase() == "XML") {
                supported = false;
                break;
            }
        }
    }
    if (!supported) {
        this.test.ignored = true;
    }
  }


  IFrameBuilder.prototype.startLoad = function(varname, file) {
    var extension = ".xml";
    //
    //   if trying to ready HTML or some other content with
    //     the DOM 3 LS parser, then ignore the test
    switch(this.contentType) {
        case null:
        case "text/xml":
        break;

        case "text/html":
        if (file == "staff" || file == "nodtdstaff") {
            this.test.ignored = true;
            this.test.ready = true;
            return null;
        }
        extension = ".html";
        break;

        case "image/svg+xml":
        extension = ".svg";
        break;
    }
    var iframe = document.getElementById(varname + extension);
    var doc = iframe.contentDocument;
    if (doc == undefined || doc == null) {
        doc = iframe.document;
    }
    return doc;
  }

  IFrameBuilder.prototype.load = function (doc, varname, filename) {
    return doc;
  }

  IFrameBuilder.prototype.close = function(doc) {
  }

  IFrameBuilder.prototype.toAutoCase = function(expected) {
    if (this.contentType == "text/html") {
        if(expected.substring(0,1) != "#") {
            return expected.toUpperCase();
        }
    }
    return expected;
  }


  IFrameBuilder.prototype.toAutoCaseArray = function(expected) {
    if (this.contentType == "text/html") {
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
    return expected;
  }

  IFrameBuilder.prototype.getDOMImplementation = function() {
    return document.implementation;
  }

  IFrameBuilder.prototype.hasFeature = function(feature, version) {
    return document.implementation.hasFeature(feature, version);
  }

  IFrameBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i < this.supportedAttributes.length; i++) {
        if (this.supportedAttributes[i][0] == attr) {
            return this.supportedAttributes[i][1];
        }
    }
    return false;
  }

   
  function getBuilder(test, contentType, attributes, features) {
//    return new MSXMLBuilder(test, contentType, attributes, features, "MSXML2.DOMDocument.3.0");
//      return new DOM3XMLBuilder(test, contentType, attributes, features);
//      return new MozillaXMLBuilder(test, contentType, attributes, features);
      return new IFrameBuilder(test, "text/html", attributes, features);
  }  

function DOMTestCase_onLoadComplete(doc) {
    if(--this.deferredDocs == 0) {
        this.setReady(true);
    }
}

function DOMTestCase_onLoadError(error) {
    this.deferredDocs = -1;
    this.fail(error);
}
        

function DOMTestCase(name) {
    var test = new top.jsUnitTestCase(name);
    test.deferredDocs = 0;
    test.onLoadComplete = DOMTestCase_onLoadComplete;
    test.onLoadError = DOMTestCase_onLoadError;
    return test;
}



var isTestPageLoaded=false;

function isLoaded() {
        return isTestPageLoaded;
}
function newOnLoadEvent() {
        isTestPageLoaded=true;
}

window.onload=newOnLoadEvent;
