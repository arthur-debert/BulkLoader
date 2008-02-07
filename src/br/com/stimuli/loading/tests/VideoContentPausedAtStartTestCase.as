package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
    import flash.utils.getTimer;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

	public class VideoContentPausedAtStartTestCase extends AsynchronousTestCase {
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var startEventFiredTime : Number;
		public var netStreamAtStart : NetStream;
		public var name : String;
		// Override the run method and begin the request for remote data
		public function VideoContentPausedAtStartTestCase(name) : void {
		  super(name);
		}
		
		public override function run():void {
            _bulkLoader = new BulkLoader("assync-test");
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
	 		_bulkLoader.get("the-movie").addEventListener(BulkLoader.OPEN, onVideoStartHandler);
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
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    trace(current * 100 , "% loaded") ;
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

		protected override function setUp():void {

		}

		protected override function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.getNetStream("the-movie").close();
			_bulkLoader.removeAll();
		}

		public function testVideoPausedAtStart():void {
            assertEquals(netStreamAtStart.time , 0);
		}

	}
}