/*
 * Copyright (c) 2001-2004 World Wide Web Consortium,
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
$Log: LSDocumentBuilderFactory.java,v $
Revision 1.1  2004-02-25 06:31:18  dom-ts-4
Add support for java test framework use of DOM L3 LS (bug 571)


*/

package org.w3c.domts;

import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSParser;
import java.util.*;

/**
 *   This class implements the generic parser and configuation
 *   abstract class for the DOM L3 implementations
 *
 *   @author Curt Arnold
 */
public class LSDocumentBuilderFactory
    extends DOMTestDocumentBuilderFactory {

	private final LSParser parser;
	private final DOMImplementation impl;

	/**
	 * 
	 * Abstract class for a strategy to map a DocumentBuilderSetting
	 * to an action on LSParser.
	 */
	private static abstract class LSStrategy {
		
		/**
		 * Constructor.
		 */
		protected LSStrategy() {
		}
		
		/**
		 * Applies setting to LSParser
		 * 
		 * @param setting setting
		 * @param parser parser
		 * @throws DOMTestIncompatibleException if parser does not support setting
		 */
		public abstract void applySetting(DocumentBuilderSetting setting, LSParser parser)
			throws DOMTestIncompatibleException;
		/**
		 * Gets state of setting for parser
		 * 
		 * @param parser parser
		 * @return state of setting
		 */
		public abstract boolean hasSetting(LSParser parser);
		
	}
	
	/**
	 * Represents a fixed setting, for example, all Java implementations
	 * supported signed values.
	 *  
	 */
	private static class LSFixedStrategy extends LSStrategy {
		private final boolean fixedValue;
		
		/**
		 * Constructor
		 * 
		 * @param settingName setting name
		 * @param fixedValue fixed value
		 */
		public LSFixedStrategy(boolean fixedValue) {
			this.fixedValue = fixedValue;
		}
		
		/**
		 * Apply setting.  Throws exception if requested setting
		 * does not match fixed value.
		 */
		public void applySetting(DocumentBuilderSetting setting, LSParser parser) 
			throws DOMTestIncompatibleException {
			if (setting.getValue() != fixedValue) {
				throw new DOMTestIncompatibleException(null, setting);
			}
		}
		/**
		 * Gets fixed value for setting
		 */
		public boolean hasSetting(LSParser parser) {
			return fixedValue;
		}
	}
	

	/**
	 * A strategy for a setting that can be applied by setting a DOMConfiguration
	 * parameter.
	 * 
	 */
	private static class LSParameterStrategy extends LSStrategy {
		private final String lsParameter;
		private final boolean inverse;

		/**
		 * Constructor
		 * 
		 * @param lsParameter corresponding DOMConfiguration parameter
		 * @param inverse if true, DOMConfiguration value is the inverse
		 * of the setting value
		 */
		public LSParameterStrategy(String lsParameter, boolean inverse) {
			this.lsParameter = lsParameter;
			this.inverse = inverse;
		}
		
		/**
		 * Apply setting
		 */
		public void applySetting(DocumentBuilderSetting setting, LSParser parser)
			throws DOMTestIncompatibleException {
			try {
				boolean lsValue = setting.getValue();
				if (inverse) {
					lsValue = !lsValue;
				}
				parser.getDomConfig().setParameter(lsParameter, new Boolean(lsValue));
			} catch(DOMException ex) {
				throw new DOMTestIncompatibleException(ex, setting);
			}
		}
		
		/**
		 * Get value of setting
		 */
		public boolean hasSetting(LSParser parser) {
			try {
				Boolean parameter = (Boolean) parser.getDomConfig().getParameter(lsParameter);
				if (parameter.booleanValue()) {
					if (inverse) {
						return false;
					}
				} else {
					if (!inverse) {
						return false;
					}
				}
				return true;
			} catch (DOMException ex) {
				return false;
			}
		}		
	}
	

	/**
	 * A strategy for the validation settings which require
	 * two DOMConfigurure parameters being set, 'validate' and 'schema-type' 
	 *
	 */
	private static class LSValidateStrategy extends LSParameterStrategy {
		private final String schemaType;

		/**
		 * Constructor
		 * @param schemaType schema type
		 */
		public LSValidateStrategy(String schemaType) {
			super("validate", false);
			this.schemaType = schemaType;
		}
		
		/**
		 * Apply setting
		 */
		public void applySetting(DocumentBuilderSetting setting, LSParser parser)
			throws DOMTestIncompatibleException {
			super.applySetting(setting, parser);
			try {
				parser.getDomConfig().setParameter("schema-type", schemaType);
			} catch(DOMException ex) {
				throw new DOMTestIncompatibleException(ex, setting);
			}
		}
		/**
		 * Get setting value
		 */
		public boolean hasSetting(LSParser parser) {
			if (super.hasSetting(parser)) {
				try {
					String parserSchemaType = (String) parser.getDomConfig().getParameter("schema-type");
					if (schemaType == null || schemaType.equals(parserSchemaType)) {
						return true;
					}
				} catch(DOMException ex) {
				}
			}
			return false;
		}
		
	}
	
	/**
	 * Strategies for mapping DocumentBuilderSettings to
	 * actions on LSParser
	 */
	private static final Map strategies;
	
	static {
		strategies = new HashMap();
		strategies.put("coalescing", new LSParameterStrategy("cdata-sections", true));
		strategies.put("expandEntityReferences", new LSParameterStrategy("entities", true));
        strategies.put("ignoringElementContentWhitespace", new LSParameterStrategy("element-content-whitespace", true));
        strategies.put("namespaceAware", new LSParameterStrategy("namespaces", false));
        strategies.put("validating", new LSValidateStrategy("http://www.w3.org/TR/REC-xml"));
        strategies.put("schemaValidating", new LSValidateStrategy("http://www.w3.org/2001/XMLSchema"));
        strategies.put("ignoringComments", new LSParameterStrategy("comments", true));
        strategies.put("signed", new LSFixedStrategy(true));
        strategies.put("hasNullString", new LSFixedStrategy(true));
	}
	
	
    /**
     * Creates a LS implementation of DOMTestDocumentBuilderFactory.
     * @param settings array of settings, may be null.
     * @throws DOMTestIncompatibleException 
     *     Thrown if implementation does not support the specified settings
     */
    public LSDocumentBuilderFactory(DocumentBuilderSetting[] settings)
        throws DOMTestIncompatibleException {
        super(settings);

        try {
        	DOMImplementationRegistry domRegistry = DOMImplementationRegistry.newInstance();
            impl = domRegistry.getDOMImplementation("LS");
        } catch (Exception ex) {
        	throw new DOMTestIncompatibleException(ex, null);
        }
        DOMImplementationLS factory = (DOMImplementationLS) impl;
        
        parser = factory.createLSParser(DOMImplementationLS.MODE_SYNCHRONOUS, null);

        if (settings != null) {
        	for(int i = 0; i < settings.length; i++) {
        		Object strategy = strategies.get(settings[i].getProperty());
        		if (strategy == null) {
        			throw new DOMTestIncompatibleException(null, settings[i]);        			
        		} else {
        			((LSStrategy) strategy).applySetting(settings[i], parser);
        		}
        	}
        }
    }

    /**
     *    Create new instance of document builder factory
     *    reflecting specified settings
     *    @param newSettings new settings
     *    @return New instance
     *    @throws DOMTestIncompatibleException 
     *         if settings are not supported by implementation
     */
    public DOMTestDocumentBuilderFactory newInstance(
        DocumentBuilderSetting[] newSettings)
        throws DOMTestIncompatibleException {
        if (newSettings == null) {
            return this;
        }
        DocumentBuilderSetting[] mergedSettings = mergeSettings(newSettings);
        return new LSDocumentBuilderFactory(mergedSettings);
    }

    /**
     *    Loads specified URL
     *    @param url url to load
     *    @return DOM document
     *    @throws DOMTestLoadException if unable to load document
     */
    public Document load(java.net.URL url) throws DOMTestLoadException {
        try {
        	return parser.parseURI(url.toString());
        } catch (Exception ex) {
            throw new DOMTestLoadException(ex);
        }
    }

    /**
     *     Gets DOMImplementation
     *     @return DOM implementation, may be null
     */
    public DOMImplementation getDOMImplementation() {
    	return impl;
    }

    /**
     *   Determines if the implementation supports the specified feature
     *   @param feature Feature
     *   @param version Version
     *   @return true if implementation supports the feature
     */
    public boolean hasFeature(String feature, String version) {
        return getDOMImplementation().hasFeature(feature, version);
    }

    
    private boolean hasProperty(String parameter) {
    	try {
    		return ((Boolean) parser.getDomConfig().getParameter(parameter)).booleanValue();
    	} catch (DOMException ex) {
    		return true;
    	}
    	
    }

    /**
     *   Indicates whether the implementation combines text and cdata nodes. 
     *   @return true if coalescing
     */
    public boolean isCoalescing() {
    	return !hasProperty("cdata-sections");
    }

    /**
     *   Indicates whether the implementation expands entity references. 
     *   @return true if expanding entity references
     */
    public boolean isExpandEntityReferences() {
    	return !hasProperty("entities");
    }

    /**
     *   Indicates whether the implementation ignores 
     *       element content whitespace. 
     *   @return true if ignoring element content whitespace
     */
    public boolean isIgnoringElementContentWhitespace() {
    	return !hasProperty("element-content-whitespace");
    }

    /**
     *   Indicates whether the implementation is namespace aware. 
     *   @return true if namespace aware
     */
    public boolean isNamespaceAware() {
    	return hasProperty("namespaces");
    }

    /**
     *   Indicates whether the implementation is validating. 
     *   @return true if validating
     */
    public boolean isValidating() {
    	return hasProperty("validate");
    }
    

}
