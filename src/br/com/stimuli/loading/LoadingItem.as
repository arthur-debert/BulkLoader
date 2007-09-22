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
    /*
    *   An object used internaly in <code>BulkLoader</code> instances
    *
    *   @langversion ActionScript 3.0
    *   @playerversion Flash 9.0
    *
    *   @author Arthur Debert
    *   @since  15.09.2007
    */  
    public class LoadingItem extends EventDispatcher {

        public static const STATUS_CANCELED : String = "canceled";
        public static const STATUS_STARTED : String = "started";
        public static const STATUS_FINISHED : String = "finished";
        public static const STATUS_ERROR : String = "error";

        /*The type of loading to perform (see <code>BulkLoader.TYPES</code>).*/
        public var type : String;
        /*The url to load the asset from.*/
        public var url : URLRequest;
        /*An [optional] id to retrieve the item by.*/
        public var id : String;
        /* The priority at which this item will be downloaded. Items with a higher priority will be downloaded first.*/
        public var priority : int = 0;
        /*Indicated if item is loaded and ready to use..*/
        public var isLoaded : Boolean;
        /*Indicated if loading has stated.*/
        public var isLoading : Boolean;
        /*At what stage this item is at ( canceled, started, finished or error).*/
        public var status : String;
        /*Maximun number of tries in case it fails.*/
        public var maxTries : int = 3;
        /*Current try number.*/
        public var numTries : int = 0;
        /*Callback to execute as soon as server starts the response.*/
        public var onStart : Function;
        /*Callback to execute as soon item is ready to use.*/
        public var onComplete : Function;
        /*Callback to execute if an error has ocurred.*/
        public var onError : Function;
        
        /*A relative unit of size, so that preloaders can show relative progress before all connections have started.*/
        public var weight : int = 1;
        /*If a random string should be appended to the end of the url to prevent caching.*/
        public var preventCache : Boolean;
        /*the number of bytes to load. Starts at -1.*/
        public var bytesTotal : int = -1;
        /*the number of bytes loaded so far. Starts at -1.*/
        public var bytesLoaded : int = 0;
        /*The percentage of loading done (from 0 to 1).*/
        public var percentLoaded : Number;
        /*The percentage of loading done relative to the weight of this item(from 0 to 1).*/
        public var weightPercentLoaded : Number;
        
        public var addedTime : int ;
        private var startTime : int ;
        private var responseTime : Number;
        /* The time (in seconds) that the server took and send begin streaming content.*/
        public var latency : Number;
        private var totalTime : int;
        /* The total time (in seconds) this item took to load.*/
        public var timeToDownload : int;
        /* The speed (in kbs) for this download.*/
        public var speed : Number;
        /* Internal object used to manage this download.*/
        private var loader : *;
        /* Internal object that holds the download content.*/
        private var _content : *;
        
        // for video:
        public var nc:NetConnection;
        public var stream : NetStream;
        public var dummyEventTrigger : Sprite;
        
        private var _metaData : Object;
        
        public function LoadingItem(url : URLRequest, type : String){
            
            if (type) {
                this.type = type.toLowerCase();
            }else{
                this.type = url.url.substring(url.url.lastIndexOf(".") + 1).toLowerCase();
            }
            if (BulkLoader.TYPES.indexOf(this.type) == -1 ){
                this.type = "txt";
            }
            if(type=="image"){
                type = "loader";
            }
            this.url = url;
        }
        
        public function get content() : * { 
          return _content; 
        }
        
        public function load() : void{
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
                loader.load(url);
            }else if (loader is Sound){
                loader.addEventListener(ProgressEvent.PROGRESS, onProgressHandler, false, 0, true);
                loader.addEventListener(Event.COMPLETE, onCompleteHandler, false, 0, true);
                loader.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
                loader.addEventListener(Event.OPEN, onStartedHandler, false, 0, true);
                loader.load(url);
            }else if (loader is NetConnection){
                loader.connect(null);
                stream = new NetStream(loader);
                stream.addEventListener(IOErrorEvent.IO_ERROR, onErrorHandler, false, 0, true);
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
            isLoading = true;
            startTime = getTimer();
        }
        
        public function createNetStreamEvent(evt : Event) : void{
            if(bytesTotal == bytesLoaded && bytesTotal > 8){
                dummyEventTrigger.removeEventListener(Event.ENTER_FRAME, createNetStreamEvent, false);
                var completeEvent : Event = new Event(Event.COMPLETE);
                onCompleteHandler(completeEvent);
            }else if(bytesTotal == 0 && stream.bytesTotal > 4){
                var startEvent : Event = new Event(Event.OPEN);
                onStartedHandler(startEvent);
                bytesLoaded = stream.bytesLoaded;
                bytesTotal = stream.bytesTotal;
            }else{
                var event : ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, stream.bytesLoaded, stream.bytesTotal);
                onProgressHandler(event)
            }
        }
        
        public function onVideoMetadata(evt : *):void{
            _metaData = evt;
        };
        
        public function get metaData() : Object { 
            return _metaData; 
        }
        
        public function onProgressHandler(evt : *) : void {
           this.bytesLoaded = evt.bytesLoaded;
           this.bytesTotal = evt.bytesTotal;
           this.percentLoaded = this.bytesLoaded / this.bytesTotal;
           this.weightPercentLoaded = percentLoaded * weight;
           dispatchEvent(evt);
        }
        
        public function onCompleteHandler(evt : Event) : void {
            totalTime = getTimer();
            timeToDownload = ((totalTime - responseTime) /1000);
            if(timeToDownload == 0){
                timeToDownload = 0.2;
            }
            speed = BulkLoader.truncateNumber((bytesTotal / 1024) / (timeToDownload));
            if (timeToDownload == 0){
                speed  = 3000;
            }
           status = STATUS_FINISHED;
           isLoaded = true;
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
        
        public function onErrorHandler(evt : IOErrorEvent) : void{
            numTries ++;
            status = STATUS_ERROR;
            dispatchEvent(evt);
        }
        
        public function onStartedHandler(evt : Event) : void{
            responseTime = getTimer();
            latency = BulkLoader.truncateNumber((responseTime - startTime)/1000);
            status = STATUS_STARTED;
            dispatchEvent(evt);
        }
        
        public override function toString() : String{
            return "LoadingItem url: " + url.url + ", type:" + type + ", status: " + status;
        }
        
        public function stop() : void{
            try{
                loader.close();
            }catch(e : Error){
                
            }
            status = null;
        }
        
        public function cleanListeners() : void {
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
        
        public function destroy() : void{
            stop();
            cleanListeners();
            _content = null;
        }
    }
    
}
