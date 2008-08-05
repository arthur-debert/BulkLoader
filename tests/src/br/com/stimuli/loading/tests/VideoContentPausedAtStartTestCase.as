package br.com.stimuli.loading.tests {
	import asunit.framework.*;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
	import flash.net.*;
	import flash.utils.getTimer;
    /**@private*/
	public class VideoContentPausedAtStartTestCase extends AsynchronousTestCase {
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var startEventFiredTime : Number;
		public var netStreamAtStart : NetStream;
		public var name : String;
		public var canBeginPlayingCount : int = 0;
		
		// Override the run method and begin the request for remote data
		public function VideoContentPausedAtStartTestCase(name: String) : void {
		  super(name);
		  this.name = name;
		}
		
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true, preventCache:true});
	 		_bulkLoader.get("the-movie").addEventListener(BulkLoader.OPEN, onVideoStartHandler);
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
            _bulkLoader.get("the-movie").addEventListener(BulkLoader.CAN_BEGIN_PLAYING, onHasBeginPlayerFiredHandler);
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
			var current :Number = Math.floor((event as Object).percentLoaded * 100) /100;
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

		public function onHasBeginPlayerFiredHandler(event : Event) : void{
		    canBeginPlayingCount ++;
		}
		
		protected function onVideoStartHandler(evt : Event) : void{
		    startEventFiredTime = getTimer();
		    netStreamAtStart = evt.target.content;
		}

		protected override function setUp():void {

		}

		protected override function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.getNetStream("the-movie").close();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
		}

		public function testVideoPausedAtStart():void {
            assertTrue(netStreamAtStart.time < 0.1);
		}
        
        public function testCanBeginPlayingEvent() : void{
            assertEquals(canBeginPlayingCount, 1);
        }
	}
}