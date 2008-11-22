package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import kisstest.TestCase; import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class RemoveFailedItemTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		public function RemoveFailedItemTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/bad-some-text.jpg", {"priority":-200, id:"text"});
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/badshoes.jpg", {"priority":-200, id:"photo"});
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/bad-samplexm l.xml", {"priority":200, id:"xml"});
            _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/bad.xml", {"priority":200, id:"xml2"});

	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		_bulkLoader.addEventListener(BulkLoader.ERROR, onError);
            _bulkLoader.start();
		}

        public function onError(evt : BulkErrorEvent) : void{
            ioError = evt;
            // are we all set?
            var allFailed : Boolean = evt.errors.length == _bulkLoader.items.length;
            if(allFailed){
                completeHandler(evt);
                tearDown();
            }
            // call the on complete manually 
            
            
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
		
		
		override public function setUp():void {

		}
		
		override public function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testRemoveFailed() : void {
		  _bulkLoader.removeFailedItems();
		  assertTrue(_bulkLoader.items.length == 0);
		}
		
		public function testRemoveAllKeepsOtherItems():void{
		    _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/chopin.mp3")
		    _bulkLoader.removeFailedItems();
    		assertTrue(_bulkLoader.items.length == 1);
		}
		
		public function testItemsToalAfterRemoveFailed() : void{
		    _bulkLoader.removeFailedItems();
		    assertEquals(_bulkLoader._itemsTotal, 0);
		    
		}
		
		public function testContentAfterRemoveAll():void{
		    var numItems : int = 0;
		    for (var prop:String in _bulkLoader._contents){
		        numItems ++;
		    }
		    // how many items in contents
		    assertEquals(0, numItems);
		}
		}
}