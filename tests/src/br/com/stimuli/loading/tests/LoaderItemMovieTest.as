package br.com.stimuli.loading.tests {
	import br.com.stimuli.kisstest.TestCase;
	import br.com.stimuli.loading.*;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.getTimer;
    
    /**@private*/
	public class LoaderItemMovieTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
        public var initTime : int = -1;
        public var completeTime : int = -1;
		
		public function LoaderItemMovieTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		var item : ImageItem = _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/avm2-movie.swf", {id:"avm2movie"}) as ImageItem;
	 		item.addEventListener(Event.INIT, onInit, false, 0, true);
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandlerBP);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

        public function onInit(evt : Event) : void{
            initTime = getTimer();
        }
        
		protected  function completeHandlerBP(event:BulkProgressEvent):void {
		    completeTime = getTimer();
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandlerBP);
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
		    _bulkLoader.clear();
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
        
        public function testInitFired() : void{
            assertTrue(initTime > 0);
            assertTrue(initTime >= completeTime);
        }    
        
	}
}