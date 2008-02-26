package br.com.stimuli.loading.lazyloaders{
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.*;
    import br.com.stimuli.loading.lazyloaders.*;
    import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.media.Sound;
	import flash.utils.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.media.SoundLoaderContext;

/**
*       @example Basic usage:<listing version="3.0">   
    var lazy : LazyXMLLoader = new LazyXMLLoader("sample-lazy.xml");
    lazy.addEventListener(Event.COMPLETE, onLazyLoaded);
    lazy.addEventListener(ProgressEvent.PROGRESS, onLazyProgress);
    lazy.start();

    var bulkLoader : BulkLoader;
    function onLazyLoaded(evt : Event) : void{
        bulkLoader = evt.target.bulkLoader;
        bulkLoader.addEventListener(BulkLoader.COMPLETE, onAllLoaded);
        bulkLoader.addEventListener(BulkLoader.PROGRESS, onLazyProgress);
        bulkLoader.start();
    }
    </listing>
    */
    dynamic public class LazyXMLLoader extends LazyBulkLoader {
        /*use lazy_loader*/
    	function LazyXMLLoader(url : *){
    		super (url)
    	}
    
        /** Reads a xml as a string and create a complete bulk loader from it.
        *   @param withData The xml to be read as a string.
        *   @return The <code>BulkLoader</code> instance to be used
        */
    	lazy_loader override function _lazyCreateLoader(withData : String) : BulkLoader{
    	    var xml : XML = new XML(withData);
    	    var name : String = String(xml.name);
    	    var logLevel : int = Boolean(String(xml.logLevel)) ? int(xml.logLevel) : BulkLoader.LOG_ERRORS;
    	    var numConnections : int = Boolean(String(xml.numConnections)) ? int(xml.numConnections) : BulkLoader.DEFAULT_NUM_CONNECTIONS;
    		lazy_loader::_bulkLoader._name = name;
    		lazy_loader::_bulkLoader._numConnections = numConnections;
    		lazy_loader::_bulkLoader.logLevel = logLevel;
    		
    		var substitutions : Object = {};
    		for each (var substitutionXML: *in xml.stringSubstitutions.children()){
    		  substitutions[substitutionXML.name()] = substitutionXML.toString();
    		}
    		lazy_loader::_bulkLoader.stringSubstitutions = substitutions;
    		lazy_loader::_bulkLoader.allowsAutoIDFromFileName = lazy_loader::toBoolean(xml.allowsAutoIDFromFileName);
    		var possibleHandlerName : String;
    		var theNode : XMLList;
    		var hasNode : Boolean
    		for each (var itemNode:XML in xml.files.children()) {
    			var props : Object = {};
    			var atts : XMLList = itemNode.@*;
    			var nodeName : String;
    			var headers : Array;
    			var header : URLRequestHeader;
    			var headerName : String;
    			var headerValue : String;
    			if (!String(itemNode.url)) {
    				trace("[LazyBulkLoader] got a item files with no url, ignoring");
    				continue;
    			}
    			//trace(String(itemNode.url));
    			for each (var configNode:XML in itemNode.children()) {
    				nodeName = configNode.name();
    				if (nodeName == "headers") {
    					headers = [];
    					for each (var headerNode:XML in configNode.children()) {
    						headerName = String(headerNode.name());
    						headerValue = String(headerNode[0]) ;
    						header = new URLRequestHeader( headerName, headerValue);
    						headers.push(header);
    					}
    					props["headers"] = headers;

    				} else if (nodeName == "context") {
    					// todo: catch for sound items
    					var context : Object;
    					if (BulkLoader.guessType(String(itemNode.url)) == BulkLoader.TYPE_SOUND) {
    						context = new SoundLoaderContext();
    					} else {
    						context = new LoaderContext();
    					}
    					context.applicationDomain = ApplicationDomain.currentDomain;
    					props[BulkLoader.CONTEXT] = context;

    				} else if (lazy_loader::INT_TYPES.indexOf(nodeName) > -1) {
    					props[nodeName] = int(String(configNode));
    					//trace("(is int)");
    				} else if (lazy_loader::NUMBER_TYPES.indexOf(nodeName) > -1) {
    					props[nodeName] = Number(String(configNode));
    					//trace("(is number)");
    				} else if (lazy_loader::STRINGED_BOOLEAN.indexOf(nodeName) > -1) {
    					props[nodeName] = lazy_loader::toBoolean(String(configNode));
    					//trace("(is boolean)");
    				} else if (nodeName != "url") {
    					props[nodeName] = String(configNode);
    				}
    			}


/*              for (var p:String in props) {
                    trace('\t' + p + ": " + props[p]);
                }*/
    			var theItem : LoadingItem = lazy_loader::_bulkLoader.add(String(String(itemNode.url)), props);
                // check for event handlers on that node:
                for each(possibleHandlerName in lazy_loader::possibleHandlers){
        		    theNode = itemNode[possibleHandlerName];
        		    nodeName = String(theNode);
        		    hasNode = Boolean(nodeName);
        		    if (hasNode && this[nodeName] is Function){
        		        theItem.addEventListener(possibleHandlerName, this[nodeName]);
        		    }
        		}

    		}
    		
    		for each(possibleHandlerName in lazy_loader::possibleHandlers){
    		    theNode = xml[possibleHandlerName];
    		    nodeName = String(theNode);
    		    hasNode = Boolean(nodeName);
    		    if (hasNode && this[nodeName] is Function){
    		        lazy_loader::_bulkLoader.addEventListener(possibleHandlerName, this[nodeName]);
    		    }
    		}
    		return lazy_loader::_bulkLoader;
    	}
    }
}

