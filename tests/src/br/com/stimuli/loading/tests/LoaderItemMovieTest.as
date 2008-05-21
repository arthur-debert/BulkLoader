package br.com.stimuli.loading.tests {
	import asunit.framework.*;
	
	import br.com.stimuli.loading.*;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
    
    /**@private*/
	public class LoaderItemMovieTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public function LoaderItemMovieTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/avm2-movie.swf", {id:"avm2movie"});
	 		
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandlerBP);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

		protected  function completeHandlerBP(event:BulkProgressEvent):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandlerBP);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			super.run();
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
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
		
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			_bulkLoader.removeAll();	
		}
		
		public function testGetavm2movie():void {
		    var item : MovieClip = _bulkLoader.getMovieClip("avm2movie");
		    assertNotNull(item);
		}
		
        public function testIsavm2movie() : void{
            var item : * = _bulkLoader.getContent("avm2movie");
		    assertTrue(item is MovieClip);
        }
        
        public function testIsSWF() : void{
            var item : * = _bulkLoader.get("avm2movie");
		    assertTrue(item.isSWF());
        }
        
        public function testHasAlpha() : void{
            var item : MovieClip = _bulkLoader.getMovieClip("avm2movie");
		    assertTrue(item.alpha is Number);
        }
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("avm2movie")._isLoaded)
        }
        
            
        
	}
}