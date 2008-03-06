package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import flash.utils.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class PauseAllResumeTest extends AsynchronousTestCase {
		public var _bulkLoader1 : BulkLoader;
		public var _bulkLoader2 : BulkLoader;
		public var lastProgress : Number = 0;
        public var progresses1 : Array = [];
        public var progresses2 : Array = [];
        
		public var name : String;
		public var ioError : Event;
		
		public var timer : Timer;
		public function PauseAllResumeTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader1= new BulkLoader(BulkLoader.getUniqueName(), 1, BulkLoader.LOG_ERRORS)
            _bulkLoader1.add("http://www.emptywhite.com/bulkloader-assets/large-file.txt", {"priority":-200, id:"text", "preventCache":true});
            _bulkLoader1.addEventListener(BulkLoader.ERROR, onError);
            _bulkLoader1.addEventListener(BulkLoader.PROGRESS, progressHandler);
            _bulkLoader1.start();
            
            _bulkLoader2= new BulkLoader(BulkLoader.getUniqueName(), 1, BulkLoader.LOG_ERRORS)
            _bulkLoader2.add("http://www.emptywhite.com/bulkloader-assets/large-file.xml", {"priority":200, id:"xml","preventCache":true });
	 		//_bulkLoader1.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		
	 		_bulkLoader2.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		_bulkLoader2.addEventListener(BulkLoader.ERROR, onError);
            
            _bulkLoader2.start();
		}

        public function onError(evt : BulkErrorEvent) : void{
            ioError = evt;
            // are we all set?
            tearDown();
            // call the on complete manually 
            
            
        }
        
		protected override function completeHandler(event:Event):void {
		    _bulkLoader1.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader2.removeEventListener(BulkLoader.COMPLETE, completeHandler);
			super.run();
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current :Number = Math.floor((event as Object).percentLoaded * 100) /100;
			var delta : Number = current - lastProgress;
			
			if (event.target ==_bulkLoader1){
		        progresses1.push(event.bytesLoaded);
		        
		    }else if (event.target ==_bulkLoader2){
		        progresses2.push(event.bytesLoaded);
		        
		    }
		    if (progresses1.length > 0 && progresses2.length > 0){
		        _bulkLoader1.removeEventListener(BulkLoader.PROGRESS, progressHandler);
		        _bulkLoader2.removeEventListener(BulkLoader.PROGRESS, progressHandler);
		        BulkLoader.pauseAllLoaders();
		        progresses2[0] = _bulkLoader2.items[0].bytesLoaded;
		        progresses1[0] = _bulkLoader1.items[0].bytesLoaded;
		        timer = new Timer(2000, 1);
		        timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);
		        timer.start();
		        //completeHandler(event);
		    }
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
		
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			BulkLoader.removeAllLoaders();	
		}
		
		public function testItemsArePaused() : void{
		    assertEquals(_bulkLoader1.items[0].bytesLoaded, progresses1[progresses1.length-1]);
            assertEquals(_bulkLoader2.items[0].bytesLoaded, progresses2[progresses2.length-1]);
            
            assertEquals(_bulkLoader1.items[0].status, LoadingItem.STATUS_STOPPED);
            assertEquals(_bulkLoader2.items[0].status, LoadingItem.STATUS_STOPPED);
            
            
            // now check bytes!
		}
		
		public function testResumeAll():void{
		    _bulkLoader1.resumeAll();
		    _bulkLoader2.resumeAll();
            assertTrue(_bulkLoader1.items[0].status != LoadingItem.STATUS_STOPPED);
            assertTrue(_bulkLoader2.items[0].status != LoadingItem.STATUS_STOPPED);
		}
		}
}