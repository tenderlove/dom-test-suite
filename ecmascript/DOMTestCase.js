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


  var factory = null;


  function MozApplyParserAttributes(parser, attrNames, attrValues) {
  }
 
  var mozStaffDocs = new Array(); 

  var docsStarted = 0;
  var docsLoaded = 0;

  function documentLoaded(e) {
      docsLoaded++;
  }


  //
  //   get a document ready for the next test
  //
  function MozAdvanceLoad(sourceURL) {
    var doc = document.implementation.createDocument("","temp",null);
    doc.load(sourceURL);
    for(var i = 0; i <= mozStaffDocs.length; i++) {
        if(i == mozStaffDocs.length || mozStaffDocs[i] == null) {
            mozStaffDocs[i] = doc;
            break;
        }
    }
  }

  function MozDocumentBuilder_load(sourceURL, willBeModified) {
    if(sourceURL == 'staff.xml' && this.attrNames == null && this.attrValues == null) {
        var doc = null;
        for(var i = 0; i < mozStaffDocs.length; i++) {
            doc = mozStaffDocs[i];
            if(doc != null && doc.documentElement.nodeName == "staff") {
                if(willBeModified) {
                    mozStaffDocs[i] = null;
                    MozAdvanceLoad(sourceURL);
                }
                return doc;
            }
        }
    }
    doc = document.implementation.createDocument("","temp",null);
    //
    //  never seems to fire
    //
    doc.addEventListener("load",documentLoaded,false);
    //
    //   need to add listener and wait
    docsStarted++;
    doc.load(sourceURL);
    for(var i = 0; i < 5; i++) {
        if(docsLoaded >= docsStarted) break;
        alert("Load attempt " + docsStarted.toString() + ": Press OK continue.");
        if(doc.documentElement.nodeName != "temp") break;
    }

    if(sourceURL == "staff.xml") {
        if(willBeModified) {
            MozAdvanceLoad(sourceURL);
        }
        else {
            mozStaffDocs[mozStaffDocs.length] = doc;
        }
    }
    return doc;
  }

   function MozDocumentBuilder_getDOMImplementation() {
        return document.implementation;
   }

  function MozDocumentBuilder_isDOMExceptionCode(ex, code) {
    return true;
  }

  function MozDocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "expandEntityReferences") {
        return true;
    }
    return false;
  }

  function MozDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.load = MozDocumentBuilder_load;
    this.isDOMExceptionCode = MozDocumentBuilder_isDOMExceptionCode;
    this.getDOMImplementation = MozDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = MozDocumentBuilder_getImplementationAttribute;
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

  var mozDefaultBuilder = null;

  function MozDocumentBuilderFactory_newDocumentBuilder(attrNames, attrValues) {
    if(attrNames == null && attrValues == null) {
        return mozDefaultBuilder;
    }
    return new MozDocumentBuilder(attrNames, attrValues);
  }

  function MozDocumentBuilderFactory() {
    this.newDocumentBuilder = MozDocumentBuilderFactory_newDocumentBuilder;
  }

  if(navigator.appName.indexOf("Netscape") != -1) {
    mozDefaultBuilder = new MozDocumentBuilder(null,null);
    factory = new MozDocumentBuilderFactory();
    //
    //  preload a couple of staff.xml documents
    //
    MozAdvanceLoad("staff.xml");
    MozAdvanceLoad("staff.xml");
  }


  //
  //   Adobe SVG Viewer support 
  //
  //
  //
    
  function ASVApplyParserAttributes(parser, attrNames, attrValues) {
  }
 
  //
  //   actually, array of <EMBED> elements
  //
  var asvStaffDocs = new Array();

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
    if(sourceURL == 'staff.xml' && this.attrNames == null && this.attrValues == null) {
        var embed = null;
        for(var i = 0; i < asvStaffDocs.length; i++) {
            embed = asvStaffDocs[i];
            if(embed != null && embed.readyState == "complete") {
                if(willBeModified) {
                    asvStaffDocs[i] = ASVStartLoad(sourceURL);
                }
                return embed.getSVGDocument();
            }
        }
    }
    var embed = ASVStartLoad(sourceURL);
    for(var i = 0; i < 5; i++) {
        alert("Document loading: Press OK continue.");
        if(embed.readyState == "complete") break;
    }

	doc = embed.getSVGDocument();

    if(sourceURL == "staff.xml") {
        if(willBeModified) {
            for(var i = 0; i <= asvStaffDocs.length; i++) {
                if(i == asvStaffDocs.length || asvStaffDocs[i] == null) {
                    asvStaffDocs[i] = ASVStartLoad(sourceURL);
                    break;
                }
            }
        }
        else {
            asvStaffDocs[asvStaffDocs.length] = embed;
        }
    }
    return doc;
  }

   function ASVDocumentBuilder_getDOMImplementation() {
        for(var i = 0; i < asvStaffDocs.length; i++) {
            if(asvStaffDocs[i] != null && asvStaffDocs[i].readyState == "complete") {
                return asvStaffDocs[i].getSVGDocument().implementation;
            }
        }
        var embed = ASVStaffLoad("staff.xml");
        asvStaffDocs[asvStaffDocs.length] = embed;
        return embed.getSVGDocument().implementation;
   }

  function ASVDocumentBuilder_isDOMExceptionCode(ex, code) {
    return true;
  }

  function ASVDocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "expandEntityReferences") {
        return true;
    }
    return false;
  }

  function ASVDocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.load = ASVDocumentBuilder_load;
    this.isDOMExceptionCode = ASVDocumentBuilder_isDOMExceptionCode;
    this.getDOMImplementation = ASVDocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = ASVDocumentBuilder_getImplementationAttribute;
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

  var asvDefaultBuilder = null;

  function ASVDocumentBuilderFactory_newDocumentBuilder(attrNames, attrValues) {
    if(attrNames == null && attrValues == null) {
        return asvDefaultBuilder;
    }
    return new ASVDocumentBuilder(attrNames, attrValues);
  }

  function ASVDocumentBuilderFactory() {
    this.newDocumentBuilder = ASVDocumentBuilderFactory_newDocumentBuilder;
  }


  //
  //
  //    Uncomment the following 4 lines to test Adobe SVG Viewer
  //
  //
  //

