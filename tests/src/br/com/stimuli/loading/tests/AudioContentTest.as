package br.com.stimuli.loading.tests {
	import br.com.stimuli.kisstest.TestCase
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
	import flash.media.Sound;
    /**@private*/
	public class AudioContentTest extends TestCase { public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var sound : Sound;
		public var sound1 : Sound;
		
		public var ioError : Event;
		
		public function AudioContentTest(name : String) : void {
		  super(name);
		  this.name  = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName());
            var goodSoundURL : String = "http://www.emptywhite.com/bulkloader-assets/sound-short.mp3";
            var badSoundURL : String = "http://www.emptywhite.com/bulkloader-assets/badchopin.mp3"
            var theURL : String = goodSoundURL;
            if (this.name.indexOf('testIOError') > -1){
                theURL = badSoundURL;
            }
	 		var item : LoadingItem = _bulkLoader.add(theURL, {id:"the-sound"});
	 		item.addEventListener(BulkLoader.OPEN, onAudioStartLoading);
	 		if (this.name != "testIOErrorOnBulkLoader"){
	 		    item.addEventListener(BulkLoader.ERROR, onIOError);
	 		}else{
	 		    _bulkLoader.addEventListener(BulkLoader.ERROR, onIOError);
	 		}
	 		
	 		//_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}
        
        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
        } 
        
		public function completeHandler(event:Event):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current : Number = Math.floor((event as Object).percentLoaded * 100) /100;
			if (current > lastProgress){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}
			for each(var propName : String in ["percentLoaded", "weightPercent", "ratioLoaded"] ){
			    if (isNaN(event[propName]) ){
			        trace(propName, "is not a number" );
			        assertFalse(isNaN(event[propName]));
			    }
			}
			//trace("event", (event as Object).percentLoaded, current);
		}

		
		
		override public function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
		}
		
		public function onAudioStartLoading(evt : Event) : void {
		    sound  = evt.target.content;
		    sound1  = _bulkLoader.getSound("the-sound");
		}
		
		public function testOpenEventWorksBothWays() : void{
		    assertNotNull(sound);


		    assertTrue(sound is Sound);
		    assertEquals(sound, sound1)
		}
		
		public function testSoundContent():void {
            var soundItem : * = _bulkLoader.getSound("the-sound");
		    assertNotNull(soundItem);
		}
        
        public function testGetHTTPStatusFromLoader() :void{
            assertEquals(_bulkLoader.getHttpStatus("the-sound"), -1);
        }
        
        public function testClearMemoryRemovesItem(): void{
            var soundItem : Sound = _bulkLoader.getSound("the-sound", true);
            assertNotNull(soundItem);
            // now try again
            soundItem = _bulkLoader.getSound("the-sound");
            assertNull(soundItem);
        }
        
        public function testIOError() : void{
            assertNotNull(ioError);
        }
        
        public function testIOErrorOnBulkLoader() : void{
            assertNotNull(ioError);
            assertNotNull( _bulkLoader.get("the-sound").errorEvent);
            assertTrue( _bulkLoader.get("the-sound").errorEvent is ErrorEvent);
        }
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("the-sound")._isLoaded);
        }
        

        public function testSaneBytesReport() : void{
                var item : LoadingItem = _bulkLoader.get("the-sound");
                assertFalse(item.bytesTotal == 0);
                assertEquals(item.bytesTotal ,item.bytesLoaded);
                assertEquals(item.bytesRemaining, 0);

        }
	}
}
