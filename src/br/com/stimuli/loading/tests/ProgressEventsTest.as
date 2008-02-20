package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.*;

	public class ProgressEventsTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public var ioError : Event;
		public function ProgressEventsTest(name) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/samplexml.xml";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-samplexml.xml"
            var theURL : String = goodURL;
            if (this.name == 'testIOError'){
                theURL = badURL;
            }
            
	 		_bulkLoader.add(theURL, {id:"text"});
            _bulkLoader.get("text").addEventListener(BulkLoader.ERROR, onIOError);
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {id:"photo"});

	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
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
			var current = Math.floor((event as Object).percentLoaded * 100) /100;
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
			_bulkLoader.removeAll();	
		}
		
		public function testGetProgressForItems() : void{
		    _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {id:"sound"});
            var e : BulkProgressEvent = _bulkLoader.getProgressForItems(["text", "photo"]);
            assertNotNull(e);
        }
        
        public function testGetProgressForItemsPercentLoaded() : void{
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {id:"sound"});
            var e : BulkProgressEvent = _bulkLoader.getProgressForItems(["text", "photo"]);
            assertEquals(e.percentLoaded,1);
        }
        
        public function testGetProgressForItemsRatioLoaded() : void{
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3", {id:"sound"});
            var e : BulkProgressEvent = _bulkLoader.getProgressForItems(["text", "photo"]);
            assertEquals(e.ratioLoaded,1);
        }
	}
}