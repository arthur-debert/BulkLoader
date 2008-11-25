package br.com.stimuli.loading.tests {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.getTimer;
	
	import br.com.stimuli.kisstest.TestCase;
    /**@private*/
	public class VideoContentTest extends TestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var startEventFiredTime : Number;
		public var canBeginPlayingCount : int = 0;
		public var netStreamAtStart : NetStream;
		
		public var ioError : Event;
		public var ioErrorCount : int = 0;
		public function VideoContentTest(name: String) : void {
		  super(name);
		  this.name= name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader  = new BulkLoader(BulkLoader.getUniqueName());
            
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/movie.flv";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-movie.flv"
            var theURL : String = goodURL;
            if (this.name.indexOf( 'testIOError') >  -1){
                theURL = badURL;
            }
        
	 		
	 		_bulkLoader.add(theURL, {id:"the-movie", checkPolicyFile:true});
	 		_bulkLoader.get("the-movie").addEventListener(BulkLoader.OPEN, onVideoStartHandler);
	 		if (this.name != "testIOErrorOnBulkLoader"){
	 		    _bulkLoader.get("the-movie").addEventListener(BulkLoader.ERROR, onIOError);
	 		}else{
	 		    _bulkLoader.addEventListener(BulkLoader.ERROR, onIOError);
	 		}
	 		
	 		_bulkLoader.get("the-movie").addEventListener(BulkLoader.CAN_BEGIN_PLAYING, onHasBeginPlayerFiredHandler);
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            ioErrorCount ++;  
            // call the on complete manually 
            completeHandler(evt);
            
        }
        
		public function completeHandler(event:Event):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		public function onHasBeginPlayerFiredHandler(event : Event) : void{
		    canBeginPlayingCount ++;
		}
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current :Number= Math.floor((event as Object).percentLoaded * 100) /100;
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}
			for each(var propName : String in ["percentLoaded", "weightPercent", "ratioLoaded"] ){
			    if (isNaN(event[propName]) ){
			        trace(propName, "is not a number" );
			        assertFalse(isNaN(event[propName]));
			    }
			}
		}
		
		protected function onVideoStartHandler(evt : Event) : void{
		    startEventFiredTime = getTimer();
		    netStreamAtStart = evt.target.content;
		}
		
		
		
		override public function tearDown():void {
			_bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
		}
		
		public function testVideoContent():void {
		    var videoItem : * = _bulkLoader.getNetStream("the-movie");
		    assertNotNull(videoItem);
		}
		
        public function testVideoMetadata() : void{
            var metadata : * = _bulkLoader.getNetStreamMetaData("the-movie");
            assertNotNull(metadata);
        }
        
        public function testVideoMetadataFromVideoItem() : void{
            var videoItem : VideoItem = _bulkLoader.get("the-movie") as VideoItem;
            var metadata : Object = videoItem.metaData;
            assertNotNull(metadata);
            assertNotNull(metadata.duration);
        }
        
        public function testStartEventFired() : void{
            assertNotNull(startEventFiredTime);
        }
        
        public function testNetStreamAvailableFromStart() : void{
            assertNotNull(netStreamAtStart);
        }
        
        public function testVideoIsNotPaused() : void{
            assertTrue(netStreamAtStart.time > 0);
        }
        
        
        public function testClearMemoryRemovesItem(): void{
            var net : NetStream = _bulkLoader.getNetStream("the-movie", true);
            assertNotNull(net);
            // now try again
            net = _bulkLoader.getNetStream("the-movie");
            assertNull(net);
        }
        
        public function testIOError() : void{
            assertNotNull(ioError);
        }
        
        public function testIOErrorOnBulkLoader() : void{
            assertNotNull(ioError);
            assertNotNull( _bulkLoader.get("the-movie").errorEvent);
            assertTrue( _bulkLoader.get("the-movie").errorEvent is ErrorEvent);
            assertEquals(ioErrorCount, 1);
        }
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("the-movie")._isLoaded)
        }
        
        public function testIsVideo() : void{
            assertTrue(_bulkLoader.get("the-movie").isVideo());
            
        }
        
        public function testCanBeginPlayingEvent() : void{
            assertEquals(canBeginPlayingCount, 1);
        }
        
        public function testCanBeginStreamingIsAlwaysTrue() : void{
            assertTrue((_bulkLoader.get("the-movie") as VideoItem).canBeginStreaming);
        }
	}
}