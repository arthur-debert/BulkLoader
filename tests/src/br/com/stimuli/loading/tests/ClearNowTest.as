package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import br.com.stimuli.kisstest.TestCase;
    import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class ClearNowTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;

		public function ClearNowTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/movie.flv";
            var theURL : String = goodURL;
            
	 		_bulkLoader.add(theURL, {id:"bad"});
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.removeAll();
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.txt", {id:"text"});
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
        
		public function completeHandler(event:Event):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
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
				

		
		override public function tearDown():void {
		    _bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testLoadHasItem():void {
		    assertNotNull(BulkLoader.whichLoaderHasItem("text"));
		}
		
		public function testClearAllHideKeys():void {
		    _bulkLoader.clear();
		    assertNull(BulkLoader.whichLoaderHasItem("text"));
		}
		
		public function testClearAllThrowsError() : void{
		    var theError : Error;
		    _bulkLoader.clear();
		    try{
		        _bulkLoader.add("some");
		    }catch(e : Error){
		        theError = e;
		    }
		    assertNotNull(theError);
		}
		
		public function testClearAllIsSafe() : void{
		    var theError : Error;
		    _bulkLoader.clear();
		    try{
		        _bulkLoader.clear()
		    }catch(e : Error){
		        theError = e;
		    }
		    assertNull(theError);
		}
	}
}