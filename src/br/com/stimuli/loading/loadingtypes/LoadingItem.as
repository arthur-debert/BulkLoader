/* BulkLoader: manage multiple loadings in Actioncript 3.
*   
*   
*   @author Arthur Debert
*   @version 0.9.1
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
*/
package br.com.stimuli.loading {
    
    import flash.events.*;
    import flash.events.EventDispatcher;
    import flash.display.*;
    import flash.net.*;
    import flash.media.Sound;
    import flash.utils.*;
    
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.BulkErrorEvent;
    
    /**
     *  Dispatched on download progress.
     *
     *  @eventType flash.events.ProgressEvent.PROGRESS
     */
    [Event(name="progress", type="flash.events.ProgressEvent.PROGRESS")]

    /**
     *  Dispatched when all the item has been fully downloaded and is ready for use..
     *
     *  @eventType flash.events.ProgressEvent.COMPLETE
     */
    [Event(name="complete", type="flash.events.ProgressEvent.COMPLETE")]
    
    /**
     *  Dispatched when the connection has been stablished and the download has begun. For types that can be streamed such as videos (<code>NetStream</code>) and sound(<code>Sound</code>), it's content is will be available after this event has fired.
     *
     *  @eventType flash.events.Event.OPEN
     */
    [Event(name="open", type="flash.events.Event.OPEN")]
    
    /**
     *  Dispatched when the the netStream can be played until the end with no interuption expected. Only fires for TYPE_VIDEO items and will only fire once.
     *
     *  @eventType br.com.stimuli.loading.BulkLoader.CAN_BEGIN_PLAYING
     */
    [Event(name="canBeginPlaying", type="br.com.stimuli.loading.BulkLoader.CAN_BEGIN_PLAYING")]
    
    /**
    *   An object used in <code>BulkLoader</code> instances.<p/>
    *   A reference to a <code>LoadingItem</code> object can be used to attach events for an individual item.
    *
    *   @langversion ActionScript 3.0
    *   @playerversion Flash 9.0
    *
    *   @author Arthur Debert
    *   @since  15.09.2007
    */  
    public class LoadingItem extends EventDispatcher {
        /** @private */
        internal static const STATUS_STOPPED : String = "stopped";
        /** @private */
        internal static const STATUS_STARTED : String = "started";
        /** @private */
        internal static const STATUS_FINISHED : String = "finished";
        /** @private */
        internal static const STATUS_ERROR : String = "error";

        /** The type of loading to perform (see <code>BulkLoader.TYPES</code>).
        * @private */
        internal var _type : String;
        // The url to load the asset from.
        /** @private */
        internal var url : URLRequest;
        /** @private */
        internal var _id : String;

        /** @private */
        internal var _priority : int = 0;
        /** @private */
        
        ///**Indicated if item is loaded and ready to use..*/
        internal var _isLoaded : Boolean;
        /**Indicated if loading has stated.
        * @private 
        */
        internal var _isLoading : Boolean;
        
        /** Indicates if we've already fired an event letting users know that the netstream can
        *   begin playing (has enough buffer to play with no interruptions)
        *   @private
        */
        private var _canBeginStreaming : Boolean = false;
        
        /** @private 
        *   At what stage this item is at ( canceled, started, finished or error).
        */
        internal var status : String;
        // 
        /** @private 
        *   Maximun number of tries in case it fails.
        *   */
        internal var maxTries : int = 3;
        /**Current try number.
        *   @private
        */
        internal var numTries : int = 0;
        
        /**A relative unit of size, so that preloaders can show relative progress before all connections have started.
        * @private
        */
        internal var weight : int = 1;
        /**If a random string should be appended to the end of the url to prevent caching.
        *   @private
        */
        internal var preventCache : Boolean;
        /**the number of bytes to load. Starts at -1.
        *   @private
        */
        internal var _bytesTotal : int = -1;
        /**the number of bytes loaded so far. Starts at -1.
        * @private
        */
        internal var _bytesLoaded : int = 0;
        
        internal var _bytesRemaining : int = -1;
        /**The percentage of loading done (from 0 to 1).
        * @private   
        */
        internal var _percentLoaded : Number;
        /**The percentage of loading done relative to the weight of this item(from 0 to 1).
        *   @private
        */
        internal var _weightPercentLoaded : Number;
        /**
        *   @private
        */
        internal var _addedTime : int ;
        private var _startTime : int ;
        private var _responseTime : Number;
        /** The time (in seconds) that the server took and send begin streaming content.
            @private
        */
        internal var _latency : Number;
        private var _totalTime : int;
        /** The total time (in seconds) this item took to load.*/
        private var _timeToDownload : int;
        /** The speed (in kbs) for this download.
        *   @private
        *   */
        internal var _speed : Number;
        /** Internal object used to manage this download.*/
        private var loader : *;

        private var _content : *;
        private var _httpStatus : int = 0;
        /**
        *   @private
        */
        internal var context : * = null;
        // for video:
        private var nc:NetConnection;
        
        /**
        *   @private
        */
        internal var stream : NetStream;
        private var dummyEventTrigger : Sprite;
        /**
        *   @private
        */
        internal var pausedAtStart : Boolean = false;
        
        private var _metaData : Object;
        private var internalType : String;
        
        private static var classes : Object = {
            loader: Loader,
            xml: URLLoader,
            video:NetConnection,
            sound: Sound,
            text: URLLoader
        }
        public function LoadingItem(url : URLRequest, type : String){
            
            if (type) {
                this._type = type.toLowerCase();
            }else{
                this._type = guessType(url.url);
                
            }
            internalType = getInternalType(this._type);
            this.url = url;
        }
        
        /** The content resulting from this download. The data type for the <code>content</code> depends on the myme-type of the downloaded asset. For types that can be streamed such as videos (<code>NetStream</code>) and sound(<code>Sound</code>), it's content is available as soon as the connection is open. Otherwiser the content will be available after the download is done and the <code>Event.COMPLETE</code> is fired.
        *   @return An object whose type depends on what the asset is.
        */
        public function get content() : * { 
          return _content; 
        }
        /**
        *   @private
        */
        internal function load() : void{
            if (preventCache){
                var cacheString : String = "BulkLoaderNoCache=" + int(Math.random()  * 100 * getTimer());
                if(url.url.indexOf("?") == -1){
                    url.url += "?" + cacheString;
                }else{
                    url.url += "&" + cacheString;
                }
            }
            
            var loaderClass : Class  = LoadingItem.classes[internalType];
            loader = new loaderClass();
            
            if (loader is Loader){
                loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);  
                loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler, false, 0, true);
                loader.load(url, context);
            }else if (loader is Sound){
                loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
                loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHttpStatusHandler, false, 0, true);
                loader.load(url, context);
            }else if (loader is NetConnection){
                loader.connect(null);
                stream = new NetStream(loader);
                stream.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
                dummyEventTrigger = new Sprite();
                dummyEventTrigger.addEventListener(Event.ENTER_FRAME, createNetStreamEvent, false, 0, true);
                var customClient:Object = new Object();
                customClient.onCuePoint = function(...args):void{};
                customClient.onMetaData = onVideoMetadata;
                customClient.onPlayStatus = function(...args):void{};
                stream.client = customClient;
                stream.play(url.url);
                stream.seek(0);
            }else if(loader is URLLoader){
                loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
                loader.load(url);
            }
            _isLoading = true;
            _startTime = getTimer();
        }
        /**
        *   @private
        */
        internal function createNetStreamEvent(evt : Event) : void{
            if(_bytesTotal == _bytesLoaded && _bytesTotal > 8){
                dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, createNetStreamEvent, false);
                var completeEvent : Event = new Event(Event.COMPLETE);
                onCompleteHandler(completeEvent);
            }else if(_bytesTotal == 0 && stream.bytesTotal > 4){
                var startEvent : Event = new Event(Event.OPEN);
                onStartedHandler(startEvent);
                _bytesLoaded = stream.bytesLoaded;
                _bytesTotal = stream.bytesTotal;
            }else{
                var event : ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, stream.bytesLoaded, stream.bytesTotal);
                onProgressHandler(event)
            }
        }
        
        /**
        *   @private
        */
        internal function onNetStatus(evt : NetStatusEvent) : void{
            stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
            if(evt.info.code == "NetStream.Play.Start"){
                _content = stream;
                var e : Event = new Event(Event.OPEN);
                onStartedHandler(e);
            }
        }
        /**
        *   @private
        */
        internal function onHttpStatusHandler(evt : HTTPStatusEvent) : void{
            _httpStatus = evt.status;
            dispatchEvent(evt);
        }
        /**
        *   @private
        */
        internal function onVideoMetadata(evt : *):void{
            _metaData = evt;
        };
        
        /**
        *   @private
        */
        public function get metaData() : Object { 
            return _metaData; 
        }
        /**
        *   @private
        */
        private function onProgressHandler(evt : *) : void {
           _bytesLoaded = evt.bytesLoaded;
           _bytesTotal = evt.bytesTotal;
           _bytesRemaining = _bytesTotal - bytesLoaded;
           _percentLoaded = _bytesLoaded / _bytesTotal;
           _weightPercentLoaded = _percentLoaded * weight;
           // if it's a video, check if we predict that time until finish loading
           // is enough to play video back
           if (isVideo() && metaData && !_canBeginStreaming){
               var timeElapsed : int = getTimer() - responseTime;
               var currentSpeed : Number = bytesLoaded / (timeElapsed/1000);
               // be cautios, give a 20% error margin for estimated download time:
               var estimatedTimeRemaining : Number = _bytesRemaining / (currentSpeed * 0.8);
               var videoTimeToDownload : Number = metaData.duration - stream.bufferLength;
               if (videoTimeToDownload > estimatedTimeRemaining){
                   fireCanBeginStreamingEvent();
               }
           }
           dispatchEvent(evt);
        }
        
        private function fireCanBeginStreamingEvent() : void{
            if(_canBeginStreaming){
                return;
            }
            _canBeginStreaming = true;
            var evt : Event = new Event(BulkLoader.CAN_BEGIN_PLAYING);
            dispatchEvent(evt);
        }
        
        private function onCompleteHandler(evt : Event) : void {
            _totalTime = getTimer();
            _timeToDownload = ((_totalTime - _responseTime) /1000);
            if(_timeToDownload == 0){
                _timeToDownload = 0.2;
            }
            _speed = BulkLoader.truncateNumber((bytesTotal / 1024) / (_timeToDownload));
            if (_timeToDownload == 0){
                _speed  = 3000;
            }
           status = STATUS_FINISHED;
           _isLoaded = true;
           if (loader is Loader){
               _content = loader.content;
           }else if (loader is URLLoader){
               if(_type == BulkLoader.TYPE_XML){
                   _content = new XML(loader.data);
               }else{
                   _content = loader.data;
               }
               
           }else if (loader is Sound){
               _content = loader;
           }else if (loader is NetConnection){
               _content = stream;
           }
           dispatchEvent(evt);
        }
        
        private function onErrorHandler(evt : Event) : void{
            numTries ++;
            status = STATUS_ERROR;   
            if(numTries >= maxTries){
                var bulkErrorEvent : BulkErrorEvent = new BulkErrorEvent(BulkErrorEvent.ERROR);
                bulkErrorEvent.errors = [this];
                dispatchEvent(bulkErrorEvent);
            }else{   
                status = null
                load();
            }
           
        }
        
        private function onStartedHandler(evt : Event) : void{
            _responseTime = getTimer();
            _latency = BulkLoader.truncateNumber((_responseTime - _startTime)/1000);
            status = STATUS_STARTED;
            if(pausedAtStart && stream){
                stream.pause();
            }
            if( isSound()){
                _content = loader;
            }
            dispatchEvent(evt);
        }
        
        public override function toString() : String{
            return "LoadingItem url: " + url.url + ", type:" + _type + ", status: " + status;
        }
        
        /**
        *   @private
        */
        internal function stop() : void{
            if(_isLoaded){
                return;
            }
            try{
                if(loader){
                    loader.close();
                }
            }catch(e : Error){
                
            }
            status = STATUS_STOPPED;
            _isLoading = false;
        }
        /**
        *   @private
        */
        internal function cleanListeners() : void {
            if (_type != BulkLoader.TYPE_VIDEO && loader){
                var removalTarget : Object = loader;
                if (loader is Loader){
                    removalTarget = loader.contentLoaderInfo;
                }
                removalTarget.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
                removalTarget.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
                removalTarget.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                removalTarget.removeEventListener(BulkLoader.OPEN, onStartedHandler, false);
            }else if (_type == BulkLoader.TYPE_VIDEO ) {
                if (stream) stream.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                if(dummyEventTrigger){
                    dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, createNetStreamEvent, false);
                    dummyEventTrigger = null;
                }
            }
        }
        
        public function isVideo(): Boolean{
            return internalType == BulkLoader.TYPE_VIDEO;
        }
        
        public function isSound(): Boolean{
            return internalType == BulkLoader.TYPE_SOUND;
        }
        
        public function isText(): Boolean{
            return internalType == BulkLoader.TYPE_TEXT;
        }
        
        public function isXML(): Boolean{
            return internalType == BulkLoader.TYPE_XML;
        }
        
        public function isImage() : Boolean{
            return isLoader() && content is Bitmap;
        }
        
        public function isSWF() : Boolean{
            return isLoader() && content is MovieClip;
        }
        public function isLoader(): Boolean{
            return internalType == BulkLoader.TYPE_LOADER;
        }
        
        public function isStreamable() : Boolean{
            return isVideo() || isSound() || isSWF();
        }
        
        /**
        *   @private
        */
        internal function destroy() : void{
            stop();
            cleanListeners();
            _content = null;
            loader = null;
        }
        
        
        /** Public accessors
        *   @private
        */
        internal function get bytesTotal() : int { 
            return _bytesTotal; 
        }
        
        /**
        *   @private
        */
        internal function get bytesLoaded() : int { 
            return _bytesLoaded; 
        }
        
        /**
        *   @private
        */
        internal function get bytesRemaining() : int { 
            return _bytesRemaining; 
        }
        
        /**
        *   @private
        */
        internal function get percentLoaded() : Number { 
            return _percentLoaded; 
        }
        
        /**
        *   @private
        */
        internal function get weightPercentLoaded() : Number { 
            return _weightPercentLoaded; 
        }
        /** The priority at which this item will be downloaded. Items with a higher priority will be downloaded first.
        *   @private
        */
        public function get priority() : int { 
            return _priority; 
        }
        
        /** The type of this item.
        *   @see BulkLoader.AVAILABLE_TYPES
        */
        public function get type() : String{
            return _type;
        }
        
        /** A Boolean that indicates if the item is fully loaded and ready for consumption.
        */
        public function get isLoaded() : Boolean { 
            return _isLoaded; 
        }
        /**
        *   @private
        */
        public function get addedTime() : int { 
            return _addedTime; 
        }
    
        /**
        *   @private
        */
        public function get startTime() : int { 
            return _startTime; 
        }
        
        /**
        *   @private
        */
        public function get responseTime() : Number { 
            return _responseTime; 
        }
        
        
        /** The time (in seconds) that the server took and send begin streaming content.
        *   @private
        */
        public function get latency() : Number { 
            return _latency; 
        }
        
        /**
        *   @private
        */
        public function get totalTime() : int { 
            return _totalTime; 
        }
        
        /** The total time (in seconds) this item took to load.
        *   @private
        */
        public function get timeToDownload() : int { 
            return _timeToDownload; 
        }
        
        /** The speed (in kbs) for this download.
        *   @private
        */
        public function get speed() : Number { 
            return _speed; 
        }
        
        /** The httpStatus of the LoadingItem, as in int (0 if no status has been received).
        *   @private
        */
        public function get httpStatus() : int { 
            return _httpStatus; 
        }       
        
        /** The id this item was assigned. This is use in all of BulkLoader.getXXX(key) functions
        */
        public function get id() : String { 
            return _id; 
        }
        
        /** @private
        *  Simply tries to guess the type from the file ending. Will remove query strings on urls
        */ 
        internal static function guessType(urlAsString : String) : String{
            // no type is given, try to guess from the url
            var searchString : String = urlAsString.indexOf("?") > -1 ? urlAsString.substring(0, urlAsString.indexOf("?")) : urlAsString;
            var _type : String = searchString.substring(searchString.lastIndexOf(".") + 1).toLowerCase();
            
        if(!Boolean(_type) ){
            _type = BulkLoader.TYPE_TEXT;
        }
            return _type;
    }
    
    /** @private
    *   Converts a type visible for users:"jpg", "image", "flv" into a type useful internally "loader", "text" etc...
    */
        internal static function getInternalType(fromType : String) : String{
            var internalType : String ;
            // find out from the type, what we will be using for loading (the internalType)
            if(fromType == BulkLoader.TYPE_LOADER || BulkLoader.LOADER_TYPES.indexOf(fromType) > -1){
                internalType = BulkLoader.TYPE_LOADER;
            }else if (fromType == BulkLoader.TYPE_SOUND ||BulkLoader.SOUND_TYPES.indexOf(fromType) > -1){
                internalType = BulkLoader.TYPE_SOUND;
            }else if (fromType == BulkLoader.TYPE_VIDEO ||BulkLoader.VIDEO_TYPES.indexOf(fromType) > -1){
                internalType = BulkLoader.TYPE_VIDEO;
            }else if (fromType == BulkLoader.TYPE_XML ||BulkLoader.XML_TYPES.indexOf(fromType) > -1){
                internalType = BulkLoader.TYPE_XML;
            }else{
                internalType = BulkLoader.TYPE_TEXT;
            }

            return internalType;
        }
    
}}
