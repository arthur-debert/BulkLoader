package br.com.stimuli.loading{
    import br.com.stimuli.loading.*;
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
    public class LazyXMLLoader extends LazyBulkLoader {
    	function LazyXMLLoader(url : *){
    		super (url)
    	}
    
        /** Reads a xml as a string and create a complete bulk loader from it.
        *   @param withData The xml to be read as a string.
        *   @return The <code>BulkLoader</code> instance to be used
        */
    	override public function createLoader(withData : String) : BulkLoader{
    	    var xml : XML = new XML(withData);
    	    var name : String = String(xml.name);
    	    if (!Boolean(name)){
    	        throw new Error("The serialized BulkLoader in '" + theURL.url + "' needs to define a name")
    	    }
    	    var logLevel : int = Boolean(String(xml.logLevel)) ? int(xml.logLevel) : BulkLoader.LOG_ERRORS;
    	    trace("{LazyXMLLoader}::method() logLevel", logLevel);
    	    var numConnections : int = Boolean(String(xml.numConnections)) ? int(xml.numConnections) : BulkLoader.DEFAULT_NUM_CONNECTIONS;
    		var _bulkLoader : BulkLoader = new BulkLoader(String(xml.name), numConnections, logLevel);
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
    						headerName = String(headerNode.name);
    						headerValue = String(headerNode.value) ;
    						header = new URLRequestHeader( headerName, headerValue);
    						headers.push(header);
    					}
    					props["headers"] = headers;

    				} else if (nodeName == "context") {
    					// todo: catch for sound items
    					var context : Object;
    					if (LoadingItem.guessType(String(itemNode.url)) == BulkLoader.TYPE_SOUND) {
    						context = new SoundLoaderContext();
    					} else {
    						context = new LoaderContext();
    					}
    					context.applicationDomain = ApplicationDomain.currentDomain;
    					props[BulkLoader.CONTEXT] = context;

    				} else if (INT_TYPES.indexOf(nodeName) > -1) {
    					props[nodeName] = int(String(configNode));
    					//trace("(is int)");
    				} else if (NUMBER_TYPES.indexOf(nodeName) > -1) {
    					props[nodeName] = Number(String(configNode));
    					//trace("(is number)");
    				} else if (STRINGED_BOOLEAN.indexOf(nodeName) > -1) {
    					props[nodeName] = toBoolean(String(configNode));
    					//trace("(is boolean)");
    				} else if (nodeName != "url") {
    					props[nodeName] = String(configNode);
    				}
    			}


/*              for (var p:String in props) {
                    trace('\t' + p + ": " + props[p]);
                }*/
    			var theItem : LoadingItem = _bulkLoader.add(String(String(itemNode.url)), props);
                // check for event handlers on that node:
                for each(possibleHandlerName in possibleHandlers){
        		    theNode = itemNode[possibleHandlerName];
        		    nodeName = String(theNode);
        		    hasNode = Boolean(nodeName);
        		    if (hasNode && this[nodeName] is Function){
        		        theItem.addEventListener(possibleHandlerName, this[nodeName]);
        		    }
        		}

    		}
    		
    		for each(possibleHandlerName in possibleHandlers){
    		    theNode = xml[possibleHandlerName];
    		    nodeName = String(theNode);
    		    hasNode = Boolean(nodeName);
    		    if (hasNode && this[nodeName] is Function){
    		        _bulkLoader.addEventListener(possibleHandlerName, this[nodeName]);
    		    }
    		}
    		return _bulkLoader;
    	}
    }
}

