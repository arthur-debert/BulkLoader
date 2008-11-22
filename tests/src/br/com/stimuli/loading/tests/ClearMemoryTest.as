package br.com.stimuli.loading.tests {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import kisstest.TestCase;
/**@private*/
	public class ClearMemoryTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		
        public var timer : Timer
		public function ClearMemoryTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
		    var numCon : int = 1;
		    if (name == "testLoadAfterRemoveWithStart") numCon = 7;
		    
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName(), 1)
            _bulkLoader.stringSubstitutions = {
                    "base_path": "http://www.emptywhite.com/bulkloader-assets/"
            }
            var fileName : String ;
            for (var i:int = 1; i<11; i++){
                fileName = "small-" + (i < 10 ? "0" + i : "" + i) + ".jpg";
                
                _bulkLoader.add("{base_path}" + fileName, {id:String(i)});
            }
	 	
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		//_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		
		}

        
        
		public function completeHandler(event:Event):void {
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
		
		public function testItemsLoadedIsValidAfterClearMemory() : void{
		    var keys : Array = [];
 		     for each (var item : LoadingItem in _bulkLoader.items){
 		         _bulkLoader.getContent(item._id, true);
 		         keys.push(item._id);
 		     }
 		     assertEquals(_bulkLoader.itemsLoaded, 0);
 		     
 		     assertEquals(0, _bulkLoader.getProgressForItems(keys).itemsLoaded);
 		 }
	}
}