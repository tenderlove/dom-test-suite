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

  function assertURIEquals(assertID, scheme, path, host, file, query, fragment, isAbsolute, actual) {
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
        if(actualPath.startsWith("//")) {
            var termSlash = actualPath.substring(2).indexOf("/") + 2;
            actualHost = actualPath.substring(0,termSlash);
        }
        assertEquals(assertID, host, actualHost);
    }

    if(file != null) {
        var actualFile = actualPath;
        var finalSlash = actualPath.lastIndexOf("/");
        if(finalSlash != -1) {
            actualFile = actualPath.substring(finalSlash+1);
        }
        assertEquals(assertID, file, actualFile);
    }

    if(isAbsolute != null) {
        assertEquals(assertID, isAbsolute.booleanValue(), actualPath.startsWith("/"));
    }
  }


  //
  //    Browser detection logic patterned after 
  //      http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html
  //
  //
  var agt = navigator.userAgent.toLowerCase();
  var major = parseInt(navigator.appVersion);
  var isNavigator6Up  = ((agt.indexOf('mozilla')!=-1) && (agt.indexOf('spoofer')==-1)
                && (agt.indexOf('compatible') == -1) && (agt.indexOf('opera')==-1)
                && (agt.indexOf('webtv')==-1) && (agt.indexOf('hotjava')==-1) 
                && (major >= 5));

  var isIE5Up = (agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1) &&
        (major >= 4) && (agt.indexOf("msie 4") ==-1);

       
  var factory = null;
  var defaultContentType = "text/xml";

  function XMLToAutoCase(expected) {
    return expected;
  }

  function HTMLToAutoCase(expected) {
    return expected.toUpperCase();
  }

  function XMLToAutoCaseArray(expected) {
    return expected;
  }

  function HTMLToAutoCaseArray(expected) {
    var upper = new Array(expected.length);
    for(var i = 0; i < expected.length; i++) {
        upper[i] = expected[i].toUpperCase();
    }
    return upper;
  }

  function toLowerCaseArray(strarray) {
    var lower = new Array(strarray.length);
    for(var i = 0; i < strarray.length; i++) {
        lower[i] = strarray[i].toLowerCase();
    }
    return lower;
  }

  //
  //   used by both HTML and SVG loaders
  //
  function MozLoadBrowserDocument(sourceURL, willBeModified, extension) {
    //
    //   resolve full URL
    //
	var absURL = location.href;
	absURL = absURL.substring(0,absURL.lastIndexOf("/")+1) + sourceURL + extension;
	//
	//      see if there is an available copy around
	//
	var newDoc = checkCache(willBeModified, this.cache, absURL);
	//
	//   if not create a new window
	//
	if(newDoc == null) {
		var newWindow = window.open(absURL);
		newDoc = newWindow.document;

        //
        //   maintain a list of windows so the right window can
        //       be closed when the document is used in a modification
        //       test and the test is finished
       var added = false;
       for(var i = 0; i < this.windows.length; i++) {
            if(this.windows[i] == null) {
                this.windows[i] = newWindow;
                added = true;
                break;
            }
        }
        if(!added) {
            this.windows[this.windows.length] = newWindow;
        }
        //
        //  if it won't be modified, it can be used in a subsequent test
        //
		if(!willBeModified) {
		   this.cache[this.cache.length] = new DocumentBuilderCacheEntry(absURL, newDoc);
		}
	}
	return newDoc; 
  }



  function MozHTMLApplyParserAttributes(parser, attrNames, attrValues) {
	if(attrNames != null) {
	    var i;
		for(i = 0; i < attrNames.length; i++) {
			if(attrNames[i] == "expandEntityReferences") {
				if(attrValues[i] == true) {
					throw "Mozilla does not support expanding entity references";
				}
			}
		}
	 }
  }

  function MozHTMLDocumentBuilder_checkAvailability(sourceURL) {
	switch(sourceURL)
	{
		case "staff":
		case "staffNS":
		case "staff.xml":
		case "staffNS.xml":
		throw sourceURL + " not available for HTML";
	}
  }


  function MozHTMLDocumentBuilder_load(sourceURL, willBeModified) {
    return this.MozLoadBrowserDocument(sourceURL, willBeModified, ".html");
  }

   function MozHTMLDocumentBuilder_getDOMImplementation() {
		return document.implementation;
   }

  //
  //   This function checks the exception raised in the test
  //   If this function returns true, then the exception is 
  //      consistent with the exception code parameter
  //
  //   This code attempts to determine the reason for the exception
  //      to reduce the chance that an unrelated exception causes
  //      the test to pass.
  function isDOMExceptionCode(ex, code) {
    return (ex.code == code);
  }

  function MozHTMLDocumentBuilder_getImplementationAttribute(attr) {
    return false;
  }
  
   function MozHTMLDocumentBuilder_close(doc) {
        alert("closing");
        for(var i = 0; i < this.windows.length; i++) {
            if(this.windows[i] != null && this.windows[i].document == doc) {
                this.windows[i].close();
                this.windows[i] = null;
            }
        }
   }
  
  function MozHTMLDocumentBuilder_checkAttributes(attrNames, attrValues) {
     //
     //    if no attributes were specified,
     //        the document builder can be reused
     if(this.attrNames == null) {
		if(attrNames == null) {
			return true;
		}
     }
     return false;
     
  }
  
  function MozHTMLDocumentBuilder_hasFeature(feature, version) {
    var upfeature = feature.toUpperCase();
    switch(upfeature) {
		case "HTML":
		case "CORE":
		case "EVENTS":
		return true;
	}		
	return false;
  }
  

  function MozHTMLDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.cache = new Array();
    this.windows = new Array();
    this.load = MozHTMLDocumentBuilder_load;
    this.checkAvailability = MozHTMLDocumentBuilder_checkAvailability;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = MozHTMLDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MozHTMLDocumentBuilder_getImplementationAttribute;
    this.close = MozHTMLDocumentBuilder_close;
    this.checkAttributes = MozHTMLDocumentBuilder_checkAttributes;
    this.hasFeature = MozHTMLDocumentBuilder_hasFeature;
    this.toAutoCase = HTMLToAutoCase;
    this.toAutoCaseArray = HTMLToAutoCaseArray;
    this.MozLoadBrowserDocument = MozLoadBrowserDocument;
  }

  function MozSVGDocumentBuilder_load(sourceURL, willBeModified) {
    return this.MozLoadBrowserDocument(sourceURL, willBeModified, ".svg");
  }

  function MozSVGDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.cache = new Array();
    this.windows = new Array();
    this.load = MozSVGDocumentBuilder_load;
    this.close = MozHTMLDocumentBuilder_close;
    this.checkAvailability = MozXMLDocumentBuilder_checkAvailability;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = MozXMLDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MozXMLDocumentBuilder_getImplementationAttribute;
    this.checkAttributes = MozXMLDocumentBuilder_checkAttributes;
    this.hasFeature = MozXMLDocumentBuilder_hasFeature;
    this.toAutoCase = XMLToAutoCase;
    this.toAutoCaseArray = XMLToAutoCaseArray;
    this.MozLoadBrowserDocument = MozLoadBrowserDocument;
  }

  function MozXMLApplyParserAttributes(parser, attrNames, attrValues) {
  }
 

  //
  //   get a document ready for the next test
  //
  function MozXMLLoad(sourceURL) {
    var doc = document.implementation.createDocument("","temp",null);
    doc.load(sourceURL);
    return doc;
  }

  function MozXMLDocumentBuilder_load(sourceURL, willBeModified) {
    var fullURL = sourceURL + this.extension;
	for(i = 0; i < this.cache.length; i++) {
		if(this.cache[i].url == fullURL) {
			var testdoc = this.cache[i].testdoc;
			if(testdoc.documentElement.nodeName != "temp") {
				//
				//  if it will be modified, start loading its replacement
				//
				if(willBeModified) {
					this.cache[i].testdoc = MozXMLLoad(fullURL);
				}
				return testdoc;
			}
		}
	}
    doc = document.implementation.createDocument("","temp",null);
    doc.load(fullURL);
    alert("Loading test document: Press OK to proceed");
    
    if(willBeModified) {
		//
		//   if it will be modified, get another copy started
		//
		this.cache[this.cache.length] = new DocumentBuilderCacheEntry(fullURL, MozXMLLoad(fullURL));
	}
	//
	//   if not going to be modified, then we can keep this around
	//      for another iteration
	else {
		this.cache[this.cache.length] = new DocumentBuilderCacheEntry(fullURL,doc);
	}

    return doc;
  }

   function MozXMLDocumentBuilder_getDOMImplementation() {
        return document.implementation;
   }

  function MozXMLDocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "expandEntityReferences") {
        return true;
    }
    return false;
  }

  function MozXMLDocumentBuilder_checkAttributes(attrNames, attrValues) {
      if(this.attrNames == null) {
         if(attrNames == null) {
            return true;
         }
      }
      return false;
  }
  
    function MozXMLDocumentBuilder_checkAvailability(sourceURL) {
        return true;
    }

  function MozXMLDocumentBuilder_hasFeature(feature, version) {
    var upfeature = feature.toUpperCase();
    if(version == null) {
		switch(upfeature) {
			case "XML":
			case "ORG.W3C.DOM":
			case "CORE":
			case "EVENTS":
			case "HTML":
			return true;
			
		}
	}
	return this.getDOMImplementation().hasFeature(feature,version);
  }
  
  function MozXMLDocumentBuilder_close(testdoc) {
  }
  

  function MozXMLDocumentBuilder(attrNames, attrValues, extension) {
    this.extension = extension;
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.cache = new Array();
    this.load = MozXMLDocumentBuilder_load;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = MozXMLDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MozXMLDocumentBuilder_getImplementationAttribute;
    this.checkAttributes = MozXMLDocumentBuilder_checkAttributes;
    this.checkAvailability = MozXMLDocumentBuilder_checkAvailability;
    this.close = MozXMLDocumentBuilder_close;
    this.hasFeature = MozXMLDocumentBuilder_hasFeature;
    this.toAutoCase = XMLToAutoCase;
    this.toAutoCaseArray = XMLToAutoCaseArray;
    //
    //   check if expandEntityReferences is false
    //     and throw an excpetion since that behavior is not supported
    //
    if(attrNames != null) {
        for(var i = 0; i < attrNames.length; i++) {
            if(attrNames[i] == "expandEntityReferences" && attrValues[i] == false) {
                throw "Mozilla doesn't support entity preservation";
            }
        }
    }
  }

  var defaultMozHTMLDocumentBuilder = null;
  var defaultMozXMLDocumentBuilder = null;
  var defaultMozSVGDocumentBuilder = null;

  var displayedSVGSupportAlert = false;

  var hasMozillaSVG = true;

  function MozDocumentBuilderFactory_newDocumentBuilder(attrNames, attrValues,contentType) {
    if(contentType != null) {
	    switch(contentType)
	    {
		    case "image/xml+svg":
            //
            //   see if feature org.w3c.svg is supported
            //
            if(!displayedSVGSupportAlert && !hasMozillaSVG) {
                alert("This browser does not support SVG, testing SVG using XML DOM");
                displayedSVGSupportAlert = true;
            }
		    if(defaultMozSVGDocumentBuilder.checkAttributes(attrNames, attrValues)) {
			    return defaultMozSVGDocumentBuilder;
		    }
            if(hasMozillaSVG) {
		        return new MozSVGDocumentBuilder(attrNames, attrValues);
            }
		    return new MozXMLDocumentBuilder(attrNames, attrValues, ".svg");
            break;

		    case "text/html":
		    if(defaultMozHTMLDocumentBuilder.checkAttributes(attrNames, attrValues)) {
			    return defaultMozHTMLDocumentBuilder;
		    }
		    return new MozHTMLDocumentBuilder(attrNames, attrValues);
		
	    }
    }
	if(defaultMozXMLDocumentBuilder.checkAttributes(attrNames, attrValues)) {
		return defaultMozXMLDocumentBuilder;
	}
	return new MozXMLDocumentBuilder(attrNames, attrValues, ".xml");
  }

  function MozDocumentBuilderFactory() {
    this.newDocumentBuilder = MozDocumentBuilderFactory_newDocumentBuilder;
  }

  //
  //   If application name contains Netscape
  //       set up Mozilla factories
  //
  if(isNavigator6Up) {
	defaultMozXMLDocumentBuilder = new MozXMLDocumentBuilder(null,null, ".xml");
	defaultMozHTMLDocumentBuilder = new MozHTMLDocumentBuilder(null, null);
    if(hasMozillaSVG) {
        defaultMozSVGDocumentBuilder = new MozSVGDocumentBuilder(null,null);
    }
    else {
        defaultMozSVGDocumentBuilder = new MozXMLDocumentBuilder(null,null, ".svg");
    }
	defaultContentType = "text/xml";
    factory = new MozDocumentBuilderFactory();
  }


  //
  //   Adobe SVG Viewer support 
  //
  //
  //
    
  //
  //   get a document ready for the next test
  //
  function ASVStartLoad(sourceURL) {
    //
    //   must create embed element in containing HTML
    //
    var embed = document.createElement("embed");
    embed.src = sourceURL + ".svg";
    embed.height= 100;
    embed.width = 100;
    embed.type = "image/svg+xml";
    var htmlelem = document.documentElement;
    var child = htmlelem.firstChild;
    while(child != null) {
		if(child.nodeName == "BODY") {
			child.appendChild(embed);
			break;
		}
		child = child.nextSibling;
	}
	return embed;
  }

  function ASVDocumentBuilder_load(sourceURL, willBeModified) {
    var embed = null;
    for(var i = 0; i < this.cache.length; i++) {
        if(this.cache[i].URL == sourceURL) {
			embed = this.cache[i].testdoc;
			if(embed != null && embed.readyState == "complete") {
				if(willBeModified) {
					this.cache[i].testdoc = ASVStartLoad(sourceURL);
				}
				return embed.getSVGDocument();
			}
        }
    }
    embed = ASVStartLoad(sourceURL);
    //
    //  if the current doc will be modified, start loading another
    //
    if(willBeModified) {
	    this.cache[this.cache.length] = new DocumentBuilderCacheEntry(sourceURL, ASVStartLoad(sourceURL));
    }
    for(var i = 0; i < 5; i++) {

        alert("Document loading: Press OK continue.");
        if(embed.readyState == "complete") break;
    }

	doc = embed.getSVGDocument();

	//
	//   if the document will be modified
	//	     start another SVG load on the same document
	//       to be ready for next time
	if(willBeModified) {
	    this.dirty[this.dirty.length] = embed;
	}
	//
	//   if this document will not be modified
	//      add it to the cache
	else {
		this.cache[this.cache.length] = new DocumentBuilderCacheEntry(sourceURL, embed);
	}

    return doc;
  }

   function ASVDocumentBuilder_getDOMImplementation() {
		for(var i = 0; i < this.cache.length; i++) {
		    if(this.cache[i].testdoc.readyState == "complete") {
		       return this.cache[i].testdoc.getSVGDocument().implementation;
		    }
		}
		var testdoc = load("staff",false);
		return testdoc.implementation;
	}

  function ASVDocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "expandEntityReferences") {
        return true;
    }
    return false;
  }
  
  //
  //   dispose of modified documents by removing their 
  //       embed section
  //
  function ASVDocumentBuilder_close(testdoc) {
	for(i = 0; i < this.dirty.length; i++) {
	  var embed = this.dirty[i];
	  if(embed.getSVGDocument() == testdoc) {
		embed.parentNode.removeChild(embed);
		break;
	  }
	}
  }
  
  function ASVDocumentBuilder_checkAttributes(attrNames, attrValues) {
      if(this.attrNames == null) {
         if(attrNames == null) {
            return true;
         }
      }
      return false;
  }
  
    function ASVDocumentBuilder_checkAvailability(sourceURL) {
        return true;
    }

  function ASVDocumentBuilder_hasFeature(feature, version) {
    var upfeature = feature.toUpperCase();
    if(version == null) {
		switch(upfeature) {
			case "XML":
			case "ORG.W3C.DOM":
			case "CORE":
			case "EVENTS":
			return true;
			
			case "HTML":
			return false;
		}
	}
	return this.getDOMImplementation().hasFeature(feature,version);
  }
  

  function ASVDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.cache = new Array();
    this.dirty = new Array();
    this.load = ASVDocumentBuilder_load;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = ASVDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = ASVDocumentBuilder_getImplementationAttribute;
    this.checkAttributes = ASVDocumentBuilder_checkAttributes;
    this.checkAvailability = ASVDocumentBuilder_checkAvailability;
    this.close = ASVDocumentBuilder_close;
    this.hasFeature = ASVDocumentBuilder_hasFeature;
    this.toAutoCase = XMLToAutoCase;
    this.toAutoCaseArray = XMLToAutoCaseArray;
    if(attrNames != null) {
        for(var i = 0; i < attrNames.length; i++) {
            if(attrNames[i] == "expandEntityReferences" && attrValues[i] == false) {
                throw "Adobe SVG Viewer can not preserve entities";
            }
            if(attrNames[i] == "ignoringElementContentWhitespace" && attrValues[i] == true) {
                throw "Adobe SVG Viewer can not preserve ignorable whitespace";
            }
        }
    }
  }




  function MSXMLApplyParserAttributes(parser, attrNames, attrValues) {
	if(attrNames != null) {
	    var i;
		for(i = 0; i < attrNames.length; i++) {
			if(attrNames[i] == "expandEntityReferences") {
				if(attrValues[i] == true) {
					throw "MSXML does not support expanding entity references";
				}
			}
			if(attrNames[i] == "validate") {
				parser.validateOnParse = attrValues[i];
			}
			if(attrNames[i] == "ignoreElementContentWhitespace") {
				parser.preserveWhiteSpace = !attrValues[i];
			}
		}
	 }
  }

  function MSXMLDocumentBuilder_checkAvailability(sourceURL) {
    return true;
  }

  function DocumentBuilderCacheEntry(url, testdoc) {
      this.url = url;
      this.testdoc = testdoc;
  }

  function checkCache(willBeModified,cache, sourceURL) {  
    //
    //       return any previously loaded instance
		for(i = 0; i < cache.length; i++) {
			if(cache[i] != null && cache[i].url == sourceURL) {
			    var testdoc = cache[i].testdoc;
			    //
			    //   if it will be modified then
			    //       remove it from the cache
			    if(willBeModified) {
			       cache[i] = null;
			    }
				return testdoc;
			}
		}
	   return null;
    }
  

  function MSXMLDocumentBuilder_load(sourceURL, willBeModified) {
	if(!this.parser.load(sourceURL + ".xml")) {
		throw this.parser.parseError.reason;
	}
    //
    //   if the first child of the document is a PI representing
    //      the XML Declaration, remove it from the tree.
    //
    //   According to the DOM FAQ, this behavior is not wrong,
    //      but the tests are written assuming that it is not there.
    //
    var xmlDecl = this.parser.firstChild;
    if(xmlDecl.nodeType == 7 && xmlDecl.target.toLowerCase() == "xml") {
        this.parser.removeChild(xmlDecl);
    }
	return this.parser;
  }

   function MSXMLDocumentBuilder_getDOMImplementation() {
        return this.parser.domImplementation;
   }


  function MSXMLDocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "ignoringElementContentWhitespace") {
        return !this.parser.preserveWhiteSpace;
    }
    return false;
  }
  
  function MSXMLDocumentBuilder_close(testdoc) {
  }
  
  function MSXMLDocumentBuilder_checkAttributes(attrNames, attrValues) {
     if(this.attrNames == null) {
        if(attrNames == null) {
           return true;
        }
     }
     return false;
  }
  
  function MSXMLDocumentBuilder_hasFeature(feature, version) {
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

  function MSXMLDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    
    this.load = MSXMLDocumentBuilder_load;
    this.checkAvailability = MSXMLDocumentBuilder_checkAvailability;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = MSXMLDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MSXMLDocumentBuilder_getImplementationAttribute;
    this.close = MSXMLDocumentBuilder_close;
    this.checkAttributes = MSXMLDocumentBuilder_checkAttributes;
    this.hasFeature = MSXMLDocumentBuilder_hasFeature;
    this.toAutoCase = XMLToAutoCase;
    this.toAutoCaseArray = XMLToAutoCaseArray;
    
    this.parser = new ActiveXObject("MSXML2.DOMDocument.3.0");
    this.parser.async = false;
    this.parser.preserveWhiteSpace = true;
    MSXMLApplyParserAttributes(this.parser,this.attrNames, this.attrValues);    
  }
  

  function MSHTMLApplyParserAttributes(parser, attrNames, attrValues) {
	if(attrNames != null) {
	    var i;
		for(i = 0; i < attrNames.length; i++) {
			if(attrNames[i] == "expandEntityReferences") {
				if(attrValues[i] == true) {
					throw "MSHTML does not support expanding entity references";
				}
			}
			if(attrNames[i] == "validate") {
				parser.validateOnParse = attrValues[i];
			}
			if(attrNames[i] == "ignoreElementContentWhitespace") {
				parser.preserveWhiteSpace = !attrValues[i];
			}
		}
	 }
  }

  function MSHTMLDocumentBuilder_checkAvailability(sourceURL) {
	switch(sourceURL)
	{
		case "staff":
		case "staffNS":
		case "staff.xml":
		case "staffNS.xml":
		throw sourceURL + " not available for HTML";
	}
  }


  function MSHTMLDocumentBuilder_load(sourceURL, willBeModified) {
    //
    //   resolve full URL
    //
	var absURL = location.href;
	absURL = absURL.substring(0,absURL.lastIndexOf("/")+1) + sourceURL + ".html";
	//
	//      see if there is an available copy around
	//
	var newDoc = checkCache(willBeModified, this.cache, absURL);
	//
	//   if not create a new window
	//
	if(newDoc == null) {
		var newWindow = window.open(absURL);
		newDoc = newWindow.document;
		if(!willBeModified) {
		   this.cache[this.cache.length] = new DocumentBuilderCacheEntry(absURL, newDoc);
		}
	}
	return newDoc; 
  }

   function MSHTMLDocumentBuilder_getDOMImplementation() {
		return document.implementation;
   }


  function MSHTMLDocumentBuilder_getImplementationAttribute(attr) {
    return false;
  }
  
  function MSHTMLDocumentBuilder_close(testdoc) {
      testdoc.parentWindow.close();
  }
  
  function MSHTMLDocumentBuilder_checkAttributes(attrNames, attrValues) {
     //
     //    if no attributes were specified,
     //        the document builder can be reused
     if(this.attrNames == null) {
		if(attrNames == null) {
			return true;
		}
     }
     return false;
     
  }
  
  function MSHTMLDocumentBuilder_hasFeature(feature, version) {
    var upfeature = feature.toUpperCase();
    switch(upfeature) {
		case "HTML":
		case "CORE":
		return true;
	}		
	return false;
  }
  

  function MSHTMLDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.cache = new Array();
    this.load = MSHTMLDocumentBuilder_load;
    this.checkAvailability = MSHTMLDocumentBuilder_checkAvailability;
    this.isDOMExceptionCode = isDOMExceptionCode;
    this.getDOMImplementation = MSHTMLDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MSHTMLDocumentBuilder_getImplementationAttribute;
    this.close = MSHTMLDocumentBuilder_close;
    this.checkAttributes = MSHTMLDocumentBuilder_checkAttributes;
    this.hasFeature = MSHTMLDocumentBuilder_hasFeature;
    this.toAutoCase = HTMLToAutoCase;
    this.toAutoCaseArray = HTMLToAutoCaseArray;
  }

  var defaultMSHTMLDocumentBuilder = null;
  var defaultMSXMLDocumentBuilder = null;
  var defaultASVDocumentBuilder = null;


  function IE5DocumentBuilderFactory_newDocumentBuilder(attrNames, attrValues,contentType) {
    if(contentType != null) {
        switch(contentType) {
            case "image/xml+svg":
            if(defaultASVDocumentBuilder.checkAttributes(attrNames,attrValues)) {
                return defaultASVDocumentBuilder;
            }
            return new ASVDocumentBuilder(attrNames, attrValues);

            case "text/html":
            if(defaultMSHTMLDocumentBuilder.checkAttributes(attrNames, attrValues)) {
                return defaultMSHTMLDocumentBuilder;
            }
            return new MSHTMLDocumentBuilder(attrNames, attrValues);
         }
      }
      if(defaultMSXMLDocumentBuilder.checkAttributes(attrNames, attrValues)) {
          return defaultMSXMLDocumentBuilder;
      }
      return new MSXMLDocumentBuilder(attrNames, attrValues);
  }

  function IE5DocumentBuilderFactory() {
    this.newDocumentBuilder = IE5DocumentBuilderFactory_newDocumentBuilder;
  }

  if(factory == null && isIE5Up) {
    factory = new IE5DocumentBuilderFactory();
    defaultContentType = "text/xml";
    defaultMSXMLDocumentBuilder = new MSXMLDocumentBuilder(null,null);
    defaultMSHTMLDocumentBuilder = new MSHTMLDocumentBuilder(null,null);
    defaultASVDocumentBuilder = new ASVDocumentBuilder(null,null);
  }
  
  if(factory == null) {
	alert("Unrecognized browser: " + navigator.userAgent);
  }


var isTestPageLoaded=false;

function isLoaded() {
        return isTestPageLoaded;
}
function newOnLoadEvent() {
        isTestPageLoaded=true;
}

window.onload=newOnLoadEvent;
