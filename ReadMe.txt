This is preliminary (21/11/2001) documentation on how to build the DOM 
Test Suite. A complete version will be published at the DOM TS pages at 
www.w3.org/DOM/Test in the next few days.

In order to build the DOM TS with the tests that are currently commited to 
the CVS, you need first to do a checkout of the 2001/DOM-Test-Suite 
branch, which you can do anonymously.

Having done this, you will need the following software to build the test 
suite (the ECMA and Java code, the documentation, the DTD and Schema files 
for the DOM TS MarkupLanguage) [proper links will be provided in the 
final document]:

Ant 1.4
Xerces
Xalan (You could use a different XSLTprocessor, we've used Xalan 
successfully)
SED
Patch

Download Ant 1.4 and Xalan-J2.1 binaries, remove crimson.jar and jaxp.jar 
from the Ant/lib directory and put Xerces.jar and xalan.jar in their 
place.

See to that you have included ant/bin, java, sed and patch on your path 
and set JAVA_HOME. 

St current directory to DOM-Test-Suite (if you want to test the build, 
copy the entire 2001/DOM-Test-Suite to a different location and make that 
the current directory) and do 

ant usage 

to see what options you have to build the suite.

The task you will probably use most frequently is dom1-core-jar, 
dom1-schema, dom1-core-validate-tests, dom1-core-gen-ecmascript and 
dom1-core-gen-ecmascript to validate the test files and transform them to 
tests in ECMA and Java.

The builds take approximately 10 minutes each and start by ant downloading 
the DOM specifications from the W3C. Please see to that you have a propser 
internet connection.

Ant will generate the following directories in which you will find the 
relevant files (all directories will be created in teh current directory):

dist, which inludes the documentation in Doxygen format (Doxygen will be 
downloaded for you), the dom1-core-jar, junit.jar and 
junit-jar. You can use JUnit, which will be downloaded by Ant, to test 
your Jaxp-compliant parser by putting it in this directory and executing 
java -jar dom1-core-jar

build, which contains the generated schema files, metadata about the tests 
and the matrix which states what tests exist and what their purpose is. 
In this directory you will find the following directories:

ecmascript, which contains the generated ECMA script code

java, which contains the java code

doxygen, which contains the documentation of all tests and each test 
separately

Finally, in your current directory you will also find downloaded software 
(JUnit, JsUnit) and the downloaded DOM specifications.


Notes on the CVS branch organisation:

We will organise the contents for easier accessibility before release. All 
folders carry fairly self-evident names; iw you want to browse the 
stylesheets that are used, go to transforms, if you want to look at the 
XML test suorce files, go to tests, and so forth.


NOTE: If you build the DOM Test Suite, bear in mind that it has not been 
officially released; you can and should therefore not use the results to 
make any claims as far as DOM conformance is concerned. The DOM TS will be 
officially released shortly, in the meanwhile we welcome your comments to 
www-dom-ts@w3.org, the DOM TS mailing list.
