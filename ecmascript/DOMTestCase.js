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

  var factory = new IE5DocumentBuilderFactory();

  function assertTrue(descr, actual) {
    assert(descr,actual);
  }

  function assertFalse(descr, actual) {
    assert(descr, !actual);
  }

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
