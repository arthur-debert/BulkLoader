package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import kisstest.TestCase; import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
    /**@private*/
	public class ResumeTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
        public var neverStopped : Boolean;
		
		public var ioError : Event;
		public var timer : Timer;
		public function ResumeTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/large-file.txt";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-text.txt"
            var theURL : String = goodURL;
            if (this.name == 'testIOError'){
                theURL = badURL;
            }
            
	 		_bulkLoader.add(theURL, {id:"text", "preventCache":true});
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
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		public function doResume(evt : Event) : void{
		    _bulkLoader.resume("text");
		    
		}
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    if(!_bulkLoader.get("text").status != LoadingItem.STATUS_STOPPED && neverStopped){
		        _bulkLoader.get("text").stop();
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
		
		
		override public function setUp():void {

		}
		
		override public function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testResume():void {
		    var item : LoadingItem = _bulkLoader.get("text");
		    assertNotNull(item);
		    assertTrue(item.status == LoadingItem.STATUS_FINISHED);
		    assertNotNull(_bulkLoader.getText("text"));
		}
		
	}
}