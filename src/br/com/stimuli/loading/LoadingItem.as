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
*/
package br.com.stimuli.loading {
    
    import flash.events.*;
    import flash.events.EventDispatcher;
    import flash.display.*;
    import flash.net.*;
    import flash.media.Sound;
    import flash.utils.*;
    
    import br.com.stimuli.loading.BulkLoader;
    
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
     *  @eventType flash.events.ProgressEvent.COMPLETE
     */
    [Event(name="open", type="flash.events.Event.OPEN")]
    
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

        internal static const STATUS_STOPPED : String = "stopped";
        internal static const STATUS_STARTED : String = "started";
        internal static const STATUS_FINISHED : String = "finished";
        internal static const STATUS_ERROR : String = "error";

        /**The type of loading to perform (see <code>BulkLoader.TYPES</code>).*/
        internal var type : String;
        /**The url to load the asset from.*/
        internal var url : URLRequest;
        /**An [optional] id to retrieve the item by.*/
        internal var id : String;
        /** The priority at which this item will be downloaded. Items with a higher priority will be downloaded first.*/
        private var _priority : int = 0;
        /**Indicated if item is loaded and ready to use..*/
        internal var _isLoaded : Boolean;
        /**Indicated if loading has stated.*/
        internal var _isLoading : Boolean;
        /**At what stage this item is at ( canceled, started, finished or error).*/
        internal var status : String;
        /**Maximun number of tries in case it fails.*/
        internal var maxTries : int = 3;
        /**Current try number.*/
        internal var numTries : int = 0;
        
        /**A relative unit of size, so that preloaders can show relative progress before all connections have started.*/
        internal var weight : int = 1;
        /**If a random string should be appended to the end of the url to prevent caching.*/
        internal var preventCache : Boolean;
        /**the number of bytes to load. Starts at -1.*/
        internal var _bytesTotal : int = -1;
        /**the number of bytes loaded so far. Starts at -1.*/
        internal var _bytesLoaded : int = 0;
        /**The percentage of loading done (from 0 to 1).*/
        internal var _percentLoaded : Number;
        /**The percentage of loading done relative to the weight of this item(from 0 to 1).*/
        internal var _weightPercentLoaded : Number;
        
        private var _addedTime : int ;
        private var _startTime : int ;
        private var _responseTime : Number;
        /** The time (in seconds) that the server took and send begin streaming content.*/
        private var _latency : Number;
        private var _totalTime : int;
        /** The total time (in seconds) this item took to load.*/
        private var _timeToDownload : int;
        /** The speed (in kbs) for this download.*/
        private var _speed : Number;
        /** Internal object used to manage this download.*/
        private var loader : *;

        private var _content : *;
        
        internal var context : * = null;
        // for video:
        private var nc:NetConnection;
        internal var stream : NetStream;
        private var dummyEventTrigger : Sprite;
        
        private var _metaData : Object;
        
        public function LoadingItem(url : URLRequest, type : String){
            
            if (type) {
                this.type = type.toLowerCase();
            }else{
                
                var searchString : String = url.url.indexOf("?") > -1 ? url.url.substring(0, url.url.indexOf("?")) : url.url;
                this.type = searchString.substring(searchString.lastIndexOf(".") + 1).toLowerCase();
                
            }
            if (BulkLoader.AVAILABLE_TYPES.indexOf(this.type) == -1 ){
                this.type = "txt";
            }
            if(type=="image"){
                type = "loader";
            }
            this.url = url;
        }
        
        /** The content resulting from this download. The data type for the <code>content</code> depends on the myme-type of the downloaded asset. For types that can be streamed such as videos (<code>NetStream</code>) and sound(<code>Sound</code>), it's content is available as soon as the connection is open. Otherwiser the content will be available after the download is done and the <code>Event.COMPLETE</code> is fired.
        *   @return An object whose type depends on what the asset is.
        */
        public function get content() : * { 
          return _content; 
        }
        
        internal function load() : void{
            if (preventCache){
                var cacheString : String = "BulkLoaderNoCache=" + int(Math.random()  * 100 * getTimer());
                if(url.url.indexOf("?") == -1){
                    url.url += "?" + cacheString;
                }else{
                    url.url += "&" + cacheString;
                }
            }
            var loaderClass : Class ;
            if (BulkLoader.LOADER_TYPES.indexOf(type) > -1){
                loaderClass = Loader;
            }else if (BulkLoader.TEXT_TYPES.indexOf(type) > -1){
                loaderClass = URLLoader;
            }else if (BulkLoader.VIDEO_TYPES.indexOf(type) > -1){
                loaderClass = NetConnection;
            }else if (BulkLoader.SOUND_TYPES.indexOf(type) > -1){
                loaderClass = Sound;
            }
            loader = new loaderClass();
            
            if (loader is Loader){
                loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.contentLoaderInfo.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
                loader.load(url, context);
            }else if (loader is Sound){
                loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
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
            startTime = getTimer();
        }
        
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
        
        internal function onNetStatus(evt : NetStatusEvent) : void{
            stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
            if(evt.info.code == "NetStream.Play.Start"){
                _content = stream;
                var e : Event = new Event(Event.OPEN);
                onStartedHandler(e);
            }
        }
        
        internal function onVideoMetadata(evt : *):void{
            _metaData = evt;
        };
        
        public function get metaData() : Object { 
            return _metaData; 
        }
        
        private function onProgressHandler(evt : *) : void {
           _bytesLoaded = evt.bytesLoaded;
           _bytesTotal = evt.bytesTotal;
           _percentLoaded = _bytesLoaded / _bytesTotal;
           _weightPercentLoaded = _percentLoaded * weight;
           dispatchEvent(evt);
        }
        
        private function onCompleteHandler(evt : Event) : void {
            _totalTime = getTimer();
            timeToDownload = ((totalTime - responseTime) /1000);
            if(timeToDownload == 0){
                timeToDownload = 0.2;
            }
            speed = BulkLoader.truncateNumber((bytesTotal / 1024) / (timeToDownload));
            if (timeToDownload == 0){
                speed  = 3000;
            }
           status = STATUS_FINISHED;
           _isLoaded = true;
           if (loader is Loader){
               _content = loader.content;
           }else if (loader is URLLoader){
               if(type == BulkLoader.TYPE_XML){
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
        
        private function onErrorHandler(evt : IOErrorEvent) : void{
            numTries ++;
            status = STATUS_ERROR;
            if(numTries >= maxTries){
                dispatchEvent(evt);
            }
        }
        
        private function onStartedHandler(evt : Event) : void{
            responseTime = getTimer();
            latency = BulkLoader.truncateNumber((responseTime - startTime)/1000);
            status = STATUS_STARTED;
            dispatchEvent(evt);
        }
        
        public override function toString() : String{
            return "LoadingItem url: " + url.url + ", type:" + type + ", status: " + status;
        }
        
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
        
        internal function cleanListeners() : void {
            if (type != BulkLoader.TYPE_VIDEO){
                loader.removeEventListener(ProgressEvent.PROGRESS, onProgressHandler, false);
                loader.removeEventListener(Event.COMPLETE, onCompleteHandler, false);
                loader.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                loader.removeEventListener(Event.OPEN, onStartedHandler, false);
            }else{
                stream.removeEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false);
                if(dummyEventTrigger){
                    dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, createNetStreamEvent, false);
                    dummyEventTrigger = null;
                }
            }

            loader = null;
        }
        
        public function isVideo(): Boolean{
            return BulkLoader.VIDEO_TYPES.indexOf(type) > -1;
        }
        
        internal function destroy() : void{
            stop();
            cleanListeners();
            _content = null;
        }
        
        
        /* Public accessors
        */
        public function get bytesTotal() : int { 
            return _bytesTotal; 
        }
        
        public function get bytesLoaded() : int { 
            return _bytesLoaded; 
        }
        
        public function get percentLoaded() : Number { 
            return _percentLoaded; 
        }
        
        public function get weightPercentLoaded() : Number { 
            return _weightPercentLoaded; 
        }
        
        public function get priority() : int { 
            return _priority; 
        }
        
        public function set priority(value:int) : void { 
            _priority = value; 
        }
        
        public function get addedTime() : int { 
            return _addedTime; 
        }
        
        public function set addedTime(value:int) : void { 
            _addedTime = value; 
        }
        
        public function get startTime() : int { 
            return _startTime; 
        }
        
        public function set startTime(value:int) : void { 
            _startTime = value; 
        }
        
        public function get responseTime() : Number { 
            return _responseTime; 
        }
        
        public function set responseTime(value:Number) : void { 
            _responseTime = value; 
        }
        /** The time (in seconds) that the server took and send begin streaming content.*/
        
        public function get latency() : Number { 
            return _latency; 
        }
        
        public function set latency(value:Number) : void { 
            _latency = value; 
        }
        
        public function get totalTime() : int { 
            return _totalTime; 
        }
        
        public function set totalTime(value:int) : void { 
            _totalTime = value; 
        }
        /** The total time (in seconds) this item took to load.*/
        public function get timeToDownload() : int { 
            return _timeToDownload; 
        }
        
        public function set timeToDownload(value:int) : void { 
            _timeToDownload = value; 
        }
        /** The speed (in kbs) for this download.*/
        public function get speed() : Number { 
            return _speed; 
        }
        
        public function set speed(value:Number) : void { 
            _speed = value; 
        }
    }
    
}