//  if(navigator.appName.indexOf("Microsoft") != -1) {
//    asvDefaultBuilder = new ASVDocumentBuilder(null,null);
//    factory = new ASVDocumentBuilderFactory();
//  }



  function IE5ApplyParserAttributes(parser, attrNames, attrValues) {
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

  function IE5DocumentBuilder_load(sourceURL, willBeModified) {
	var actualURL = sourceURL;
	if(!this.parser.load(actualURL)) {
		throw this.parser.parseError.reason;
	}
    //
    //   if the first child of the document is a PI representing
    //      the XML Declaration, remove it from the tree.
    //
    //   According to the DOM FAQ, this behavior is not wrong,
    //      but the tests are written assumming that it is not there.
    //
    var xmlDecl = this.parser.firstChild;
    if(xmlDecl.nodeType == 7 && xmlDecl.target.toLowerCase() == "xml") {
        this.parser.removeChild(xmlDecl);
    }
	return this.parser;
  }

   function IE5DocumentBuilder_getDOMImplementation() {
        return this.parser.domImplementation;
   }

  //
  //   This function checks the exception raised in the test
  //   If this function returns true, then the exception is 
  //      consistent with the exception code parameter
  //
  //   This code attempts to determine the reason for the exception
  //      to reduce the chance that an unrelated exception causes
  //      the test to pass.
  function IE5DocumentBuilder_isDOMExceptionCode(ex, code) {
	var retval;
    switch(code) {
        //
        //  INDEX_SIZE_ERR
        case 1:
        retval = (ex.number == -2147024809);
        break;

        //
        //  HIERARCHY_REQUEST_ERR
        case 3:
        retval = (ex.number == -2147467259);
        break;


        //
        //  INVALID_CHARACTER_ERR
        case 5:
        retval = (ex.description.search(".*may not contain.*") >= 0);
        break;

        //
        //   NO_MODIFICATION_ALLOWED_ERR
        case 7:
		retval = (ex.description.search(".*read.*only.*") >= 0);
        break;

        //
        //   NOT_FOUND_ERR
        //
        case 8:
        retval = (ex.number == -2147024809 || ex.number == -2147467259);
        break;

        //
        //   INUSE_ATTRIBUTE_ERR
        case 10:
        retval = (ex.description.search(".*must be removed.*") >= 0);
        break;
	}
	return retval;
  }

  function IE5DocumentBuilder_getImplementationAttribute(attr) {
    if(attr == "ignoringElementContentWhitespace") {
        return !this.parser.preserveWhiteSpace;
    }
    return false;
  }

  function IE5DocumentBuilder(attrNames, attrValues) {
    this.attrNames = attrNames;
    this.attrValues = attrValues;
    this.load = IE5DocumentBuilder_load;
    this.isDOMExceptionCode = IE5DocumentBuilder_isDOMExceptionCode;
    this.getDOMImplementation = IE5DocumentBuilder_getDOMImplementation;
    this.getImplementationAttribute = IE5DocumentBuilder_getImplementationAttribute;
    this.parser = new ActiveXObject("MSXML2.DOMDocument.3.0");
    this.parser.async = false;
    this.parser.preserveWhiteSpace = true;
    IE5ApplyParserAttributes(this.parser,this.attrNames, this.attrValues);    
  }

  var IE5DefaultBuilder = new IE5DocumentBuilder(null,null);

  function IE5DocumentBuilderFactory_newDocumentBuilder(attrNames, attrValues) {
    if(attrNames == null && attrValues == null) {
        return IE5DefaultBuilder;
    }
    return new IE5DocumentBuilder(attrNames, attrValues);
  }

  function IE5DocumentBuilderFactory() {
    this.newDocumentBuilder = IE5DocumentBuilderFactory_newDocumentBuilder;
  }

  if(factory == null && navigator.appName.indexOf("Microsoft") != -1) {
    factory = new IE5DocumentBuilderFactory();
  }

