package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import br.com.stimuli.kisstest.TestCase;
import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class ResumeAllTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
        public var neverStopped : Boolean;
		
		public var ioError : Event;
		public var timer : Timer;
		public function ResumeAllTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/large-file.txt";
            
	 		_bulkLoader.add(goodURL, {id:"text", "preventCache":true});
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/large-file.xml", {id:"xml", "preventCache":true});
            _bulkLoader.get("text").addEventListener(BulkLoader.ERROR, onIOError);
	 		
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
		    //trace(_bulkLoader.getStats());
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		public function doResume(evt : Event) : void{
		    _bulkLoader.resumeAll();
		    
		}
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    if(!_bulkLoader.get("text").status != LoadingItem.STATUS_STOPPED && neverStopped){
		        _bulkLoader.pauseAll();
		        timer = new Timer(1000, 1);
		        timer.addEventListener(TimerEvent.TIMER_COMPLETE, doResume);
		        timer.start();
		        neverStopped = false;
		    }
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
		
		public function testResumeAll():void {
		    var keysToCheck : Array = ["text", "xml"];
		    keysToCheck.forEach(function(key:String, ...rest):void{
		        var item : LoadingItem = _bulkLoader.get(key);
    		    assertNotNull(item);
    		    assertTrue(item.status == LoadingItem.STATUS_FINISHED);
    		    assertTrue(_bulkLoader.get(key).content.toString().length > 200);
		    });
		    
		}
		
	}
}