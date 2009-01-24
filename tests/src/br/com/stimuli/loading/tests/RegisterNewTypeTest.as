package br.com.stimuli.loading.tests {
	import br.com.stimuli.kisstest.TestCase;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
    /**@private*/
	public class RegisterNewTypeTest extends TestCase { public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var registerSuccess : Boolean = false;
		public var ioError : Event;
		
		public function RegisterNewTypeTest(name : String) : void {
		  super(name);
		  this.name  = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
		    registerSuccess = BulkLoader.registerNewType( "json", "JSON", JSONItem) ;
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName());
	 		var item : LoadingItem = _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/lazyloader.json", {id:"json"});
	 		_bulkLoader.add( "http://www.emptywhite.com/bulkloader-assets/some-text.txt", {"id":"text"});
	 		_bulkLoader.addEventListener(BulkLoader.ERROR, onIOError);
	 		
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
			var current : Number = Math.floor((event as Object).percentLoaded * 100) /100;
			if (current > lastProgress){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}
			for each(var propName : String in ["percentLoaded", "weightPercent", "ratioLoaded"] ){
			    if (isNaN(event[propName]) ){
			        trace(propName, "is not a number" );
			        assertFalse(isNaN(event[propName]));
			    }
			}
			//trace("event", (event as Object).percentLoaded, current);
		}

		public function testJSONContent () : void{
		    var cont : Object = _bulkLoader.getContent("json");
		    assertEquals(cont.name, "lazyTest");
		}
		
		public function testOtherItemType () : void{
		    var li : LoadingItem = _bulkLoader.get("text");
		    assertTrue(li is URLItem);
		}
		
		public function testNewType () : void{
		    var li : LoadingItem = _bulkLoader.get("json");
		    assertTrue(li is JSONItem);
		}
		
		public function testMultipleAdds() : void {
		    var success : Boolean = BulkLoader.registerNewType( "json", "JSON", JSONItem) ;
		    assertFalse(success);
		}
		
		
		override public function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
		}
		
		       
	}
}