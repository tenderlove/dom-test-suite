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


 package org.w3c.domts;
 import java.lang.reflect.*;
 import javax.xml.parsers.*;
 import java.text.*;
 import java.util.*;
 import javax.xml.parsers.*;


  /**
  * This class is an parser setting,
  * such as non-validating or entity-expanding.
  *
  * @author Curt Arnold
  * @date 2 Feb 2002
  */
 public final class DocumentBuilderSetting {
  private final String property;
  private final boolean value;
  private final DocumentBuilderSettingStrategy strategy;

  public final static DocumentBuilderSetting coalescing =
    new DocumentBuilderSetting("coalescing",true,
        DocumentBuilderSettingStrategy.coalescing);

  public final static DocumentBuilderSetting notCoalescing =
    new DocumentBuilderSetting("coalescing",false,
        DocumentBuilderSettingStrategy.coalescing);


  public final static DocumentBuilderSetting expandEntityReferences =
    new DocumentBuilderSetting("expandEntityReferences",true,
        DocumentBuilderSettingStrategy.expandEntityReferences);


  public final static DocumentBuilderSetting notExpandEntityReferences =
    new DocumentBuilderSetting("expandEntityReferences",false,
        DocumentBuilderSettingStrategy.expandEntityReferences);

  public final static DocumentBuilderSetting ignoringElementContentWhitespace =
    new DocumentBuilderSetting("ignoringElementContentWhitespace",true,
        DocumentBuilderSettingStrategy.ignoringElementContentWhitespace);


  public final static DocumentBuilderSetting notIgnoringElementContentWhitespace =
    new DocumentBuilderSetting("ignoringElementContentWhitespace",false,
        DocumentBuilderSettingStrategy.ignoringElementContentWhitespace);


  public final static DocumentBuilderSetting namespaceAware =
    new DocumentBuilderSetting("namespaceAware",true,
        DocumentBuilderSettingStrategy.namespaceAware);


  public final static DocumentBuilderSetting notNamespaceAware =
    new DocumentBuilderSetting("namespaceAware",false,
        DocumentBuilderSettingStrategy.namespaceAware);



  public final static DocumentBuilderSetting validating =
    new DocumentBuilderSetting("validating",true,
        DocumentBuilderSettingStrategy.validating);

  public final static DocumentBuilderSetting notValidating =
    new DocumentBuilderSetting("validating",false,
        DocumentBuilderSettingStrategy.validating);

  public final static DocumentBuilderSetting signed =
    new DocumentBuilderSetting("signed",true,
        DocumentBuilderSettingStrategy.signed);


  public final static DocumentBuilderSetting notSigned =
    new DocumentBuilderSetting("signed",false,
        DocumentBuilderSettingStrategy.signed);

  public final static DocumentBuilderSetting hasNullString =
    new DocumentBuilderSetting("hasNullString",true,
        DocumentBuilderSettingStrategy.hasNullString);


  public final static DocumentBuilderSetting notHasNullString =
    new DocumentBuilderSetting("hasNullString",false,
        DocumentBuilderSettingStrategy.hasNullString);

  /**
   * Protected constructor, use static members for supported settings.
   */
  protected DocumentBuilderSetting(String property,
    boolean value, DocumentBuilderSettingStrategy strategy) {
    if(property == null) {
      throw new NullPointerException("property");
    }
    this.property = property;
    this.value = value;
    this.strategy = strategy;
  }

 /**
  * Returns true if the settings have a conflict or are identical.
  * @param other other setting, may not be null.
  */
  public final boolean hasConflict(DocumentBuilderSetting other) {
    if(other == null) {
      throw new NullPointerException("other");
    }
    if(other == this) {
      return true;
    }
    return strategy == other.strategy;
  }

  public final boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
    return strategy.hasSetting(factory) == value;
  }

  public final void applySetting(DocumentBuilderFactory builder)  
    throws DOMTestIncompatibleException {
    strategy.applySetting(builder,value);
  }

  public final String toString() {
    StringBuffer builder = new StringBuffer(property);
    builder.append('=');
    builder.append(String.valueOf(value));
    return builder.toString();
  }



}