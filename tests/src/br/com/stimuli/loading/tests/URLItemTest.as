package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import kisstest.TestCase;
import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class URLItemTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		public function URLItemTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/some-text.txt";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-text.txt"
            var theURL : String = goodURL;
            if (this.name == 'testIOError'){
                theURL = badURL;
            }
            
	 		_bulkLoader.add(theURL, {id:"text"});
            _bulkLoader.get("text").addEventListener(BulkLoader.ERROR, onIOError);
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            
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
		
		public function testContentExists():void {
		    var item : String = _bulkLoader.getText("text");
		    assertNotNull(item);
		}
		
        public function testContent() : void{
            var item : String = _bulkLoader.getText("text");
		    assertTrue(item == "hello bulk!");

        }
        
        public function testDefaultGetType() : void{
            var item : * = _bulkLoader.getContent("text");
		    assertTrue(item is String);
        }
        
        public function testClearMemoryRemovesItem(): void{
            var item : String = _bulkLoader.getContent("text", true) ;
		    assertNotNull(item);
            // now try again
            item = _bulkLoader.getContent("text");
            assertNull(item);
        }
        
        public function testGetHTTPStatusFromItem() :void{
            var item : * = _bulkLoader.get("text");
            assertTrue(item.httpStatus  > -1 );
        }
        
        public function testGetHTTPStatusFromLoader() :void{
            assertTrue(_bulkLoader.getHttpStatus("text")  > -1 );
        }
        
        public function testIOError() : void{
            assertNotNull(ioError);
        }
        
        public function testItemIsLoaded() : void{
            assertTrue(_bulkLoader.get("text").isLoaded)
        }
	}
}