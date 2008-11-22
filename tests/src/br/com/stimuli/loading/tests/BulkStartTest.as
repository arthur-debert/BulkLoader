package br.com.stimuli.loading.tests {
	import asunit.framework.*;
	
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
    /**@private*/
	public class BulkStartTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public var ioError : Event;
		
		public var theLogLevel : int = 10;
		public function BulkStartTest(name: String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName(), -1, theLogLevel);
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/shoes.jpg";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-image.jpg"
            var theURL : String = goodURL;
            if (this.name == 'testIOError'){
                theURL = badURL;
            }
            
	 		_bulkLoader.add(theURL, {id:"photo"});
            _bulkLoader.get("photo").addEventListener(BulkLoader.ERROR, onIOError);
	 		
            completeHandler(new Event("dummy"))
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
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
		
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testIsRunningOnStart() : void{
		    _bulkLoader.start();
		    assertTrue(_bulkLoader.isRunning);
		}
		
		public function testStartCanChangeConnections():void {
		    var oldConnectionsNumber : int = _bulkLoader._numConnections;
		    _bulkLoader.start(2);
		    assertFalse(oldConnectionsNumber ==  _bulkLoader._numConnections)
		}
		
		public function testCorrectLogLevel() : void{
		    assertEquals(_bulkLoader.logLevel, theLogLevel)
		}
		
    }
}