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
package br.com.stimuli.loading.loadingtypes {
    
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.utils.SmartURL;
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.utils.*;
    
    /** 
     *  Dispatched on download progress.
     *
     *  @eventType flash.events.ProgressEvent.PROGRESS
     */
    [Event(name="progress", type="flash.events.ProgressEvent")]

    /**
     *  Dispatched when all the item has been fully downloaded and is ready for use..
     *
     *  @eventType flash.events.ProgressEvent.COMPLETE
     */
    [Event(name="complete", type="flash.events.Event")]
    
    /**
     *  Dispatched when the connection has been stablished and the download has begun. For types that can be streamed such as videos (<code>NetStream</code>) and sound(<code>Sound</code>), it's content is will be available after this event has fired.
     *
     *  @eventType flash.events.Event.OPEN
     */
    [Event(name="open", type="flash.events.Event")]
    
    /**
     *  Dispatched when the ImageItem (swf or image) has inited.
     *
     *  @eventType flash.events.Event.INIT
     */
    [Event(name="init", type="flash.events.Event")]
    
    /**
     *  Dispatched when the the netStream can be played until the end with no interuption expected. Only fires for TYPE_VIDEO items and will only fire once.
     *
     *  @eventType br.com.stimuli.loading.BulkLoader.CAN_BEGIN_PLAYING
     */
    [Event(name="canBeginPlaying", type="br.com.stimuli.loading.BulkLoader")]
    
    /**
    *   An class used in <code>BulkLoader</code> instances.<p/>.
    *   A reference to a <code>LoadingItem</code> object can be used to attach events for an individual item, read it's id, type, content and urls from inside event handlers.
    *   When implementing custom loading types, the new type should be a subclass of LoadingItem.
    *   This class is just the base for specific loading types, but should provide the external interface for end users.
    *   @langversion ActionScript 3.0
    *   @playerversion Flash 9.0
    *
    *   @author Arthur Debert
    *   @since  15.09.2007
    */  
    public class LoadingItem extends EventDispatcher {
        /** @private */
        public static const STATUS_STOPPED : String = "stopped";
        /** @private */
        public static const STATUS_STARTED : String = "started";
        /** @private */
        public static const STATUS_FINISHED : String = "finished";
        /** @private */
        public static const STATUS_ERROR : String = "error";

        /** The type of loading to perform (see <code>BulkLoader.TYPES</code>).
        * @private */
        public var _type : String;
        // The url to load the asset from.
        /** @private */
        public var url : URLRequest;
        /** @private */
        public var _id : String;
        /** @private */
        public var _uid : String;
        /** @private */
        public var _additionIndex : int ;
        /** @private */
        public var _priority : int = 0;
        /** @private */
        
        ///**Indicated if item is loaded and ready to use..*/
        /** @private */
        public var _isLoaded : Boolean;
        /**Indicated if loading has stated.
        * @private 
        */
        public var _isLoading : Boolean;
        
        /** @private 
        *   At what stage this item is at ( canceled, started, finished or error).
        */
        public var status : String;
        // 
        /** @private 
        *   Maximun number of tries in case it fails.
        *   */
        public var maxTries : int = 3;
        /**Current try number.
        *   @private
        */
        public var numTries : int = 0;
        
        /**A relative unit of size, so that preloaders can show relative progress before all connections have started.
        * @private
        */
        public var weight : int = 1;
        /**If a random string should be appended to the end of the url to prevent caching.
        *   @private
        */
        public var preventCache : Boolean;
        /**the number of bytes to load. Starts at -1.
        *   @private
        */
        public var _bytesTotal : int = -1;
        /**the number of bytes loaded so far. Starts at -1.
        * @private
        */
        public var _bytesLoaded : int = 0;
        /** @private */
        public var _bytesRemaining : int = 10000000;
        /**The percentage of loading done (from 0 to 1).
        * @private   
        */
        public var _percentLoaded : Number;
        /**The percentage of loading done relative to the weight of this item(from 0 to 1).
        *   @private
        */
        public var _weightPercentLoaded : Number;
        /**
        *   @private
        */
        public var _addedTime : int ;
        /** @private */
        public var _startTime : int ;
        /** @private */
        public var _responseTime : Number;
        /** The time (in seconds) that the server took and send begin streaming content.
            @private
        */
        public var _latency : Number;
        /** @private */
        public var _totalTime : int;
        /** The total time (in seconds) this item took to load.*/
        public var _timeToDownload : Number;
        /** The speed (in kbs) for this download.
        *   @private
        *   */
        public var _speed : Number;
        /** @private */
        public var _content : *;
        /** @private */
        public var _httpStatus : int = -1;
        /**
        *   @private
        */
        public var _context : * = null;
		/**
		 *	@private
		 */
		public var _parsedURL : SmartURL
        /** @private */
        public var specificAvailableProps : Array ;
        /** @private */
        public var propertyParsingErrors : Array;
        
        /** Stores any erros (if any), such as IOError and SecurityError for this item */
        public var errorEvent : ErrorEvent;
        
        public function LoadingItem(url : URLRequest, type : String, _uid : String){
            this._type = type;
            this.url = url;
			_parsedURL = new SmartURL(url.url);
            if(!specificAvailableProps){
                specificAvailableProps = [];
            }
            this._uid = _uid;
        }
        
        /**
        *   @private
        */
        public function _parseOptions(props : Object)  : Array{
            preventCache = props[BulkLoader.PREVENT_CACHING];
            _id = props[BulkLoader.ID];
            _priority = int(props[BulkLoader.PRIORITY]) || 0;
            maxTries = props[BulkLoader.MAX_TRIES] || 3;
            weight = int(props[BulkLoader.WEIGHT]) || 1;
            
            // checks that we are not adding any inexistent props, aka, typos on props :
            var allowedProps : Array = BulkLoader.GENERAL_AVAILABLE_PROPS.concat(specificAvailableProps);
            propertyParsingErrors = [];
            for (var propName :String in props){
                
                if (allowedProps.indexOf(propName) == -1){
                    propertyParsingErrors.push(this + ": got a wrong property name: " + propName + ", with value:" + props[propName]);
                }
            }
            return propertyParsingErrors;
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
        public function load() : void{
            if (preventCache){
                var cacheString : String = "BulkLoaderNoCache=" + _uid + "_" + int(Math.random()  * 100 * getTimer());
                if(url.url.indexOf("?") == -1){
                    url.url += "?" + cacheString;
                }else{
                    url.url += "&" + cacheString;
                }
            }
            _isLoading = true;
            _startTime = getTimer();
        }
        
        /**
        *   @private
        */
        public function onHttpStatusHandler(evt : HTTPStatusEvent) : void{
            _httpStatus = evt.status;
            dispatchEvent(evt);
        }
        
        /**
        *   @private
        */
        public function onProgressHandler(evt : *) : void {
           _bytesLoaded = evt.bytesLoaded;
           _bytesTotal = evt.bytesTotal;
           _bytesRemaining = _bytesTotal - bytesLoaded;
           _percentLoaded = _bytesLoaded / _bytesTotal;
           _weightPercentLoaded = _percentLoaded * weight;
           dispatchEvent(evt);
        }
        
        
        /**
        *   @private
        */
        public function onCompleteHandler(evt : Event) : void {
            _totalTime = getTimer();
            _timeToDownload = ((_totalTime - _responseTime) /1000);
            if(_timeToDownload == 0){
                _timeToDownload = 0.1;
            }
            _speed = BulkLoader.truncateNumber((bytesTotal / 1024) / (_timeToDownload));
           status = STATUS_FINISHED;
           _isLoaded = true;
           dispatchEvent(evt);
           evt.stopPropagation();
        }
        /**
        *   @private
        */
        public function onErrorHandler(evt : ErrorEvent) : void{
            numTries ++;
             
            evt.stopPropagation();
            if(numTries < maxTries){
                status = null
                load();
            }else{
                status = STATUS_ERROR;
                errorEvent = evt;
                _dispatchErrorEvent(errorEvent);
            }
        }
        
        /** @private
        */
        public function _dispatchErrorEvent (evt : ErrorEvent) : void{
            // we are dispatching here so we can have all error events catched by addEventListener("error"), regardless of event type.
            status = STATUS_ERROR;
            dispatchEvent(new ErrorEvent(BulkLoader.ERROR, true, false, evt.text));
        }
        /** private
        */
        public function _createErrorEvent(e : Error) : ErrorEvent{
            return new ErrorEvent(BulkLoader.ERROR, false, false, e.message);
        }
        /**
        *   @private
        * @param A SecurityErrorEvent.
        */
        public function onSecurityErrorHandler(e : ErrorEvent) : void{
            status = STATUS_ERROR;   
            errorEvent = e as ErrorEvent;
            e.stopPropagation();
        	_dispatchErrorEvent(errorEvent);
        }
        
        /**
        *   @private
        */
        public function onStartedHandler(evt : Event) : void{
            _responseTime = getTimer();
            _latency = BulkLoader.truncateNumber((_responseTime - _startTime)/1000);
            status = STATUS_STARTED;
            dispatchEvent(evt);
        }
        
        public override function toString() : String{
            return "LoadingItem url: " + url.url + ", type:" + _type + ", status: " + status;
        }
        
        /**
        *   @private
        */
        public  function stop() : void{
            if(_isLoaded){
                return;
            }
            status = STATUS_STOPPED;
            _isLoading = false;
        }
        /**
        *   @private
        */
        public  function cleanListeners() : void {
        }
        
        
        /** Returns true if content is of type video.
        */
        public function isVideo(): Boolean{
            return false;
        }
        
        /** Returns true if content is of type sound.
        */
        public function isSound(): Boolean{
            return false;
        }
        
        /** Returns true if content is of type text.
        */
        public function isText(): Boolean{
            return false;
        }
        /** Returns true if content is of type xml.
        */
        public function isXML(): Boolean{
            return false;
        }
        /** Returns true if content is of type image.
        */        
        public function isImage() : Boolean{
            return false;
        }
        /** Returns true if content is of type movieclip.
        */
        public function isSWF() : Boolean{
            return false;
        }
        /** Returns true if uses a Loader instance internally. (such as swfs and images).
        */
        public function isLoader(): Boolean{
            return false;
        }
        /** Returns true if this loading type should allow it's  content  to be accessed as soon as the server response starts. Should be true for sound and video types.
        */
        public function isStreamable() : Boolean{
            return false;
        }
        
        /**
        *   @private
        */
        public function destroy() : void{
            _content = null;
            //loader = null;
        }
        
        
        /** Public accessors
        *   @private
        */
        public function get bytesTotal() : int { 
            return _bytesTotal; 
        }
        
        /**
        *   @private
        */
        public function get bytesLoaded() : int { 
            return _bytesLoaded; 
        }
        
        /**
        *   @private
        */
        public function get bytesRemaining() : int { 
            return _bytesRemaining; 
        }
        
        /**
        *   @private
        */
        public function get percentLoaded() : Number { 
            return _percentLoaded; 
        }
        
        /**
        *   @private
        */
        public function get weightPercentLoaded() : Number { 
            return _weightPercentLoaded; 
        }
        /** The priority at which this item will be downloaded. Items with a higher priority will be downloaded first.
        *   @private
        */
        public function get priority() : int { 
            return _priority; 
        }
        
        /** The type of this item.
        *   @see BulkLoader.AVAILABLE_EXTENSIONS
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
        
		/** The hostname, as a string for this item's URL. If no hostname is specified, then an empty string is returned
		*/
		public function get hostName():String
		{
			return _parsedURL.host;
		}
		
		public function get humanFiriendlySize():String
		{
			var kb : Number = _bytesTotal/1024;
			if (kb < 1024){
				return int(kb) + " kb"
			}else{
				return (kb/1024).toPrecision(3) + " mb"
			}
		}
        /** Returns a string with time stats for this loading item.
        */
        public function getStats() : String{
            return "Item url: " + url.url + 
            "(s), total time: " + (_totalTime/1000).toPrecision(3) +
			"(s), download time: " + (_timeToDownload).toPrecision(3) +
            "(s), latency:" + _latency +
            "(s), speed: " + _speed + 
            " kb/s, size: " + humanFiriendlySize;
        }
}}
