/*
Copyright (c) 2003 World Wide Web Consortium,
(Massachusetts Institute of Technology, Institut National de
Recherche en Informatique et en Automatique, Keio University). All
Rights Reserved. This program is distributed under the W3C's Software
Intellectual Property License. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.
See W3C License http://www.w3.org/Consortium/Legal/ for more details.
*/

function updateImplementationAttribute(options, implAttribute) {
   var builderVal = builder.getImplementationAttribute(implAttribute);
   var disabled = false;
   for (var i = 0; i < builder.fixedAttributeNames.length; i++) {
      if (implAttribute == builder.fixedAttributeNames[i]) {
        disabled = true;
        break;
      }
   }
   updateTrueFalse(options, builderVal, disabled);
}

function updateTrueFalse(options, builderVal, disabled) {
   for(var i = 0; i < options.length; i++) {
      if (options[i].value == "true") {
         options[i].checked = builderVal;
      } else {
         options[i].checked = !builderVal;
      }
      options[i].disabled = disabled;
   }
}


function onImplementationChange() {
    var implOptions = document.forms[0].implementation;
    for(var i = 0; i < implOptions.length; i++) {
        if (implOptions[i].checked) {
            builder = createBuilder(implOptions[i].value);
            break;
        }
    }
    update();
    updateIncompatibleTests();
}



function update() {
    updateTrueFalse(document.forms[0].asynchronous, builder.async, !builder.supportsAsyncChange);
    updateImplementationAttribute(document.forms[0].expandEntityReferences, "expandEntityReferences");
    updateImplementationAttribute(document.forms[0].ignoringElementContentWhitespace, "ignoringElementContentWhitespace");
    updateImplementationAttribute(document.forms[0].validating, "validating");
    updateImplementationAttribute(document.forms[0].coalescing, "coalescing");
    updateImplementationAttribute(document.forms[0].namespaceAware, "namespaceAware");

    var contentTypes = document.forms[0].contentType;
    for(i = 0; i < contentTypes.length; i++) {
        if (contentTypes[i].value == builder.contentType) {
            contentTypes[i].checked = true;
        }
        var disabled = true;
        for(var j = 0; j < builder.supportedContentTypes.length; j++) {
            if (contentTypes[i].value == builder.supportedContentTypes[j]) {
                disabled = false;
                break;
            }
        }
        contentTypes[i].disabled = disabled;
    }
}

function updateIncompatibleTests() {
    var incompatibleTests = new Array();
    checkTests(null, incompatibleTests);
    var i = 0;
    existingTests = document.forms[0].incompatible.options;
    var overlapCount = existingTests.length;
    if (overlapCount > incompatibleTests.length) {
        overlapCount = incompatibleTests.length;
        existingTests.length = overlapCount;
    }
    for (i = 0; i < overlapCount; i++) {
        if (existingTests[i].text != incompatibleTests[i]) {
            existingTests[i].text = incompatibleTests[i];
        }
    }
    if (incompatibleTests.length > overlapCount) {
        for (; i < incompatibleTests.length; i++) {
            var newOption = document.createElement("option");
            newOption.text = incompatibleTests[i];
            document.forms[0].incompatible.insertBefore(newOption, null);
        }
    }
}

function setImplementationAttribute(implAttr, implValue) {
    try {
        builder.setImplementationAttribute(implAttr, implValue);
        updateIncompatibleTests();
    } catch(msg) {
        alert(msg);
        update();
    }
}

function setContentType(contentType) {
    for (var i = 0; i < builder.supportedContentTypes.length; i++) {
        if (builder.supportedContentTypes[i] == contentType) {
            builder.contentType = contentType;
            updateIncompatibleTests();
            return;
        }
    }
    alert(contentType + " not supported by selected implementation");
    update();
}

function checkTest(activeTests, inactiveTests, testName, loadedDocs, 
    featureNames, featureVersions, 
    implementationAttrNames, implementationAttrValues) {
    var active = true;
    var i;
    if (loadedDocs != null) {
        for (i = 0; i < loadedDocs.length; i++) {
            if (loadedDocs[i] == "staff" && !(builder.contentType == "text/xml" || builder.contentType == "image/svg+xml")) {
                active = false;
                break;
            }
        }
    }
    if (active && featureNames != null) {
        for (i = 0; i < featureNames.length; i++) {
            if (!builder.hasFeature(featureNames[i], featureVersions[i])) {
                active = false;
            }
        }
    }
    if (active && implementationAttrNames != null) {
        for (i = 0; i < implementationAttrNames.length; i++) {
            var existing = builder.getImplementationAttribute(implementationAttrNames[i]);
            //
            //   if the setting doesn't equal the current (possibly fixed) setting
            //
            if (existing != implementationAttrValues[i]) {
                //
                //  see if it is settable
                //
                var settable = false;
                for (var j = 0; j < builder.configurableAttributeNames.length; j++) {
                    if (builder.configurableAttributeNames[i] == implementationAttrNames[i]) {
                        settable = true;
                        break;
                    }
                }
                active = settable;
            }
        }
    }
    if (active) {
        if (activeTests != null) {
            activeTests[activeTests.length] = testName;
        }
    } else {
        if (inactiveTests != null) {
            inactiveTests[inactiveTests.length] = testName;
        }
    }
}

function fillTestSelection() {
    var pageURL = location.href;
    if (pageURL.indexOf('?') != -1) {
        pageURL = pageURL.substring(0, pageURL.indexOf('?'));
    }
    var baseURL = pageURL.substring(0, pageURL.lastIndexOf('/') + 1);
    var tests = new Array();
    checkTests(tests, tests);
    var select = document.forms[0].testpage;
    select.options[0] = new Option("All compatible tests", pageURL);
    for (var i = 0; i < tests.length; i++) {
        select.options[i+1] = new Option(tests[i], baseURL + tests[i] + ".html");
    }
}

