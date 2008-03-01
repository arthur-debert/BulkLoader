package br.com.stimuli.loading.tests {
	import asunit.framework.*;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
	import flash.media.Sound;
    /**@private*/
	public class AudioContentTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var sound : Sound;
		public var sound1 : Sound;
		
		public var ioError : Event;
		public var name : String;
		public function AudioContentTest(name : String) : void {
		  super(name);
		  this.name  = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName());
            var goodSoundURL : String = "http://www.emptywhite.com/bulkloader-assets/chopin.mp3";
            var badSoundURL : String = "http://www.emptywhite.com/bulkloader-assets/badchopin.mp3"
            var theURL : String = goodSoundURL;
            if (this.name == 'testIOError'){
                theURL = badSoundURL;
            }
	 		var item : LoadingItem = _bulkLoader.add(theURL, {id:"the-sound"});
	 		item.addEventListener(BulkLoader.OPEN, onAudioStartLoading);
	 		item.addEventListener(BulkLoader.ERROR, onIOError);
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
        
		protected override function completeHandler(event:Event):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			super.run();
		}
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
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
		protected override function setUp():void {
		}
		
		
		protected override function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.removeAll();
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
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("the-sound")._isLoaded);
        }
        
	}
}