
package br.com.stimuli.loading{

	import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.media.Sound;
	import flash.utils.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.media.SoundLoaderContext;

	
    
    /** A serialized version of af BulkLoader instance. This class allows you to keep external  files with a complete description of what loading items should be loaded. This class is not meant to be used directly, but used as a base classes for specific data transports (xml, json).
    *   @private
    */
	public class LazyBulkLoader extends EventDispatcher {
		protected var theURL : URLRequest;
		protected var loader : URLLoader;
		protected var _bulkLoader : BulkLoader;
		internal static  const INT_TYPES : Array = ["maxTries", "priority"];
		internal static  const NUMBER_TYPES : Array = ["weigth"];
		internal static  const STRINGED_BOOLEAN : Array = ["preventCache", "pausedAtStart"];
        public var possibleHandlers : Array = [BulkLoader.COMPLETE, BulkLoader.PROGRESS, BulkLoader.ERROR, BulkLoader.OPEN];
		public function LazyBulkLoader(url : *) {
			if (url is String) {
				theURL = new URLRequest(url);
			}
			theURL = (theURL as URLRequest) || url;
		}

		public function start():void {
			loader = new URLLoader(theURL);
			loader.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
		}

		public function onProgress(evt : ProgressEvent):void {
			dispatchEvent(evt);
		}

        
		public function onComplete(evt : Event):void {
            _bulkLoader = createLoader(evt.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/** Useful subclasses should implement this method for a specific seralization method. 
		* @param withData   A <code>String</code> to be turned into a <code>BulkLoader</code> instance.
		* @return A <code>BulkLoader</code> instance created from the the serialized content.
		*/
		public function createLoader(withData : String) : BulkLoader{
		    throw new Error("subclasses should implement a useful method for this");
		    return new BulkLoader("bad");
		}
		internal static function toBoolean(value : String):Boolean {
			if (value == "true" || value == "1" || value == "yes") {
				return true;
			}
			return false;
		}
		public function get bulkLoader():BulkLoader {
			return _bulkLoader;
		}

		override public function toString():String {
			return "[LazyBulkLoader] url: " + theURL.url;
		}
	}
}