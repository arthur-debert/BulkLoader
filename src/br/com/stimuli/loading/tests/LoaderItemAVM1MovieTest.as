package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

	public class LoaderItemAVM1MovieTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public function LoaderItemAVM1MovieTest(name) : void {
		  super(name);
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader("assync-test");
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/avm1movie.swf", {id:"avm1movie"});
	 		
	 		
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
		
		public function testGetAVM1Movie():void {
		    var item : AVM1Movie = _bulkLoader.getAVM1Movie("avm1movie");
		    assertNotNull(item);
		}
		
        public function testIsAVM1Movie() : void{
            var item : * = _bulkLoader.getContent("avm1movie");
		    assertTrue(item is AVM1Movie);
        }
        
        public function testHasAlpha() : void{
            var item : AVM1Movie = _bulkLoader.getAVM1Movie("avm1movie");
		    assertTrue(item.alpha is Number);
        }
        

        
            
        
	}
}