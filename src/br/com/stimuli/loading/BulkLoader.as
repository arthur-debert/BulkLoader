/** BulkLoader: manage multiple loadings in Actioncript 3.
*   
*   
*   @author Arthur Debert
*   @version 0.4
*/

/**
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
*/
package br.com.stimuli.loading {
    
import flash.events.*;
import flash.net.*;
import flash.display.*;
import flash.media.Sound;
import flash.utils.*;

import br.com.stimuli.loading.LoadingItem;
import br.com.stimuli.loading.BulkProgressEvent;
    
/**
 *  Dispatched on download progress by any of the items to download.
 *
 *  @eventType br.com.stimuli.loading.BulkProgressEvent.PROGRESS
 */
[Event(name="progress", type="br.com.stimuli.loading.BulkProgressEvent")]

/**
 *  Dispatched when all items have been downloaded and parsed.
 *
 *  @eventType br.com.stimuli.loading.BulkProgressEvent.COMPLETE
 */
[Event(name="complete", type="br.com.stimuli.loading.BulkProgressEvent")]
    
    /**
    *   Manages loading for simultaneous items and multiple formats.
    *   Exposes a simpler interface, with callbacks instead of events for each item to be loaded (but still dispatched "global" events).
    *   The number of simultaneous connections is configurable.
    *   
    *   @example Basic usage:<listing version=3.0>
    import br.com.stimuli.loading.BulkLoader;

    / /instantiate a BulkLoader with a name : a way to reference this instance from another classes without having to set a expolicit reference on many places
    var bulkLoader : BulkLoader = new BulkLoader("main loading");
    // add items to be loaded
    bulkLoader.add("my_xml_file.xml");
    bulkLoader.add("main.swf");
    // you can also use a URLRequest object
    var backgroundURL : URLRequest = new URLRequest("background.jpg");
    bulkLoader.add(backgroundURL);

    // add event listeners for the loader itself :
    // event fired when all items have been loaded
    bulkLoader.addEventListener(BulkLoader.COMPLETE, onCompleteHandler);
    // event fired when loading progress has been made:
    bulkLoader.addEventListener(BulkLoader.PROGRESS, onProgressHandler);

    // start loading all items
    bulkLoader.start();

    function onProgressHandler(evt : ProgressEvent) : void{
        trace("Loaded" , evt.bytesLoaded," of ",  evt.bytesTotal);
    }

    function onCompleteHandler(evt : ProgressEvent) : void{
            trace("All items are loaeded and ready to consume");
            // grab the main movie clip:
            var mainMovie : MovieClip = bulkLoader.getMovieClip("main.swf");
            // Get the xml object:
            var mXML : XML = bulkLoader.getXML("my_xml_file.xml");
            // grab the bitmap for the background image by a string:
            var myBitmap : Bitmap = bulkLoader.getBitmap("background.jpg");
            // grab the bitmap for the background image using the url rquest object:
            var myBitmap : Bitmap = bulkLoader.getBitmap(backgroundURL);
    }

    // In any other class you can access those assets without having to pass around references to the bulkLoader instance.
    // In another class  you get get a reference to the "main loading" bulkLoader:
    var mainLoader : BulkLoader = BulkLoader.getLoader("main loading");
    // now grab the xml:
    var mXML : XML = mainLoader.getXML("my_xml_file.xml");
    // or shorter:
    var mXML : XML = BulkLoader.getLoader("main loading").getXML("my_xml_file.xml");
    *    </listing>
    *   @langversion ActionScript 3.0
    *   @playerversion Flash 9.0
    *
    *   @author Arthur Debert
    *   @since  15.09.2007
    */  
    
    
    public class BulkLoader extends EventDispatcher {
        
        /** Tells this class to use a <code>Loader</code> object to load the item.*/
        public static const TYPE_IMAGE : String = "loader";
        /** Tells this class to use a <code>Loader</code> object to load the item.*/
        public static const TYPE_SWF : String = "loader";
        /** Tells this class to use a <code>Loader</code> object to load the item.*/
        public static const TYPE_LOADER : String = "loader";
        /** Tells this class to use a <code>Sound</code> object to load the item.*/
        public static const TYPE_SOUND : String = "sound";
        /** Tells this class to use a <code>URLRequest</code> object to load the item.*/
        public static const TYPE_TEXT : String = "text";
        /** Tells this class to use a <code>XML</code> object to load the item.*/
        public static const TYPE_XML : String = "xml";
        /** Tells this class to use a <code>NetStream</code> object to load the item.*/
        public static const TYPE_VIDEO : String = "video";
        
        /** List of all file extensions that the <code>BulkLoader</code> knows how to guess.
        *   Availabe types: swf, jpg, jpeg, gif, png. */
        internal static var AVAILABLE_TYPES : Array = ["swf", "jpg", "jpeg", "gif", "png", "flv", "mp3", "xml", "txt", "js" ];
        /** List of file extensions that will be automagically use a <code>Loader</code> object for loading.
        *   Availabe types: txt, js, xml, php, asp .
        */
        internal static var LOADER_TYPES : Array = ["swf", "jpg", "jpeg", "gif", "png" , "image"];
        /** List of file extensions that will be automagically treated as text for loading.
        *   Availabe types: txt, js, xml, php, asp .
        */
        internal static var TEXT_TYPES : Array = ["txt", "js", "xml", "php", "asp" ];
        /** List of file extensions that will be automagically treated as video for loading. 
        *  Availabe types: flv. 
        */
        internal static var VIDEO_TYPES : Array = ["flv"];
        /** List of file extensions that will be automagically treated as sound for loading.
        *  Availabe types: mp3.
        */
        internal static var SOUND_TYPES : Array = ["mp3"];
        
        private static var XML_TYPES : Array = ["xml"];
        
        /** 
        *   The name of the event 
        *   @eventType progress
        */
		public static const PROGRESS : String = "progress";
		/** 
        *   The name of the event 
        *   @eventType complete
        */
		public static const COMPLETE : String = "complete";
		
		// properties on adding a new url:
		/** A function to be called when an item has started loading. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const ON_START : String = "onStart";
		/** A function to be called if an item has failed loading. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const ON_ERROR : String = "onError";
		/** A function to be called when an item has finished loading and it's content is ready for usage. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const ON_COMPLETE : String = "onComplete";
		/** If <code>true</code> a random query (or post data parameter) will be added to prevent caching. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const PREVENT_CACHING : String = "preventCache";
		/** An array of RequestHeader objects to be used when contructing the <code>URLRequest</code> object. If the <code>url</code> parameter is passed as a <code>URLRequest</code> object it will be ignored. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const HEADERS : String = "headers";
		/** An object definig the loading context for this load operario. If this item is of <code>TYPE_SOUND</code>, a <code>SoundLoaderContext</code> is expected. If it's a <code>TYPE_LOADER</code> a LoaderContext should be passed. Checked when adding a new item to load.
		* @see #add()
		*/
		public static const CONTEXT : String = "context";
		/** A <code>String</code> to be used to identify an item to load, can be used in any method that fetches content (as the key parameters), stops, removes and resume items. Checked when adding a new item to load.
		* @see #add()
		* @see #getContent()
		* @see #pauseItem()
		* @see #resumeItem()
		* @see #removeItem()
		*/
		public static const ID : String = "id";

		/** An <code>int</code> that controls which items are loaded first. Items with a higher <code>PRIORITY</code> will load first. If more than one item has the same <code>PRIORITY</code> number, the order in which they are added will be taken into consideration. Checked when adding a new item to load.
		* @see #add()
		*/
        public static const PRIORITY : String = "priority";
		
		/** The number, as an <code>int</code>, to retry downloading an item in case it fails. Checked when adding a new item to load.
		* @default 3
		* @see #add()
		*/
        public static const MAX_TRIES : String = "maxTries";
		/* An <code>int</code> that sets a relative size of this item. It's used on the <code>BulkProgressEvent.weightPercent</code> property. This allows bulk downloads with more items that connections and with widely varying file sizes to give a more accurate progress information. Checked when adding a new item to load.
		* @see #add()
		* @default 3
		*/
        public static const WEIGHT : String = "weight";
		
		
        
		/**
		* The name by which this loader instance can be identified.
		* This property is used so you can get a reference to this instance from other classes in your code without having to save and pass it yourself, throught the static method BulkLoader.getLoader(name) .<p/>
		* Each name should be unique, as instantiating a BulkLoader with a name already taken will throw an error.
		* @ see getLoaders
		*/
        private var _name : String;
        
        private var _items : Array = [];
        private var _contents : Dictionary = new Dictionary();
        private static var allLoaders : Object = {};
        
        // Maximum number of simultaneous open requests
        private var _numConnectons : int = 7;
        private var _connections : Array;
        
        /** 
        *   The ratio (0->1) of items to load / items total.
        *   This number is always reliable.
        **/
        public var loadedRatio : Number = 0;
        /** Total number of items to load.*/
        public var itemsTotal : int = 0;
        /** 
        *   Number of items alrealdy loaded.
        *   Failed or canceled items are not taken into consideration
        */
        public var itemsLoaded : int = 0;
        /** The sum of weights in all items to load.
        *   Each item's weight default to 1
        */
        public var totalWeight : int = 0;
        /** The total bytes to load.
        *   If the number of items to load is larger than the number of simultaneous connections, bytesTotal will be 0 untill all connections are opened and the number of bytes for all items is known.
        *   @see #bytesTotalCurrent
        */ 
        public var bytesTotal : int = 0;
        /** The sum of all bytes loaded so far. 
        *  If itemsTotal is less than the number of connections, this will be the same as bytesTotal. Else, bytesTotalCurrent will be available as each loading is started.
        *   @see #bytesTotal
        */
        public var bytesTotalCurrent : int = 0;
        /** The sum of all bytesLoaded for each item.
        */
        public var bytesLoaded : int = 0;
        /** The percentage (0->1) of bytes loaded.
        *   Until all connections are opened  this number is not reliable . If you are downloading more items than the number of simultaneous connections, use loadedRatio or weightPercent instead.
        *   @see #loadedRatio
        *   @see #weightPercent
        */   
        public var percentLoaded : Number = 0;
        /** The weighted percent of items loaded(0->1).
        *   This always returns a reliable value.
        */
        public var weightPercent : Number;
        
        /**The average latency (in miliseconds) for the entire loading.*/
        public var avgLatency : Number;
        /**The average speed (in kb/s) for the entire loading.*/
        public var speedAvg : Number;
        private var speedTotal : Number;
        private var startTime : int ;
        private var endTime : int;
        /**Time in seconds for the whole loading. Only available after everything is laoded*/
        public var totalTime : Number;
        
        /** LogLevel: Outputs everything that is happening. Usefull for debugging. */
        public static const LOG_VERBOSE : int = 0;
        /**Ouputs noteworthy events such as when an item is started / finished loading.*/
        public static const LOG_INFO : int = 2;
        /**Will only trace errors. Defaut level*/
        public static const LOG_ERRORS : int = 3;
        /**The logging level <code>BulkLoader</code> will use.*/
        public static var logLevel: int = 3;
        
        public var isRunning : Boolean;
        private var isFinished : Boolean;
        /** Creates a new BulkLoader object identifiable by the <code>name</code> parameter. The <code>name</code> parameter must be unique, else an Error will be thrown.
        *   
        *   @param name  A name that can be used later to reference this loader in a static context,
        *   @param  numConnectons The number of maximum simultaneous connections to be open.
        *   @param  logLevel At which level should traces be outputed. By default only errors will be traced.
        *   
        *   @see #numConnectons
        *   @see #log()
        */
        public function BulkLoader(name : String, numConnectons : int = 7, logLevel : int = 3){
            if (Boolean(allLoaders[name])){
                throw new Error ("BulkLoader with name'" + name +"' has already been created.");
            }
            allLoaders[name] = this;
            this._numConnectons = numConnectons;
            BulkLoader.logLevel = logLevel;
            _name = name;
        }
        
        /** Fetched a loader object created with the <code>name</code> parameter.
        *   This is usefull if you must access loades assets from another scope, without having to pass direct references to this loader.
        *   @param  name The name of the loader to be fetched.
        *   @return The BulkLoader instance that was registred with that name. Returns null if none is found.
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
        
        
        /** Checks if there is <b>loaded</b> item in this <code>BulkLoader</code>.
        * @param    The url (as a <code>String</code> or a <code>URLRequest</code> object)or an id (as a <code>String</code>) by which the item is identifiable.
        * @param    searchAll   If true will search through all <code>BulkLoader</code> instances. Else will only search this one.
        * @return   True if a loader has a <b>loaded</b> item stored.
        */
        public function hasItem(key : *, searchAll : Boolean = true) : Boolean{
            var loaders : *;
            if (searchAll){
              loaders = allLoaders;
            }else{
                loaders = [this];
            }
            for each (var l : BulkLoader in allLoaders){
                if (hasItemInBulkLoader(key, l )) return true;
            }
            return false;
        }
        /** Adds a new assets to be loaded. The <code>BulkLoader</code> object will manage diferent assets type. If the right type cannot be infered from the url termination (e.g. the url ends with ".swf") the BulkLoader will relly on the <code>type</code> property of the <code>props</code> parameter. If both are set, the <code>type</code>  property of the props object will overrite the one defined in the <code>url</code>. In case none is specified and the url won't hint at it, the type <code>TYPE_TEXT</code> will be used.
        *   
        *   @param url String OR URLRequest A <code>String</code> or a <code>URLRequest</code> instance.
        *   @param props An object specifing extra data for this loader. The following properties are supported:<p/>
        *   <table>
        *       <th>Property name</th>
        *       <th>Class constant</th>
        *       <th>Data type</th>
        *       <th>Description</th>
        *       <tr>
        *           <td>onStart</td>
        *           <td><a href="#ON_START">ON_START</a></td>
        *           <td><code>Function</code></td>
        *           <td>A callback to be executed as soon as this item begins loading.</td>
        *       </tr>
        *       <tr>
        *           <td>onComplete</td>
        *           <td><a href="#ON_COMPLETE">ON_COMPLETE</a></td>
        *           <td><code>Function</code></td>
        *           <td>A callback to be executed as the tem is done loading and is ready to use.</td>
        *       </tr>
        *       <tr>
        *           <td>onError</td>
        *           <td><a href="#ON_ERROR">ON_ERROR</a></td>
        *           <td><code>Function</code></td>
        *           <td>A callback to be executed if this item fails to load.</td>
        *       </tr>
        *       <tr>
        *           <td>preventCache</td>
        *           <td><a href="#PREVENT_CACHING">PREVENT_CACHING</a></td>
        *           <td><code>Boolean</code></td>
        *           <td>If <code>true</code> a random query string will be added to the url (or a post param in case of post reuquest).</td>
        *       </tr>
        *       <tr>
        *           <td>id</td>
        *           <td><a href="#ID">ID</a></td>
        *           <td><code>String</code></td>
        *           <td>A string to identify this item. This id can be used in any method that uses the <code>key</code> parameter, such as <code>pauseItem, removeItem, resumeItem, getContent, getBitmap, getBitmapData, getXML, getMovieClip and getText</code>.</td>
        *       </tr>
        *       <tr>
        *           <td>priority</td.
        *           <td><a href="#PRIORITY">PRIORITY</a></td>
        *           <td><code>int</code></td>
        *           <td>An <code>int</code> used to order which items till be downloaded first. Items with a higher priority will download first. For items with the same priority they will be loaded in the same order they've been added.</td>
        *       </tr>
        *       <tr>
        *           <td>maxTries</td.
        *           <td><a href="#MAX_TRIES">MAX_TRIES</a></td>
        *           <td><code>int</code></td>
        *           <td>The number of retries in case the lading fails, defaults to 3.</td>
        *       </tr>
        *       <tr>
        *           <td>weight</td.
        *           <td><a href="#WEIGHT">WEIGHT</a></td>
        *           <td><code>int</code></td>
        *           <td>A number that sets an arbitrary relative size for this item. See #weightPercent.</td>
        *       </tr>
        *       <tr>
        *           <td>headers</td.
        *           <td><a href="#HEADERS">HEADERS</a></td>
        *           <td><code>Array</code></td>
        *           <td>An array of <code>RequestHeader</code> objects to be used when constructing the URL. If the <code>url</code> parameter is passed as a string, <code>BulkLoader</code> will use these request headers to construct the url.</td>
        *       </tr>
        *       <tr>
        *           <td>context</td.
        *           <td><a href="#CONTEXT">CONTEXT</a></td>
        *           <td><code>LoaderContext or SoundLoaderContext</code></td>
        *           <td>An object definig the loading context for this load operario. If this item is of <code>TYPE_SOUND</code>, a <code>SoundLoaderContext</code> is expected. If it's a <code>TYPE_LOADER</code> a LoaderContext should be passed.</td>
        *       </tr>
        *   </table>
        *   @example Retriving contents:<listing version=3.0>
import br.stimuli.loaded.BulkLoader;
var bulkLoader : BulkLoader = new BulkLoader("main");
// simple item:
bulkLoader.add("config.xml");
// use an id that can be retirved latterL
bulkLoader.add("background.jpg", {id:"bg"});
// or use a static var to have auto-complete and static checks on your ide:
bulkLoader.add("background.jpg", {BulkLoader.ID:"bg"});
// loads the languages.xml file first and parses before all items are done:
public function parseLanguages() : void{
   var theLangXML : XML = bulkLoader.getXML("langs");
   // do something wih the xml:
   doSomething(theLangXML);
}
bulkLoader.add("languages.xml", {priority:10, onComplete:parseLanguages, id:"langs"});
// Start the loading operation with only 3 simultaneous connections:
bulkLoader.start(3)
   </listing>
        */
        public function add(url : *, props : Object= null ) : void {
            props = props || {};
            if (url is String){
                url = new URLRequest(url);
                if(props[HEADERS]){
                    url.requestHeaders = props[HEADERS];
                }
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
                         log("onStart for url ", item.url.url, " threw an error:", e.getStackTrace() ,3);
                     }
                    
                }
                if (props.onError && item.status == LoadingItem.STATUS_ERROR){
                    try{
                         props.onError();
                     }catch(e : Error){
                         log("onError for url ", item.url.url, " threw an error:", e.getStackTrace() ,3);
                     }
                    
                }else if (props.onComplete && item.isLoaded){
                    try{
                         props.onComplete();
                     }catch(e : Error){
                         log("onComplete for url ", item.url.url, " threw an error:", e.getStackTrace() ,3);
                     }
                }
                return;
            }
            
            item  = new LoadingItem(url, props["type"]);
            log("Added",item, 0);
            // properties from the props argument
            item.onStart = props[ON_START];
            item.onComplete = props[ON_COMPLETE];
            item.onError = props[ON_ERROR];
            item.preventCache = props[PREVENT_CACHING];
            item.id = props[ID];
            item.priority = int(props[PRIORITY]) || 0;
            item.maxTries = props[MAX_TRIES] || 3;
            item.weight = int(props[WEIGHT]) || 1;
            item.context = props[CONTEXT] || null;
            // internal, used to sort items of the same priority
            item.addedTime = getTimer();
            item.addEventListener(Event.COMPLETE, onItemComplete, false, 0, true);
            item.addEventListener(IOErrorEvent.IO_ERROR, onItemError, false, 0, true);
            item.addEventListener(Event.OPEN, onItemStarted, false, 0, true);
            item.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
            _items.push(item);
            itemsTotal += 1;
            totalWeight += item.weight;
            _items.sortOn(["priority", "addedTime"],  [Array.NUMERIC | Array.DESCENDING, Array.NUMERIC]);
        }
        
        /** Start loading all items added previously
        *   @param  withConnections [optional]The maximum number of connections to make at the same time. If specified, will override the parameter passed (if any) to the constructor.
        *   @see #numConnectons
        *   @see #see #BulkLoader()
        */   
        public function start(withConnections : int = -1 ) : void{
            if(_connections){
                loadNext();
                return;
            }
            startTime = getTimer();
            if (withConnections  > 0){
                _numConnectons = withConnections;
            }
            _connections = [];
            var max : int = Math.max(_numConnectons, _items.length);
            for (var i:int = 0; i< _connections.length; i++){
              //_connections[i] = _items[i];
              //log("Will load", _items[i], 0);
              //_items[i].load();
            }
            loadNext();
            isRunning = true;
        }
        
        /**  Register a new file extension to be loaded as a given type. This is used both in the guessing of types from the url and affects how loading is done for each type.
        *   @param  extension   The file extension to be used (can include the dot or not)
        *   @param  atType      Which type this extension will be associated with. 
        *   
        *   @see #TYPE_LOADER
        *   @see #TYPE_VIDEO
        *   @see #TYPE_SOUND
        *   @see #TYPE_TEXT
        *   
        *   @return A <code>Boolean</code> indicating if the new extension was registered.
        */
        public static function registerNewType( extension : String, atType : String) : Boolean {
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
              return true;
          }
          return false;
        }
        
        // if toLoad is specified it be cut line
        private function loadNext(toLoad : LoadingItem = null) : Boolean{
            if(isFinished){
                return false;
            }
            var next : Boolean = false;
            if (!toLoad){
                // no given to load, search for the next one in line
                for each (var checkItem:LoadingItem in _items){
                   if (!checkItem.isLoading && checkItem.status != LoadingItem.STATUS_STOPPED){
                       toLoad = checkItem;
                       break;
                   }
                }
            }
            if (toLoad){
                next = true;
                isRunning = true;
                if(_connections.length < numConnectons){
                    _connections.push(toLoad);
                    toLoad.load();
                    log("Will load item:", toLoad);
                }
                // if we've got any more connections to open, load the next item
                if(_connections.length < numConnectons){
                    loadNext();
                }
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
                 log("onComplete for url ", item.url.url, " threw an error:", e.getStackTrace() ,3);
             }
            } 
            item.cleanListeners();
            _contents[item.url.url] = item.content;
            
            var next : Boolean= loadNext();
           var allDone : Boolean = isAllDoneP();
           itemsLoaded ++;
           if(allDone) {
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
        
        private function removeFromItems(item : LoadingItem) : Boolean{
            var removeIndex : int = _items.indexOf(item)
            if(removeIndex > -1){
                _items.splice( removeIndex, 1); 
                return true;
            }
            if(item.isLoaded){
                itemsLoaded --;
            }
            itemsTotal --;
           return false;
        }
        
        private function removeFromConnections(item : *) : Boolean{
            var removeIndex : int = _connections.indexOf(item)
            if(removeIndex > -1){
                _connections.splice( removeIndex, 1); 
                return true;
            }
           return false;
        }
        
        private function onItemError(evt : IOErrorEvent) : void{
            var item : LoadingItem  = evt.target as LoadingItem;
           if(Boolean(item.onError))  {
               try{
                   item.onError();
              }catch(e : Error){
                  log("onError for url ", item.url.url, " threw an error!", e.getStackTrace(), 3);
              }
           }
           log("Error loading", item, 3);
           if(item.numTries < item.maxTries){
               item.status = null;
               item.load();
           }else{
               log("After " + item.numTries + " I am giving up on " + item.url.url, 3);
               removeFromConnections(item);
           }
        }
        
        private function onItemStarted(evt : Event) : void{
            var item : LoadingItem  = evt.target as LoadingItem;
            if (item.isVideo()){
                _contents[item.url.url] = item.stream;
            }
            log("Started loading", item, 1);
           if(Boolean(item.onStart)) {
               try{
                  item.onStart();
              }catch(e : Error){
                  log("onStart for url ", item.url.url, " threw an error!", e.getStackTrace(), 3);
              }
           }
        }
        
        private function onProgress(evt : Event = null) : void{
            bytesLoaded = bytesTotal = bytesTotalCurrent = 0;
            weightPercent = 0;
            itemsLoaded = 0;
            var itemsStarted : int = 0;
            var weightLoaded : Number = 0;
            for each (var item:LoadingItem in _items){
              if (item.status == LoadingItem.STATUS_STARTED || item.status == LoadingItem.STATUS_FINISHED || item.status == LoadingItem.STATUS_STOPPED){
                  bytesLoaded += item.bytesLoaded;
                  bytesTotalCurrent += item.bytesTotal;
                  weightLoaded += (item.bytesLoaded / item.bytesTotal) * item.weight;
                  if(item.status == LoadingItem.STATUS_FINISHED) {
                      itemsLoaded ++;
                  }
                  itemsStarted ++;
              }

            }

            // only set bytes total if all items have begun loading
            if (itemsStarted == _items.length){
                bytesTotal = bytesTotalCurrent;
            }else{
                bytesTotal = Number.POSITIVE_INFINITY;
            }
            weightPercent = weightLoaded / totalWeight;
            var e : BulkProgressEvent = new BulkProgressEvent(PROGRESS);
            e.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
            dispatchEvent(e);
        }
        

        
        /** The number of simultaneous connections to use.
        *   @return The number of connections used.
        *   @see #start()
        */
        public function get numConnectons() : int { 
            return _numConnectons; 
        }
        /** Returns an object where the urls are the keys(as strings) and the loaded contents are the value for that key.
        *  Each value is typed as * an the client must check for the right typing.
        *   @return An object hashed by urls, where values are the downloaded content type of each url. The user mut cast as apropriate.
        */
        public function get contents() : Object { 
          return _contents; 
        }
        
        /**
		* The name by which this loader instance can be identified.
		* This property is used so you can get a reference to this instance from other classes in your code without having to save and pass it yourself, throught the static method BulkLoader.getLoader(name) .<p/>
		* Each name should be unique, as instantiating a BulkLoader with a name already taken will throw an error.
		* @see #getLoaders()
		*/
        public function get name() : String { 
            return _name; 
        }
        
        /** ============================================================================== */
        /** = Acessing content function                                                  = */
        /** ============================================================================== */
        
        /** Helper functions to get loaded content. All helpers will be casted to the specific types. If a cast fails it will throw an error.
        *   
        */
        private function getContentAsType(key : *, type : Class,  clearMemory : Boolean = false) : *{
            var item : LoadingItem = getItem(key);
            if(!item){
                return null;
            }
            try{
                if (item.isLoaded || item.isVideo()) {
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
        
        /** Returns an untyped object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded.
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url
        */
        public function getContent(key : String, clearMemory : Boolean = false) : *{
            return getContentAsType(key,  Object,  clearMemory);
        }
        
        /** Returns an XML object with the downloaded asset for the given key.
        *   @param  key          String OR URLRequest     The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a XML object. Returns null if the cast fails.
        */
        public function getXML(key : *, clearMemory : Boolean = false) : XML{
            return XML(getContentAsType(key, XML,  clearMemory));
        }
        
        /** Returns a String object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a String object. Returns null if the cast fails.
        */
        public function getText(key : *, clearMemory : Boolean = false) : String{
            return String(getContentAsType(key, String, clearMemory));
        }
        
        /** Returns a Sound object with the downloaded asset for the given key.
        *   @param  key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param  clearMemory  Boolean    If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a Sound object. Returns null if the cast fails.
        */
        public function getSound(key : *, clearMemory : Boolean = false) : Sound{
            return Sound(getContentAsType(key, Sound,clearMemory));
        }
        
        /** Returns a Bitmap object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a Bitmap object. Returns null if the cast fails.
        */
        public function getBitmap(key : String, clearMemory : Boolean = false) : Bitmap{
            return Bitmap(getContentAsType(key, Bitmap, clearMemory));
        }
        
        /** Returns a <code>MovieClip</code> object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a MovieClip object. Returns null if the cast fails.
        */
        public function getMovieClip(key : String, clearMemory : Boolean = false) : MovieClip{
            return MovieClip(getContentAsType(key, MovieClip, clearMemory));
        }
        
        /** Returns a <code>NetStream</code> object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a NetStream object. Returns null if the cast fails.
        */
        public function getNetStream(key : String, clearMemory : Boolean = false) : NetStream{
            return NetStream(getContentAsType(key, NetStream, clearMemory));
        }
        
        /** Returns a <code>Object</code> with meta data information for a given <code>NetStream</code> key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The meta data object downloaded with this NetStream. Returns null if the given key does not resolve to a NetStream.
        */
        public function getNetStreamMetaData(key : String, clearMemory : Boolean = false) : Object{
            var netStream : NetStream = getNetStream(key, clearMemory);
            return  (Boolean(netStream) ? getItem(key).metaData : null);
            
        }
        
        /** Returns an BitmapData object with the downloaded asset for the given key.
        *   @param key The url request, url as a string or a id  from which the asset was loaded. Returns null if the cast fails. Does not clone the original bitmap data from the bitmap asset.
        *   @param clearMemory If this <code>BulkProgressEvent</code> instance should clear all references to the content of this asset.
        *   @return The content retrived from that url casted to a BitmapData object. Returns null if the cast fails.
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
        
        private function isAllDoneP() : Boolean{
            return _items.every(function(item : LoadingItem, ...rest):Boolean{
                return item.isLoaded;
            });
        }
        
        private function onAllLoaded() : void {
            var eComplete : BulkProgressEvent = new BulkProgressEvent(COMPLETE);
            eComplete.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
            var eProgress : BulkProgressEvent = new BulkProgressEvent(PROGRESS);
            eProgress.setInfo(bytesLoaded, bytesTotal, bytesTotalCurrent, itemsLoaded, itemsTotal, weightPercent);
            dispatchEvent(eProgress);
            dispatchEvent(eComplete);
            isRunning = false;
            endTime = getTimer();
            totalTime = BulkLoader.truncateNumber((endTime - startTime) /1000);
            updateStats();
            _connections = null;
            traceStats();
            isFinished = true;
            log("Finished all", 1);
        }
        
        /* If the <code>logLevel</code> if lower that <code>LOG_ERRORS</code>(3). Outputs a host of statistics about the loading operation
        *   @return A formated string with loading statistics.
        *   @see #LOG_ERRORS
        *   @see logLevel
        */
        public function traceStats() : String{
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
            var statsString : String = stats.join("\n");
            log(statsString, 1);
            return statsString;
        }
        
        /* Outputs with a trace operation a message. 
        *   Depending on <code>logLevel</code> diferrent levels of messages will be outputed:
        *   <ul>logLevel = LOG_VERBOSE (0) : Everything is logged. Useful for debugging.
        *   <ul>logLevel = LOG_INFO (1) : Every load operation is logged (loading finished, started, statistics).
        *   <ul>logLevel = LOG_ERRORS (3) : Only loading errors and callback erros will be traced. Useful in production.
        *   @see #logLevel
        *   @see #LOG_ERRORS
        *   @see #LOG_INFO
        *   @see #LOG_VERBOSE
        */   
        protected static function log(...msg) : void{
            var level : int  = isNaN(msg[msg.length -1] ) ? 3 : int(msg.pop());
            if (level >= logLevel ){
                trace("[BulkLoader]", msg.join(" "));
            }
        }
        
        /* Used internaly to fetch an item with a given key.
        *   @param key A url (as a string or urlrequest) or an id to fetch
        *   @return The corresponding <code>LoadingItem</code> or null if one isn't found.
        */
        private function getItem(key : *) : LoadingItem{
            for each (var item : LoadingItem in _items){
                if(item.id == key || item.url.url == key || item.url == key  ){
                    return item;
                }
            }
            return null;
        }
        
        /** This will delete this item from memory. It's content will be inaccessible after that.
        *   @param key A url (as a string or urlrequest) or an id to fetch
        *   @return <code>True</code> if an item with that key has been removed, and <code>false</code> othersiwe.
        *   */
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
            removeFromItems(item);
            item.destroy();
            item = null;
            // checks is removeing this item we are done?
            onProgress();
            return true;
        }
        
        /** Deletes all loading and loaded objects. This will stop all connections and delete from the cache all of it's items (no content will be accessible if <code>clearAll</code> is executed).
        */
        public function clearAll() : void{
            for each (var item : LoadingItem in _items){
                clearItem(item);
            }
            delete allLoaders[name];
            _items = _connections = null;
            _contents = null;
        }
        
        /** Deletes all content from all instances of <code>BulkLoader</code> class. This will stop any pending loading operations as well as free memory.
        *   @see #clearAll()
        */ 
        public static function clearAllLoaders() : void{
            for each (var atLoader : BulkLoader in allLoaders){
                atLoader.clearAll();
                delete allLoaders[atLoader.name];
                atLoader = null;
            }
            allLoaders = null;
        }
        
        /** Removes all items that have been stopped.
        *   After removing, it will try to restart loading if there are still items to load.
        *   @ return <code>True</code> if any items have been removed, <code>false</code> otherwise.
        */
        public function removePausedItems() : Boolean{
            var stoppedLoads : Array = _items.filter(function (item : LoadingItem, ...rest) : Boolean{
                return (item.status == LoadingItem.STATUS_STOPPED);
            });
            stoppedLoads.forEach(function(item : LoadingItem, ...rest):void{
               clearItem(item); 
            });
            loadNext();
            return stoppedLoads.length > 0;
        }
        
        /** Removes all items that have not succesfully loaded.
        *   After removing, it will try to restart loading if there are still items to load.
        *   @ return In any items have been removed.
        */
        public function removeFailedItems(): Boolean{
            var badLoads : Array = _items.filter(function (item : LoadingItem, ...rest) : Boolean{
                return (item.status == LoadingItem.STATUS_ERROR);
            });
            badLoads.forEach(function(item : LoadingItem, ...rest):void{
               clearItem(item); 
            });
            loadNext();
            return badLoads.length > 0;
        }
        /** Stop loading the item identified by <code>key</code>. This will not remove the item from the <code>BulkLoader</code>. Note that progress notification will jump around, as the stopped item will still count as something to load, but it's byte count will be 0.
        * @param key The key (url as a string, url as a <code>URLRequest</code> or an id as a <code>String</code>).    
        * @param loadsNext If it should start loading the next item.
        * @return A <code>Boolean</code> indicating if the object has been stopped.
        */
        public function pauseItem(key : *,  loadsNext : Boolean = false) : Boolean{
            var item : LoadingItem = key is LoadingItem ? key : getItem(key);
            if(!item) {
                return false;
            }
            item.stop();
            var result : Boolean = removeFromConnections(item);
            if(loadsNext){
                loadNext();
            }
            return result;
        }
        
        /** Stops loading all items of this <code>BulkLoader</code> instance. This does not clear or remove items from the qeue.
        */
        public  function pause() : void{
            for each(var item : LoadingItem in _items){
                pauseItem(item);
            }
            isRunning = false;
            log("Stopping all items", 1);
        }
        
        /** Stops loading all items from all <code>BulkLoader</code> instances.
        *   @see #stopAllItems()
        *   @see #stopItem()
        */
        public static function pauseAllLoaders() : void{
            for each (var atLoader : BulkLoader in allLoaders){
                atLoader.pause();
            }
        }
        
        /** Resumes loading of the item. Depending on the environment the player is running, resumed items will be able to use partialy downloaded content. 
        *   @param  key The url request, url as a string or a id  from which the asset was loaded. 
        *   @return If a item with that key has resumed loading.
        */
        public function resumeItem(key : *) : Boolean{
            var item : LoadingItem = key is LoadingItem ? key : getItem(key);
            if(item){
                if (item.status == LoadingItem.STATUS_STOPPED){
                    item.status = null;
                    return true
                }
            }
            return false;
        }
        
        /* Resumes all loading operations that were stopped.
        *   @return <code>True</code> if any item was stopped and resumed, false otherwise
        */
        public function resume() : Boolean{
            log("Resuming all items", 1);
            var affected : Boolean = false;
            _items.forEach(function(item : LoadingItem, ...rest):void{
                if(item.status == LoadingItem.STATUS_STOPPED){
                    resumeItem(item);
                    affected = true;
                }
            });
            loadNext();
            return affected;
        }
        /** Utility function to truncate a number to the given number of decimal places.
        *   @description 
        *   Number is truncated using the <code>Math.round</code> function.
        *   
        *   @param  The number to truncate
        *   @param  The number of decimals place to preserve.
        *   @return The truncated number.
        */
        public static function truncateNumber(raw : Number, decimals :int =2) : Number {
            var power : int = Math.pow(10, decimals);
           return Math.round(raw * ( power )) / power;
        }
        
        /** 
        *   Returns a string identifing this loaded instace.
        */
        override public function toString() : String{
            return "[BulkLoader] name:"+ name + "itemsTotal: " + itemsTotal + ", itemsLoaded: " + itemsLoaded; 
        }
    }   
}