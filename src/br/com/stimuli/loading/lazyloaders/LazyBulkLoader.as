
package br.com.stimuli.loading.lazyloaders{

	import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.media.Sound;
	import flash.utils.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.media.SoundLoaderContext;
    import br.com.stimuli.loading.BulkLoader;
	
    /**
     *  Dispatched when the external file representing this serialized bulk loader intance has been downloaded and parse. At
     *  this point the user can get references to all <code>items</code> and attach events to them accordingly.
     *
     *  @eventType br.com.stimuli.loading.BulkProgressEvent.PROGRESS
     */
    [Event(name="lazyComplete", type="flash.events.Event")]
    /** A serialized version of af BulkLoader instance. This class allows you to keep external  files with a complete description of what loading items should be loaded. This class is not meant to be used directly, but used as a base classes for specific data transports (xml, json).
    *   
    */
	public class LazyBulkLoader extends BulkLoader {
	    namespace lazy_loader = "http://code.google.com/p/bulk-loader/"
		lazy_loader var _lazyTheURL : URLRequest;
		/** @private */
		lazy_loader var _lazyLoader : URLLoader;
		/** @private */
		lazy_loader static  const INT_TYPES : Array = ["maxTries", "priority"];
		/** @private */
		lazy_loader static  const NUMBER_TYPES : Array = ["weigth"];
		/** @private */
		lazy_loader static  const STRINGED_BOOLEAN : Array = ["preventCache", "pausedAtStart", "checkPolicyFile"];
        
        public static const LAZY_COMPLETE : String = "lazyComplete";
		public function LazyBulkLoader(url : *, name : String, numConnections : int = BulkLoader.DEFAULT_NUM_CONNECTIONS, logLevel : int = BulkLoader.DEFAULT_LOG_LEVEL){
			if (url is String) {
				lazy_loader::_lazyTheURL = new URLRequest(url);
			}
			lazy_loader::_lazyTheURL = (lazy_loader::_lazyTheURL as URLRequest) || url;
			super(name, numConnections, logLevel);
		}
        
        /** Starts to fetch the external data that will define a BulkLoader instance when parsed. When the fetch operation
        *   is done and the item is correctly parsed, it will dispatch an event with name <code>LAZY_COMPLETE</code>.
        */
		override public function start(numConnections : int = -1):void {
		    if (numConnections > 0){
		        this._numConnections = numConnections;
		    }
			lazy_loader::_lazyLoader = new URLLoader(lazy_loader::_lazyTheURL);
			lazy_loader::_lazyLoader.addEventListener(Event.COMPLETE, lazy_loader::_lazyOnComplete, false, 0, true);
		}

        /** @private */
		lazy_loader function _lazyOnComplete(evt : Event):void {
            lazy_loader::_lazyParseLoader(evt.target.data);
            dispatchEvent(new Event(LAZY_COMPLETE));
            super.start();
		}
		
		/** Useful subclasses should implement this method for a specific seralization method. The <BulkLoader>.start method will be called right after
		* the serialized data is parsed.
		* @param withData   A <code>String</code> to be turned into a <code>BulkLoader</code> instance.
		* @private
		*/
		lazy_loader function _lazyParseLoader(withData : String) : void{
		    throw new Error("subclasses should implement a useful method for this");
		}
		/** @private */
		lazy_loader static function toBoolean(value : String):Boolean {
			if (value == "true" || value == "1" || value == "yes") {
				return true;
			}
			return false;
		}

		override public function toString():String {
			return "[LazyBulkLoader] url: " + lazy_loader::_lazyTheURL.url + ", bulkloader: " + super.toString();
		}
		
		/* ,
		"headers": 
		[
			{"header1": "value1"},
			{"header2": "value2"}
		]
		*/
	}
}