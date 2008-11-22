package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import kisstest.TestCase;
import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class RemoveAllTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		
        public var timer : Timer
		public function RemoveAllTest(name : String) : void {
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
	 		//_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		//_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		timer = new Timer (3000, 1);
	 		timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeRemove );
	 		timer.start();
		}

        public function onTimeRemove(evt : Event) : void{
            timer.stop();
            _bulkLoader.removeAll();
            var fileName : String ;
            for (var i:int = 11; i<21; i++){
                fileName = "small-" + (i < 10 ? "0" + i : i) + ".jpg";
                _bulkLoader.add("{base_path}" + fileName, {id:String(i)});
            }
            _bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
            if (name == "testLoadAfterRemoveWithStart"){
                _bulkLoader.start();
            }
        }
        
        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
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
		
		public function testLoadAfterRemove():void {
		    for (var i:int = 0; i<11; i++){
		      assertNull(_bulkLoader.get(String(i)));
		    }
		    for (i = 11; i<21; i++){
		      assertNotNull(_bulkLoader.get(String(i)));
		    }
		    
		 }
		 
		 public function testLoadAfterRemoveWithStart():void {
 		    for (var i:int = 0; i<11; i++){
 		      assertNull(_bulkLoader.get(String(i)));
 		    }
 		    for (i = 11; i<21; i++){
 		      assertNotNull(_bulkLoader.get(String(i)));
 		    }

 		 }
	}
}