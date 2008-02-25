package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
    import br.com.stimuli.loading.lazyloaders.*;
/**@private*/
	public class LazyXMLLoaderTest extends AsynchronousTestCase {
		public var lazyLoader : LazyXMLLoader;
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public var ioError : Event;
		
		public function LazyXMLLoaderTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            lazyLoader = new LazyXMLLoader("http://www.emptywhite.com/bulkloader-assets/lazyloader.xml");
            lazyLoader.addEventListener("complete", onlazyLoaded);
            lazyLoader.addEventListener("progress", progressHandler);
            lazyLoader.start();
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
        }
        
        public function onlazyLoaded(event:Event) : void{
            trace("#### onlazyLoaded", onlazyLoaded);
            lazyLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
		    _bulkLoader = lazyLoader.bulkLoader;
		    _bulkLoader.start();
		    _bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
        }
        
		protected override function completeHandler(event:Event):void {
		    trace("#### onlazyLoaded", completeHandler);
			super.run();
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
		    var percentLoaded : Number = event.bytesLoaded/ event.bytesTotal;
			var current :Number = Math.floor(percentLoaded * 100) /100;
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}	
		}
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			_bulkLoader.removeAll();	
			BulkLoader.removeAllLoaders();
		}
        
        public function testName() : void{
            assertEquals(_bulkLoader.name, "lazyTest");
        }
        
        public function testLogLevel() : void{
            assertEquals(_bulkLoader.logLevel, 10);
        }
        
        public function testNumConnections() : void{
            assertEquals(_bulkLoader.numConnections, 5);
        }
        
        public function testImage() : void{
            var bitmap : Bitmap = _bulkLoader.getBitmap("cats");
            assertNotNull(_bulkLoader.get("http://www.emptywhite.com/bulkloader-assets/cats.jpg"));
        }
        
        public function testAutoID() : void{
            var bitmap : Bitmap = _bulkLoader.getBitmap("cats");
            assertNotNull(_bulkLoader.get("cats"));
        }
	}
}