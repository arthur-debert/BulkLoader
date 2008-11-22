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
	public class OnCompleteTest extends TestCase { public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		public var dispatchedProgressAfterComplete : Boolean = false;
		public var numOfDispatches : int = 0;
		public var hasCompleted : Boolean ;
		
		public var timer: Timer;
		public function OnCompleteTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/some-text.txt";
            var preventCache : Boolean = false
            if (this.name == 'testWihNoCache'){
                 preventCache = true;
            }
            
	 		_bulkLoader.add(goodURL, {id:"text", preventCache: preventCache});
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {id:"xml", preventCache: preventCache});
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
		    numOfDispatches ++;
		    hasCompleted = true;
		    timer = new Timer(2000, 1);
		    timer.addEventListener( TimerEvent.TIMER_COMPLETE, runWrapper)
			timer.start();
		}
		
		public function runWrapper(evt : Event) : void{
		    dispatchEvent(new Event(Event.INIT));
		}
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
		    if(hasCompleted){
		        dispatchedProgressAfterComplete = true;
		    }
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
		
		public function testOnCompleteFiredOnlyOnce():void {
		    
		    assertEquals(numOfDispatches,1);
		}
		
        
        public function testItemIsLoaded() : void{
            assertFalse(dispatchedProgressAfterComplete)
        }
        
        public function testWihNoCache() : void{
            assertFalse(dispatchedProgressAfterComplete);
            assertEquals(numOfDispatches,1);
        }
	}
}