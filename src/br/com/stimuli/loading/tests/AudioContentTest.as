package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

	public class AsynchronousTestCaseExample extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public function AsynchronousTestCaseExample(name) : void {
		  super(name);
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
		    trace("run");
            _bulkLoader = new BulkLoader("assync-test");
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {id:"the-sound"});
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
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
			    trace("\n", current * 100 , "% loaded") ;
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
		    trace("setup");
		}
		
		protected override function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.removeAll();
		}
		
		public function testVideoContent():void {
		    var videoItem : * = _bulkLoader.getNetStream("the-movie");
		    assertNotNull(videoItem);
		}
		
		public function testSoundContent():void {
            var soundItem : * = _bulkLoader.getSound("the-sound");
		    assertNotNull(soundItem);
		}
	}
}