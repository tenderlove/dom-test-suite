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

function toUpperCaseArray() {
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

function IFrameBuilder() {
    this.suffix = ".html";
}

IFrameBuilder.prototype.preload = function(frame, varname, url) {
  frame.document.location.href = fileBase + url + suffix;
  return 0;
}

IFrameBuilder.prototype.load = function(frame, varname, url) {
    return frame.document;
}

IFrameBuilder.prototype.getImplementationAttribute = function(attr) {
        var supportedAttributes = [
        [ "validating", false ],
        [ "expandEntityReferences", true],
        [ "coalescing", false],
        [ "signed", true],
        [ "hasNullString", true ],
        [ "ignoringElementContentWhitespace", false] ];

    for (var i = 0; i < supportedAttributes.length; i++) {
        if (supportedAttributes[i][0] == attr) {
            return supportedAttributes[i][1];
        }
    }
    return false;
}


IFrameBuilder.prototype.toAutoCase = function(s) {
    return s.toUpperCase();
}

IFrameBuilder.prototype.toAutoCaseArray = function(s) {
    return toUpperCaseArray(s);
}


function MozillaXMLBuilder() {
    this.suffix = ".xml";
    this.docs = new Array();
    this.docnames = new Array();
}

MozillaXMLBuilder.prototype.preload = function(frame, varname, url) {
  var domimpl = document.implementation;
  var doc = domimpl.createDocument("", "temp", null);
  doc.addEventListener("load", loadComplete, false);
  doc.load(fileBase + url + this.suffix);
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
    return false;
}


MozillaXMLBuilder.prototype.toAutoCase = function(s) {
    return s;
}

MozillaXMLBuilder.prototype.toAutoCaseArray = function(s) {
    return s;
}


var builder = new IFrameBuilder();
//var builder = new MozillaXMLBuilder();

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

var suffix = builder.suffix;

