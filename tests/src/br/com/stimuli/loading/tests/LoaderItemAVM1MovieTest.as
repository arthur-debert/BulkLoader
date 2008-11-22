package br.com.stimuli.loading.tests {
	import kisstest.TestCase
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
    
    /**@private*/
	public class LoaderItemAVM1MovieTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public function LoaderItemAVM1MovieTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/avm1movie.swf", {id:"avm1movie"});
	 		
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
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
		
		

		
		override public function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
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
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("avm1movie")._isLoaded)
        }
        
            
        
	}
}