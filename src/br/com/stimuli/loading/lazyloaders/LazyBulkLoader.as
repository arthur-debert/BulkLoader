
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
	
    
    /** A serialized version of af BulkLoader instance. This class allows you to keep external  files with a complete description of what loading items should be loaded. This class is not meant to be used directly, but used as a base classes for specific data transports (xml, json).
    *   @private
    */
	dynamic public class LazyBulkLoader extends Proxy {
	    namespace lazy_loader = "http://www.stimuli.com.br/projects/bulkloader/"
		lazy_loader var _lazyTheURL : URLRequest;
		lazy_loader var _lazyLoader : URLLoader;
		lazy_loader var _bulkLoader : BulkLoader;
		lazy_loader static  const INT_TYPES : Array = ["maxTries", "priority"];
		lazy_loader static  const NUMBER_TYPES : Array = ["weigth"];
		lazy_loader static  const STRINGED_BOOLEAN : Array = ["preventCache", "pausedAtStart", "checkPolicyFile"];
        lazy_loader var possibleHandlers : Array = [BulkLoader.COMPLETE, BulkLoader.PROGRESS, BulkLoader.ERROR, BulkLoader.OPEN];
        
		public function LazyBulkLoader(url : *) {
			if (url is String) {
				lazy_loader::_lazyTheURL = new URLRequest(url);
			}
			lazy_loader::_lazyTheURL = (lazy_loader::_lazyTheURL as URLRequest) || url;
			lazy_loader::_lazyStart();
			
			lazy_loader::_bulkLoader = BulkLoader.createUniqueNamedLoader();
		}
        
        flash_proxy override function callProperty(propName : *, ...rest) : *{
            if (!lazy_loader::_bulkLoader){
                trace("[LazyBulkLoader] Error: called method " , propName, " but bulkloader isn't loaded yet.")
            }
            var func : Function = lazy_loader::_bulkLoader[propName] as Function;
            if (Boolean(func)){
                return func.apply(lazy_loader::_bulkLoader, rest);
            }
        }
        
        flash_proxy override function getProperty(propName : *) : *{
            if (!lazy_loader::_bulkLoader){
                trace("[LazyBulkLoader] Error: called getProperty " , propName, " but bulkloader isn't loaded yet.")
            }
            return lazy_loader::_bulkLoader[propName];
        }
        
        flash_proxy override function setProperty(propName : *, value : *) : void{
            if (!lazy_loader::_bulkLoader){
                trace("[LazyBulkLoader] Error: called setProperty " , propName, " but bulkloader isn't loaded yet.")
            }
            lazy_loader::_bulkLoader[propName] = value;
        }
        
		lazy_loader  function _lazyStart():void {
			lazy_loader::_lazyLoader = new URLLoader(lazy_loader::_lazyTheURL);
			lazy_loader::_lazyLoader.addEventListener(Event.COMPLETE, lazy_loader::_lazyOnComplete, false, 0, true);
			lazy_loader::_lazyLoader.addEventListener(ProgressEvent.PROGRESS, lazy_loader::_lazyOnProgress, false, 0, true);
		}

		lazy_loader  function _lazyOnProgress(evt : ProgressEvent):void {
			//dispatchEvent(evt);
		}

        
		lazy_loader  function _lazyOnComplete(evt : Event):void {
            lazy_loader::_lazyCreateLoader(evt.target.data);
            lazy_loader::_bulkLoader.start();
			//dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/** Useful subclasses should implement this method for a specific seralization method. 
		* @param withData   A <code>String</code> to be turned into a <code>BulkLoader</code> instance.
		* @return A <code>BulkLoader</code> instance created from the the serialized content.
		*/
		lazy_loader  function _lazyCreateLoader(withData : String) : BulkLoader{
		    throw new Error("subclasses should implement a useful method for this");
		    return new BulkLoader("bad");
		}

		lazy_loader static function toBoolean(value : String):Boolean {
			if (value == "true" || value == "1" || value == "yes") {
				return true;
			}
			return false;
		}
		

		 public function toString():String {
			return "[LazyBulkLoader] url: " + lazy_loader::_lazyTheURL.url + ", bulkLoader:" + lazy_loader::_bulkLoader;
		}
	}
}