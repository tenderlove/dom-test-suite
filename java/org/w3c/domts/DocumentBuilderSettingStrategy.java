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


  /**
  * This class is a strategy that provides the mapping
  * from an abstract setting (such as DocumentBuilderSetting.validating)
  * to a specific DOM implementation
  *
  * @author Curt Arnold
  * @date 2 Feb 2002
  */
 public abstract class DocumentBuilderSettingStrategy {
    protected DocumentBuilderSettingStrategy() {}

    public boolean hasConflict(DocumentBuilderSettingStrategy other) {
      return (other == this);
    }

    public abstract void applySetting(DocumentBuilderFactory factory,boolean value)
       throws DOMTestIncompatibleException;

    public abstract boolean hasSetting(DOMTestDocumentBuilderFactory factory);

    public static final DocumentBuilderSettingStrategy coalescing =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          factory.setCoalescing(value);
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return factory.isCoalescing();
        }

      };

    public static final DocumentBuilderSettingStrategy expandEntityReferences =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          factory.setExpandEntityReferences(value);
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return factory.isExpandEntityReferences();
        }
      };

    public static final DocumentBuilderSettingStrategy ignoringElementContentWhitespace =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          factory.setIgnoringElementContentWhitespace(value);
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return factory.isIgnoringElementContentWhitespace();
        }
      };


    public static final DocumentBuilderSettingStrategy namespaceAware =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          factory.setNamespaceAware(value);
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return factory.isNamespaceAware();
        }
      };


    public static final DocumentBuilderSettingStrategy validating =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          factory.setValidating(value);
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return factory.isValidating();
        }
      };


    public static final DocumentBuilderSettingStrategy signed =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          if(!value) {
            throw new DOMTestIncompatibleException(null,DocumentBuilderSetting.notSigned);
          }
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return true;
        }
      };

    public static final DocumentBuilderSettingStrategy hasNullString =
      new DocumentBuilderSettingStrategy() {
        public void applySetting(DocumentBuilderFactory factory, boolean value)
          throws DOMTestIncompatibleException {
          if(!value) {
            throw new DOMTestIncompatibleException(null,DocumentBuilderSetting.notHasNullString);
          }
        }
        public boolean hasSetting(DOMTestDocumentBuilderFactory factory) {
          return true;
        }
      };
}