/*
 * Copyright (c) 2001 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
 */

 /*
 $Log: DOMTestDocumentBuilderFactory.java,v $
 Revision 1.6  2003-06-27 05:36:05  dom-ts-4
 contentType condition fixes: http://www.w3.org/Bugs/Public/show_bug.cgi?id=241

 Revision 1.5  2003/04/23 05:48:24  dom-ts-4
 DOMTSML and framework support for createXPathEvaluator
 http://www.w3.org/Bugs/Public/show_bug.cgi?id=190

 Revision 1.4  2002/02/03 04:22:35  dom-ts-4
 DOM4J and Batik support added.
 Rework of parser settings

 Revision 1.3  2002/01/30 07:08:44  dom-ts-4
 Update for GNUJAXP

 Revision 1.2  2001/08/22 22:12:49  dom-ts-4
 Now passing all tests with default settings

 Revision 1.1  2001/07/23 04:52:20  dom-ts-4
 Initial test running using JUnit.

 */

package org.w3c.domts;

import javax.xml.parsers.*;
import org.w3c.dom.*;
import org.w3c.domts.*;
import java.lang.reflect.*;
import java.util.*;
import org.xml.sax.*;


/**
 * This class represents a particular parser and configuration
 * (such as entity-expanding, non-validating, whitespace ignoring)
 * for a test session.  Individual tests or suites within a
 * session can override the session properties on a call to
 * createBuilderFactory.
 *
 * @author Curt Arnold
 */
public abstract class DOMTestDocumentBuilderFactory {
  /**
   *   Parser configuration
   */
  private final DocumentBuilderSetting[] settings;


  /**
   *   Constructor
   *   @param properties Array of parser settings, may be null.
   */
  public DOMTestDocumentBuilderFactory(DocumentBuilderSetting[] settings)
    throws DOMTestIncompatibleException {
    if(settings == null) {
        this.settings = new DocumentBuilderSetting[0];
    }
    else {
        this.settings = (DocumentBuilderSetting[]) settings.clone();
    }
  }

  /**
   *   Returns an instance of DOMTestDocumentBuilderFactory
   *   with the settings from the argument list
   *   and any non-revoked settings from the current object.
   *   @param settings array of settings, may be null.
   */
  public abstract DOMTestDocumentBuilderFactory newInstance(DocumentBuilderSetting[] settings)
    throws DOMTestIncompatibleException;

  public abstract DOMImplementation getDOMImplementation();

  public abstract boolean hasFeature(String feature,String version);

  public abstract Document load(java.net.URL url) throws DOMTestLoadException;

  /**
   *  Creates XPath evaluator
   *  @param doc DOM document, may not be null
   */
  public Object createXPathEvaluator(Document doc)  {
      try {
          Method getFeatureMethod = doc.getClass().getMethod("getFeature",
            new Class[] { String.class, String.class });
          if (getFeatureMethod != null) {
              return getFeatureMethod.invoke(doc, new Object[] { "XPath", null });
          }
      }
      catch(Exception ex) {
      }
      return doc;
   }
        

    /**
     *   Merges the settings from the specific test case or suite
     *   with the existing (typically session) settings.
     *   @param settings new settings, may be null which will
     *   return clone of existing settings.
     */
  protected DocumentBuilderSetting[] mergeSettings(DocumentBuilderSetting[] newSettings)
  {
      if(newSettings == null) {
        return (DocumentBuilderSetting[]) settings.clone();
      }
      List mergedSettings = new ArrayList(settings.length + newSettings.length);
      //
      //    all new settings are respected
      //
      for(int i = 0; i < newSettings.length; i++) {
        mergedSettings.add(newSettings[i]);
      }
      //
      //    for all previous settings, take only those that
      //       do not conflict with existing settings
      for(int i = 0; i < settings.length; i++) {
        DocumentBuilderSetting setting = settings[i];
        boolean hasConflict = false;
        for(int j = 0; j < newSettings.length; j++) {
          DocumentBuilderSetting newSetting = newSettings[j];
          if(newSetting.hasConflict(setting) || setting.hasConflict(newSetting)) {
            hasConflict = true;
            break;
          }
        }
        if(!hasConflict) {
          mergedSettings.add(setting);
        }
      }

      DocumentBuilderSetting[] mergedArray =
        new DocumentBuilderSetting[mergedSettings.size()];
      for(int i = 0; i < mergedSettings.size(); i++) {
        mergedArray[i] = (DocumentBuilderSetting) mergedSettings.get(i);
      }
      return mergedArray;
    }


    public String addExtension(String testFileName) {
        return testFileName + ".xml";
    }

    public abstract boolean isCoalescing();

    public abstract boolean isExpandEntityReferences();

    public abstract boolean isIgnoringElementContentWhitespace();

    public abstract boolean isNamespaceAware();

    public abstract boolean isValidating();
    
    public String getContentType() {
    	return "text/xml";
    }

  /**
   * Creates an array of all determinable settings for the DocumentBuilder
   * including those at implementation defaults.
   * @param builder must not be null
   */
  public final DocumentBuilderSetting[] getActualSettings() {

    DocumentBuilderSetting[] allSettings = new DocumentBuilderSetting[] {
      DocumentBuilderSetting.coalescing,
      DocumentBuilderSetting.expandEntityReferences,
      DocumentBuilderSetting.hasNullString,
      DocumentBuilderSetting.ignoringElementContentWhitespace,
      DocumentBuilderSetting.namespaceAware,
      DocumentBuilderSetting.signed,
      DocumentBuilderSetting.validating,
      DocumentBuilderSetting.notCoalescing,
      DocumentBuilderSetting.notExpandEntityReferences,
      DocumentBuilderSetting.notHasNullString,
      DocumentBuilderSetting.notIgnoringElementContentWhitespace,
      DocumentBuilderSetting.notNamespaceAware,
      DocumentBuilderSetting.notSigned,
      DocumentBuilderSetting.notValidating
      };

      List list = new ArrayList(allSettings.length /2);
      for(int i = 0; i < allSettings.length; i++) {
        if(allSettings[i].hasSetting(this)) {
          list.add(allSettings[i]);
        }
      }
      DocumentBuilderSetting[] settings = new DocumentBuilderSetting[list.size()];
      for(int i = 0; i < settings.length; i++) {
        settings[i] = (DocumentBuilderSetting) list.get(i);
      }
      return settings;
  }

}

