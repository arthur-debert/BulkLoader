/* BulkLoader: manage multiple loadings in Actioncript 3.
*   
*   
*   @author Arthur Debert
*   @version 0.4
*/

/*
* Licensed under the MIT License
* 
* Copyright (c) 2006-2007 Arthur Debert
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
* http://code.google.com/p/bulk-loader/
* http://www.opensource.org/licenses/mit-license.php
*    
*/package br.com.stimuli.loading {
    
    import flash.events.*;
    import flash.net.*;
    import flash.display.*;
    import flash.media.Sound;
    import flash.utils.*;
    
    import br.com.stimuli.loading.LoadingItem;
    import br.com.stimuli.loading.BulkProgressEvent;
    
    /*
    *   Manages loading for simultaneous items and multople formats.
    *   Exposes a simpler interface, with callbacks instead of events for each item to be loaded (but still dispatched "global" events).
    *   The number of simultaneous connections is settable.
    *   @langversion ActionScript 3.0
    *   @playerversion Flash 9.0
    *
    *   @author Arthur Debert
    *   @since  15.09.2007
    */  
    public class BulkLoader extends EventDispatcher {
        public static const ITEM_LOADED : String = "onItemLoaded";
        public static const TYPE_LOADER : String = "loader";
        public static const TYPE_SOUND : String = "sound";
        public static const TYPE_TEXT : String = "text";
        public static const TYPE_XML : String = "xml";
        public static const TYPE_VIDEO : String = "video";
        
        public static var TYPES : Array = ["swf", "jpg", "jpeg", "gif", "png", "flv", "mp3", "xml", "txt", "js", "image" ];
        
        public static var LOADER_TYPES : Array = ["swf", "jpg", "jpeg", "gif", "png" , "image"];
        public static var TEXT_TYPES : Array = ["txt", "js", "xml", "php", "asp" ];
        public static var VIDEO_TYPES : Array = ["flv"];
        public static var SOUND_TYPES : Array = ["mp3"];
        public static var XML_TYPES : Array = ["xml"];
        
        /* The name of the event */
		public static const PROGRESS : String = "progress";
		public static const COMPLETE : String = "complete";
		
        private var _name : String;
        
        private var _items : Array = [];
        private var _contents : Dictionary = new Dictionary();
        private static var allLoaders : Object = {};
        
        // Maximum number of simultaneous open requests
        private var _numConnectons : int = 7;
        private var _connections : Array;
        
        // progress indicators
        public var loadedRatio : Number = 0;
        public var itemsTotal : int = 0;
        public var itemsLoaded : int = 0;
        public var totalWeight : int = 0;
        public var bytesTotal : int = 0;
        public var bytesTotalCurrent : int = 0;
        public var bytesLoaded : int = 0;
        public var percentLoaded : Number = 0;
        public var weightPercent : Number;
        
        /*The average latency (in miliseconds) for the entire loading.*/
        public var avgLatency : Number;
        /*The average speed (in kb/s) for the entire loading.*/
        public var speedAvg : Number;
        private var speedTotal : Number;
        private var startTime : int ;
        private var endTime : int;
        /*Time in seconds for the whole loading. Only available after everything is laoded*/
        public var totalTime : Number;
        
        private var hasStarted : Boolean;
        /* Outputs everything that is happening */
        public static const LOG_VERBOSE : int = 0;
        /*Ouputs noteworthy events such as when an item is finished loading.*/
        public static const LOG_INFO : int = 2;
        /*Will only trace errors. Defaut level*/
        public static const LOG_ERRORS : int = 3;
        /*The logging level <code>BulkLoader</code> will use.*/
        private static var logLevel: int = 3;
        

        /* Creates a new BulkLoader object identifiable by the <code>name</code> parameter. The <code>name</code> parameter must be unique, else an Error will be thrown.
        *   
        *   @param  name            String      A name that can be used later to reference this loader in a static context,
        *   @param  numConnectons   int         [optional] The number of maximum simultaneous connections to be open.
        *   @param  logLevel        int         At which level should traces be outputed. Defaults that only errors will be traced.
        */
        public function BulkLoader(theName : String, numConnectons : int = 7, logLevel : int = 3){
            if (Boolean(allLoaders[theName])){
                throw new Error ("BulkLoader with name'" + theName +"' has already been created.");
            }
            allLoaders[theName] = this;
            this._numConnectons = numConnectons;
            BulkLoader.logLevel = logLevel;
            _name = theName;
        }
        
        /* Fetched a loader object created with the <code>name</code> parameter.
        *   This is usefull if you must access loades assets from another scope, without having to pass direct references to this loader.
        *   @param  name            String      The name of the loader to be fetched.
        *   @return BulkLoader      The BulkLoader instance that was registred with that name. Returns null if none is found.
        */
        public static function getLoader(name :String) : BulkLoader{
            return BulkLoader.allLoaders[name] as BulkLoader;
        }
        
        
        private function hasItemInBulkLoader(key : *, atLoader : BulkLoader) : Boolean{
            var item : LoadingItem = getItem(key);
            if (item &&item.isLoaded) {
                return true;
            }
            return false;
        }
        
        
        /* Checks if there is <b>loaded</b> item in this <code>BulkLoader</code>.
        * @param    key         String or URLRequest      The url request object, a url as a string or an id by which the item is identifiable.
        * @param    searchAll   Boolean                     If true will search through all BulkLoader instances. Else will only search this one.
        * @return   Boolean                                 True if a loader has a <b>loaded</b> item stored.
        */
        public function hasItemWithID(id : String, searchAll : Boolean = true) : Boolean{
            var loaders : *;
            if (searchAll){
              loaders = allLoaders;
            }else{
                loaders = [this];
            }
            for each (var l : BulkLoader in allLoaders){
                if (hasItemInBulkLoader(id, l )) return true;
            }
            return false;
        }
        /* Adds a new assets to be loaded. The <code>BulkLoader</code> object will manage diferent assets type. If the right type can be infered from the url termination (e.g. the url ends with something.swf) the BulkLoader will relly on the <code>type</code> property of the <code>props</code> parameter. If both are set, the url will overrite the one defined in the <code>type</code> properti of the props object. In case none is specified and the url won't hint at it, the type <code>TYPE_TEXT</code> will be used.
        *   
        *   @param url      String OR URLRequest A string or a <code>URLRequest</code> instance.
        *   @param props    An object specifing extra data for this loader. See the <code>LoadingItem</code> special props.
        */
        public function add(url : *, props : Object= null ) : void {
            if(hasStarted){
                log("Cannot add url", url, "bacuse the loader has already started");
            }
            props = props || {};
            if (url is String){
                url = new URLRequest(url);
            }else if (!url is URLRequest){
                throw new Error("[BulkLoader] cannot add object with bad type for url:'" + url.url);
            }
            var item : LoadingItem = getItem(url);
            // have already loaded this?
            if( item ){
                // yes, find out at what stage we are, and call the needed callbacks
                if (props.onStart && item.status == LoadingItem.STATUS_STARTED){
                    try{
                         props.onStart();
                     }catch(e : Error){
                         log("onStart for url ", item.url, " threw an error:", e.getStackTrace() ,3);
                     }
                    
                }
                if (props.onError && item.status == LoadingItem.STATUS_ERROR){
                    try{
                         props.onError();
                     }catch(e : Error){
                         log("onError for url ", item.url, " threw an error:", e.getStackTrace() ,3);
                     }
                    
                }else if (props.onComplete && item.isLoaded){
                    try{
                         props.onComplete();
                     }catch(e : Error){
                         log("onComplete for url ", item.url, " threw an error:", e.getStackTrace() ,3);
                     }
                }
                return;
            }
            
            item  = new LoadingItem(url, props["type"]);
            log("Added",item, 0);
            item.onStart = props.onStart;
            item.onComplete = props.onComplete;
            item.onError = props.onError;
            item.preventCache = props.preventCache;
            item.id = props.id;
            item.priority = int(props.priority) || 0;
            item.addedTime = getTimer();
            item.maxTries = props.maxTries || 3;
            item.weight = int(props.weight) || 1;
            item.addEventListener(Event.COMPLETE, onItemComplete, false, 0, true);
            item.addEventListener(IOErrorEvent.IO_ERROR, onItemError, false, 0, true);
            item.addEventListener(Event.OPEN, onItemStarted, false, 0, true);
            item.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
            _items.push(item);
            itemsTotal += 1;
            totalWeight += item.weight;
            _items.sortOn(["priority", "addedTime"],  [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC]);
        }
        
        /* Start loading all items added previously
        *   @param  withConnections int     [optional]The maximum number of connections to make at the same time.
        */   
        public function start(withConnections : int = -1 ) : void{
            startTime = getTimer();
            if (withConnections  > 0){
                _numConnectons = withConnections;
            }
            _connections = new Array(Math.min(_numConnectons, _items.length));
            var max : int = Math.max(_numConnectons, _items.length);
            for (var i:int = 0; i< _connections.length; i++){
              _connections[i] = _items[i];
              log("Will load", _items[i], 0);
              _items[i].load();
            }
            hasStarted = true;
        }
        
        /*  Register a new file extension to be loaded as a given type. This is used both in the guessing of types from the url and affects how loading is done for each type.
        *   @param  extension   String  The file extension to be used (can include the dot or not)
        *   @param  atType      String  Wich type this extension will be associated with. Possible values" <code>TYPE_LOADER, TYPE_VIDEO, TYPE_SOUND, TYPE_TEXT</code>"
        */
        public static function registerNewType( extension : String, atType : String) : void {
          if (extension.charAt(0) == ".") extension = extension.substring(1);
          var objects : Array ;
          var options : Object = {
              TYPE_LOADER   : LOADER_TYPES,
              TYPE_VIDEO    : VIDEO_TYPES,
              TYPE_SOUND    : SOUND_TYPES,
              TYPE_TEXT     : TEXT_TYPES
          };
          objects = options[atType];
          if (objects && objects.indexOf(extension) == -1){
              objects.push(extension);
          }
        }
        
        private function loadNext(toLoad : LoadingItem = null) : Boolean{
            var next : Boolean = false;
            if (!toLoad){
                for each (var checkItem:LoadingItem in _items){
                   if (!checkItem.isLoading){
                       toLoad = checkItem;
                       break;
                   }
                }
            }
            //dispatchEvent(new Event(ITEM_LOADED));
            if (toLoad){
                toLoad.load();
                _connections.push(toLoad);
                next = true;
            }
            return next;
        }
        
        private function onItemComplete(evt : Event) : void {
           var item : LoadingItem  = evt.target as LoadingItem;
           removeFromConnections(item);
           log("Loaded ", item, 1);
           if(Boolean(item.onComplete) ) {
              try{
                 item.onComplete();
             }catch(e : Error){
                 log("onComplete for url ", item.url, " threw an error:", e.getStackTrace() ,3);
             }
            } 
            item.cleanListeners();
            _contents[item.url] = item.content;
            
            var next : Boolean= loadNext();

           var allDone : Boolean = true;
           for each (item in _items){
                if (!item.isLoaded) {
                    allDone = false;
                    break;
                }
           }
           itemsLoaded ++;
           if(allDone) {
               // trigger the last progress event:
               var e : BulkProgressEvent = new BulkProgressEvent(PROGRESS);
                e.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
                dispatchEvent(e);
               onAllLoaded();
            }

        }
        
        private function updateStats() : void {
          avgLatency = 0;
          speedAvg = 0;
          var totalLatency : Number = 0;
          var totalBytes : int = 0;
          speedTotal = 0;
          var num : int = 0;
          for each(var item : LoadingItem in _items){
              if (item.isLoaded && item.status != LoadingItem.STATUS_ERROR){
                  totalLatency += item.latency;
                  totalBytes += item.bytesTotal;
                  num ++;
              }
          }
          speedTotal = (totalBytes/1024) / totalTime;
          avgLatency = totalLatency / num;
          speedAvg = speedTotal / num;
        }
        
        private function removeFromConnections(item : *) : void{
           _connections.splice(_connections.indexOf(item), 1); 
        }
        
        private function onItemError(evt : IOErrorEvent) : void{
            var item : LoadingItem  = evt.target as LoadingItem;
           if(Boolean(item.onError))  {
               try{
                   item.onError();
              }catch(e : Error){
                  log("onError for url ", item.url, " threw an error!", e.getStackTrace(), 3);
              }
           }
           log("Error loading", item, 3);
           if(item.numTries < item.maxTries){
               item.status = null;
               item.load();
           }else{
               log("After " + item.numTries + " I am giving up on " + item.url, 3);
               removeFromConnections(item);
           }
        }
        
        private function onItemStarted(evt : Event) : void{
            var item : LoadingItem  = evt.target as LoadingItem;
            log("Started loading", item, 1);
           if(Boolean(item.onStart)) {
               try{
                  item.onStart();
              }catch(e : Error){
                  log("onStart for url ", item.url, " threw an error!", e.getStackTrace(), 3);
              }
           }
        }
        
        private function onProgress(evt : Event) : void{
            bytesLoaded = bytesTotal = bytesTotalCurrent = 0;
            weightPercent = 0;
            itemsLoaded = 0;
            var itemsStarted : int = 0;
            var weightLoaded : Number = 0;
            for each (var item:LoadingItem in _items){
              if (item.status == LoadingItem.STATUS_STARTED || item.status == LoadingItem.STATUS_FINISHED){
                  bytesLoaded += item.bytesLoaded;
                  bytesTotalCurrent += item.bytesTotal;
                  weightLoaded += (item.bytesLoaded / item.bytesTotal) * item.weight;
                  if(item.status == LoadingItem.STATUS_FINISHED) {
                      itemsLoaded ++;
                  }
                  itemsStarted ++;
              }

            }

            
            if (itemsStarted == _items.length){
                bytesTotal = bytesTotalCurrent;
            }
            weightPercent = weightLoaded / totalWeight;
            var e : BulkProgressEvent = new BulkProgressEvent(PROGRESS);
            e.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
            dispatchEvent(e);
        }
        
        /* =================================================================== */
        /* = Information acess                                               = */
        /* =================================================================== */
        
        /* The number of simultaneous connections to use.
        *   @return  int     The number of connections used.
        */
        public function get numConnectons() : int { 
            return _numConnectons; 
        }
        /* Returns an object where the urls are the keys and the loaded contents are the value for that key.
        *  Each value is typed as * an the client must check for the right typing.
        */
        public function get contents() : Object { 
          return _contents; 
        }
        
        public function get name() : String { 
            return _name; 
        }
        
        /* ============================================================================== */
        /* = Acessing content function                                                  = */
        /* ============================================================================== */
        
        /* Helper functions to get loaded content. All helpers will be casted to the specific types. If a cast fails it will throw an error.
        *   
        */
        private function getContentAsType(key : *, type : Class,  clearMemory : Boolean = false) : *{
            var item : LoadingItem = getItem(key);
            if(!item){
                return null;
            }
            try{
                if (item.isLoaded) {
                    var res : * = type(item.content)
                    if(clearMemory){
                        clearItem(key);
                    }
                    return res;
                }
            }catch(e : Error){
                log("Failed to get content with url: '"+ key + "'as type:", type, 3);
            }
            
            return null;
        }
        
        /* Returns an untyped object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest     The url request, url as a string or a id  from which the asset was loaded.
        *   @param  clearMemory  Boolean    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns            Untyped     The content retrived from that url
        */
        public function getContent(key : String, clearMemory : Boolean = false) : *{
            return getContentAsType(key,  Object,  clearMemory);
        }
        
        /* Returns an XML object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest     The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns            XML         The content retrived from that url casted to a XML object. Returns null if the cast fails.
        */
        public function getXML(key : *, clearMemory : Boolean = false) : XML{
            return XML(getContentAsType(key, XML,  clearMemory));
        }
        
        /* Returns a String object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest     The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns             String     The content retrived from that url casted to a String object. Returns null if the cast fails.
        */
        public function getText(key : *, clearMemory : Boolean = false) : String{
            return String(getContentAsType(key, String, clearMemory));
        }
        
        /* Returns a Sound object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest     The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns             Sound      The content retrived from that url casted to a Sound object. Returns null if the cast fails.
        */
        public function getSound(key : *, clearMemory : Boolean = false) : Sound{
            return Sound(getContentAsType(key, Sound,clearMemory));
        }
        
        /* Returns a Bitmap object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest       The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean                    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns             Bitmap                     The content retrived from that url casted to a Bitmap object. Returns null if the cast fails.
        */
        public function getBitmap(key : String, clearMemory : Boolean = false) : Bitmap{
            return Bitmap(getContentAsType(key, Bitmap, clearMemory));
        }
        
        /* Returns a Bitmap object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest       The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean                    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns             MovieClip                  The content retrived from that url casted to a MovieClip object. Returns null if the cast fails.
        */
        public function getMovieClip(key : String, clearMemory : Boolean = false) : MovieClip{
            return MovieClip(getContentAsType(key, MovieClip, clearMemory));
        }
        
        /* Returns an BitmapData object with the downloaded asset for the url.
        *   @param  key          String OR URLRequest       The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails. Does not clone the original bitmap data from the bitmap asset.
        *   @param  clearMemory  Boolean                    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @returns             BitmapData                 The content retrived from that url casted to a BitmapData object. Returns null if the cast fails.
        */
        public function getBitmapData(key : *,  clearMemory : Boolean = false) : BitmapData{
            try{
                return getBitmap(key,  clearMemory).bitmapData;
            }catch (e : Error){
                log("Failed to get bitmapData with url:", key);
            }
            return  null;
        }
        
        public function getSerializedData(key : *, encodingFunction : Function, clearMemory : Boolean = false) : *{
            try{
                var raw : * = getContentAsType(key, Object, clearMemory);
                var parsed : * = encodingFunction.apply(null, raw);
                return parsed;
            }catch (e : Error){
                log("Failed to parse key:", key, "with encodingFunction:" + encodingFunction);
            }
            return null;
        }
        
        private function onAllLoaded() : void {
            log("Finished all", 1);
            endTime = getTimer();
            totalTime = BulkLoader.truncateNumber((endTime - startTime) /1000);
            updateStats();
            _connections = null;
            traceStats();
            var e : BulkProgressEvent = new BulkProgressEvent(COMPLETE);
            e.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
            dispatchEvent(e);
        }
        
        public function traceStats() : void{
            //if(logLevel > 2) return;
            var stats : Array = [];
            stats.push("\n************************************");
            stats.push("All items loaded(" + itemsTotal + ")");
            stats.push("Total time(s): " + totalTime);
            stats.push("Average latency(s): " + int(avgLatency *1000));
            stats.push("Average speed(kb/s): " + truncateNumber(speedAvg));
            stats.push("Median speed(kb/s): " + truncateNumber(speedTotal));
            stats.push("KiloBytes total:" + truncateNumber(bytesTotal/1024));
            stats.push("");
            for each (var item:LoadingItem in _items){
                if (item.isLoaded){
                    stats.push("\t- Item url:" + item.url.url + 
                    ", total time: " + item.timeToDownload +
                    ", latency:" + item.latency +
                    ", speed: " +item.speed + 
                    ", kbs total: " + truncateNumber(item.bytesTotal/1024))
                }
            }
            stats.push("************************************");
            log(stats.join("\n"), 1);
        }
        
        protected static function log(...msg) : void{
            var level : int  = isNaN(msg[msg.length -1] ) ? 3 : int(msg.pop());
            if (level >= logLevel ){
                trace("[BulkLoader]", msg.join(" "));
            }
        }
        
        public function getItem(key : *) : LoadingItem{
            for each (var item : LoadingItem in _items){
                if(item.id == key || item.url.url == key || item.url == key  ){
                    return item;
                }
            }
            return null;
        }
        
        public function clearItem(key : *) : Boolean{
            
            var item : LoadingItem;
            if (item is LoadingItem){
                item = item;
            } else{
                item = getItem(key);
            }
            if(!item) {
                return false;
            }
            var itemIndex : int = _items.indexOf(item);
            if(itemIndex){
                _items.splice( itemIndex,1);
                item.destroy();
            } 
            item = null;
            return true;
        }
        
        public function clearAll() : void{
            for each (var item : LoadingItem in _items){
                clearItem(item);
            }
            delete allLoaders[name];
        }
        
        public static function clearAllLoaders() : void{
            for each (var atLoader : BulkLoader in allLoaders){
                atLoader.clearAll();
                delete allLoaders[atLoader.name];
                atLoader = null;
            }
            allLoaders = null;
        }
        
        public function stopItem(key : *,  loadsNext : Boolean = false) : Boolean{
            var item : LoadingItem = getItem(key);
            if(!item) {
                return false;
            }
            item.stop();
            removeFromConnections(item);
            if(loadsNext){
                loadNext();
            }
            return true;
        }
        
        public  function stopAllItems() : void{
            for each(var item : LoadingItem in _items){
                stopItem(item);
            }
        }
        
        public static function stopAllLoaders() : void{
            for each (var atLoader in allLoaders){
                atLoader.stopAllItems();
            }
        }
        
        public function resume(key : *) : void{
            var item : LoadingItem = getItem(key);
            loadNext(item);
        }
        /* Utility function to truncate a number to the given number of decimal places.
        *   @description 
        *   Number is truncated using the <code>Math.round</code> function.
        *   
        *   @param  raw         Number  The number to truncate
        *   @param  decimals    int     The number of decimals place to preserve.
        *   @return             Number  The truncated number.
        */
        public static function truncateNumber(raw : Number, decimals :int =2) : Number {
            var power : int = Math.pow(10, decimals);
           return Math.round(raw * ( power )) / power;
        }
        
        override public function toString() : String{
            return "[BulkLoader] itemsTotal: " + itemsTotal + ", itemsLoaded: " + itemsLoaded; 
        }
    }
    
}