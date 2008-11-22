package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import kisstest.TestCase;
import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
    import br.com.stimuli.loading.lazyloaders.*;
/**@private*/
	public class LazyXMLInternalsTest extends TestCase { 
	    public var lazyLoader : LazyXMLLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		public function LazyXMLInternalsTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            lazyLoader = new LazyXMLLoader("http://www.emptywhite.com/bulkloader-assets/lazyloader.xml", BulkLoader.getUniqueName());
            lazyLoader.addEventListener("complete", completeHandler);
            lazyLoader.addEventListener("progress", progressHandler);
            lazyLoader.start();
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
        }
        
		public function completeHandler(event:Event):void {
		    lazyLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
		    
			dispatchEvent(new Event(Event.INIT));
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    var percentLoaded : Number = event.bytesLoaded/ event.bytesTotal;
			var current :Number = Math.floor(percentLoaded * 100) /100;
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}
			
		}
		
		

		
		override public function tearDown():void {
			lazyLoader.removeAll();	
			BulkLoader.removeAllLoaders();
            lazyLoader = null;
		}
        
        public function testXMLLoaded() : void{
            assertNotNull(lazyLoader);
        }
        
        public function testProgressNotNull() : void{
            assertTrue(lastProgress > 0.1)
        }
	}
}