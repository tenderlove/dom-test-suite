<?xml version="1.0" encoding="UTF-8"?>
/*
Copyright (c) 2001-2004 World Wide Web Consortium,
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

  function assertEqualsAutoCase(context, descr, expected, actual) {
  	if (builder.contentType == "text/html") {
  	    if(context == "attribute") {
  	    	assertEquals(descr, expected.toLowerCase(), actual.toLowerCase());
  	    } else {
  	        assertEquals(descr, expected.toUpperCase(), actual);
  	    }
  	} else {
  		assertEquals(descr, expected, actual); 
  	}
  }
  

  function assertEqualsCollectionAutoCase(context, descr, expected, actual) {
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
    for(i = 0; i &lt; expectedLen; i++) {
        matches = 0;
        expectedValue = expected[i];
        for(j = 0; j &lt; actualLen; j++) {
        	if (builder.contentType == "text/html") {
        		if (context == "attribute") {
        			if (expectedValue.toLowerCase() == actual[j].toLowerCase()) {
        				matches++;
        			}
        		} else {
        			if (expectedValue.toUpperCase() == actual[j]) {
        				matches++;
        			}
        		}
        	} else {
            	if(expectedValue == actual[j]) {
                	matches++;
                }
            }
        }
        if(matches == 0) {
            assert(descr + ": No match found for " + expectedValue,false);
        }
        if(matches &gt; 1) {
            assert(descr + ": Multiple matches found for " + expectedValue, false);
        }
    }
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
    for(i = 0; i &lt; expectedLen; i++) {
        matches = 0;
        expectedValue = expected[i];
        for(j = 0; j &lt; actualLen; j++) {
            if(expectedValue == actual[j]) {
                matches++;
            }
        }
        if(matches == 0) {
            assert(descr + ": No match found for " + expectedValue,false);
        }
        if(matches &gt; 1) {
            assert(descr + ": Multiple matches found for " + expectedValue, false);
        }
    }
  }


  function assertEqualsListAutoCase(context, descr, expected, actual) {
	var minLength = expected.length;
	if (actual.length &lt; minLength) {
	    minLength = actual.length;
	}
    //
    for(var i = 0; i &lt; minLength; i++) {
		assertEqualsAutoCase(context, descr, expected[i], actual[i]);
    }
    //
    //  if they aren't the same size, they aren't equal
    assertEquals(descr, expected.length, actual.length);
  }


  function assertEqualsList(descr, expected, actual) {
	var minLength = expected.length;
	if (actual.length &lt; minLength) {
	    minLength = actual.length;
	}
    //
    for(var i = 0; i &lt; minLength; i++) {
        if(expected[i] != actual[i]) {
			assertEquals(descr, expected[i], actual[i]);
        }
    }
    //
    //  if they aren't the same size, they aren't equal
    assertEquals(descr, expected.length, actual.length);
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
    if(firstColon != -1 &amp;&amp; firstColon &lt; firstSlash) {
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


// size() used by assertSize element
function size(collection)
{
  return collection.length;
}

function same(expected, actual)
{
  return expected === actual;
}

function getSuffix(contentType) {
        return ".svg";
}

function equalsAutoCase(context, expected, actual) {
	if (builder.contentType == "text/html") {
		if (content == "attribute") {
			return expected.toLowerCase() == actual;
		}
		return expected.toUpperCase() == actual;
	}
	return expected == actual;
}



function EventMonitor() {
  this.atEvents = new Array();
  this.bubbledEvents = new Array();
  this.capturedEvents = new Array();
  this.allEvents = new Array();
}

EventMonitor.prototype.handleEvent = function(evt) {
    switch(evt.eventPhase) {
       case 1:
       monitor.capturedEvents[monitor.capturedEvents.length] = evt;
       break;
       
       case 2:
       monitor.atEvents[monitor.atEvents.length] = evt;
       break;

       case 3:
       monitor.bubbledEvents[monitor.bubbledEvents.length] = evt;
       break;
    }
    monitor.allEvents[monitor.allEvents.length] = evt;
}

function DOMErrorImpl(err) {
  this.severity = err.severity;
  this.message = err.message;
  this.type = err.type;
  this.relatedException = err.relatedException;
  this.relatedData = err.relatedData;
  this.location = err.location;
}



function DOMErrorMonitor() {
  this.allErrors = new Array();
}

DOMErrorMonitor.prototype.handleError = function(err) {
    this.allErrors[this.allErrors.length] = new DOMErrorImpl(err);
}

DOMErrorMonitor.prototype.assertLowerSeverity = function(id, severity) {
    var i;
    for (i = 0; i &lt; this.allErrors.length; i++) {
        if (this.allErrors[i].severity &gt;= severity) {
           assertEquals(id, severity - 1, this.allErrors[i].severity);
        }
    }
}

function UserDataNotification(operation, key, data, src, dst) {
    this.operation = operation;
    this.key = key;
    this.data = data;
    this.src = src;
    this.dst = dst;
}

function UserDataMonitor() {
	this.allNotifications = new Array();
}

UserDataMonitor.prototype.handle = function(operation, key, data, src, dst) {
    this.allNotifications[this.allNotifications.length] =
         new UserDataNotification(operation, key, data, src, dst);
}



function SVGBuilder() {
    this.contentType = "image/svg+xml";
    this.supportedContentTypes = [ "image/svg+xml" ];

    this.supportsAsyncChange = false;
    this.async = false;
    this.fixedAttributeNames = [
        "validating",  "expandEntityReferences", "coalescing", 
        "signed", "hasNullString", "ignoringElementContentWhitespace", "namespaceAware", "ignoringComments"];

    this.fixedAttributeValues = [false,  true, false, true, true , false, true, false ];
    this.configurableAttributeNames = [ ];
    this.configurableAttributeValues = [ ];
    this.initializationError = null;
    this.initializationFatalError = null;
    this.skipIncompatibleTests = true;
    this.documentURLs = new Array();
    this.documentVarnames = new Array();
}

SVGBuilder.prototype.hasFeature = function(feature, version) {
    return document.implementation.hasFeature(feature, version);
}

SVGBuilder.prototype.getImplementation = function() {
  return document.implementation;
}

SVGBuilder.prototype.preload = function(frame, varname, url) {
  var i;
  this.documentVarnames[this.documentVarnames.length] = varname;
  this.documentURLs[this.documentURLs.length] = url;
  if (this.documentURLs.length &gt; 1) {
     //
     //   if all the urls are not the same
     //
     for (i = 1; i &lt; this.documentURLs.length; i++) {
         if (this.documentURLs[i] != this.documentURLs[0]) {
             throw "Tests with multiple loads of different documents are not currently supported";
         }
     }
  }
  return 1;
}

SVGBuilder.prototype.load = function(frame, varname, url) {
  if (this.documentVarnames[0] = varname) {
  	return document;
  }
  return document.cloneNode(true);
}

SVGBuilder.prototype.getImplementationAttribute = function(attr) {
    for (var i = 0; i &lt; this.fixedAttributeNames.length; i++) {
        if (this.fixedAttributeNames[i] == attr) {
            return this.fixedAttributeValues[i];
        }
    }
    throw "Unrecognized implementation attribute: " + attr;
}


SVGBuilder.prototype.setImplementationAttribute = function(attribute, value) {
    var supported = this.getImplementationAttribute(attribute);
    if (supported != value) {
        this.initializationError = "SVG loader does not support " + attribute + "=" + value;
    }
}

SVGBuilder.prototype.canSetImplementationAttribute = function(attribute, value) {
    var supported = this.getImplementationAttribute(attribute);
    return (supported == value);
}




function createConfiguredBuilder() {
    return new SVGBuilder();
}

function catchInitializationError(buildr, ex) {
   buildr.initializationError = ex;
   buildr.initializationFatalError = ex;
}


function checkFeature(feature, version)
{
  if (!builder.hasFeature(feature, version))
  {
    //
    //   don't throw exception so that users can select to ignore the precondition
    //
    builder.initializationError = "builder does not support feature " + feature + " version " + version;
  }
}


function changeColor(color) {
   document.getElementsByTagName("rect").item(0).setAttribute("style", "fill:" + color);
}

function addMessage(x, y, msg) {
   var textElem = document.createElementNS("http://www.w3.org/2000/svg", "text");
   textElem.setAttributeNS(null, "x", x);
   textElem.setAttributeNS(null, "y", y);
   textElem.appendChild(document.createTextNode(msg));
   document.documentElement.appendChild(textElem);   
}

function checkInitialization(buildr, testname) {
   if (buildr.initializationError != null) {
      addMessage("0", "160", buildr.initializationError);
      changeColor("yellow");
   }
   return buildr.initializationError;
}

function preload(docRef, varname, href) {
   return builder.preload(docRef, varname, href);
}


function load(docRef, varname, href) {
   return document;
}


function getImplementationAttribute(attr) {
    return builder.getImplementationAttribute(attr);
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


function getImplementation() {
    return builder.getImplementation();
}


function assertEquals(id, expected, actual) {
   var myActual;
   if (expected != actual) {
       myActual = actual;
       if (actual == null) {
          myActual = "null";
       }
       throw id + ": assertEquals failed, actual " + actual + ", expected " + expected + "."; 
   }
}

function assertNull(id, actual) {
   if (actual != null) {
       throw id + ": assertNull failed, actual " + actual;
   }
}


function assertTrue(id, actual) {
   if (!actual) {
       throw id + ": assertTrue failed";
   }
}


function assertFalse(id, actual) {
   if (actual) {
       throw id + ": assertTrue failed";
   }
}

function assertNotNull(id, actual) {
   if (actual == null) {
       throw id + ": assertNotNull failed";
   }
}

function fail(id) {
    throw id + ": fail";
}

addMessage("0", "120", exposeTestFunctionNames()[0]);

//
//   invoke test setup
//
setUpPage();

try {
	runTest();
	if (builder.initializationError == null) {
	   changeColor("green");
	}
} catch(ex) {
    changeColor("red");
    addMessage("0", "140", ex);    
}