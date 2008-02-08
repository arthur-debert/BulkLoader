package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.media.Sound;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

	public class AudioContentTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var sound : Sound;
		public var sound1 : Sound;
		public function AudioContentTest(name) : void {
		  super(name);
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader("assync-test");
	 		var item : LoadingItem = _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {id:"the-sound"});
	 		item.addEventListener(BulkLoader.OPEN, onAudioStartLoading);
	 		//_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

		protected override function completeHandler(event:Event):void {
			super.run();
		}
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current = Math.floor((event as Object).percentLoaded * 100) /100;
			if (current > lastProgress){
			    lastProgress = current;
			    trace( current * 100 , "% loaded") ;
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
	}
}