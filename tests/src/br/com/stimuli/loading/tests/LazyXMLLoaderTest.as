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
		 // todo: test audio context,  loader context, events for entire loader, events for each item
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
        
        public function testFLV() : void{
            var netStream : NetStream = _bulkLoader.getNetStream("movie");
            assertNotNull(netStream);
        }
        
        public function testFLVMetadata() : void{
            var meta : Object = _bulkLoader.getNetStreamMetaData("movie");
            assertNotNull(meta);
        }
        
        public function testFLVCheckPolicyFile() : void{
            var videoItem : VideoItem = _bulkLoader.get("movie") as VideoItem;
            assertTrue(videoItem.checkPolicyFile);
        }
        
        public function testMaxTries() : void{
            var videoItem : VideoItem = _bulkLoader.get("movie") as VideoItem;
            assertEquals(videoItem.maxTries, 5);
        }
        
        public function testPriority() : void{
            assertEquals(_bulkLoader.get("movie").priority, 100)
        }
        
        public function testWeight() : void{
            assertEquals(_bulkLoader.get("movie").weight, 4)
        }
        
        public function testPreventCache() : void{
            assertEquals(_bulkLoader.get("some-text").preventCache, true);
            assertEquals(_bulkLoader.get("movie").preventCache, false);
        }
        
        public function testText() : void{
            assertNotNull(_bulkLoader.getText("some-text"));
        }
        
        public function testSound() : void{
            assertNotNull(_bulkLoader.getSound("the-sound"));
        }
        
        public function testID() : void{
            assertNotNull(_bulkLoader.getSound("the-sound"));
        }
        
        public function testType() : void{
            var item : LoadingItem =  _bulkLoader.get("untyped-image")
            assertNotNull(item);
            assertTrue(item.content is Bitmap);
            assertTrue(item is ImageItem);
        }
        
        public function testXML() : void{
            var item : LoadingItem =  _bulkLoader.get("samplexml")
            assertNotNull(item);
        }
        
        public function testHeaders() : void{
            var item : LoadingItem =  _bulkLoader.get("samplexml")
            var headers : Array = item.url.requestHeaders;
            assertNotNull(headers);
            assertEquals(headers.length, 2 );
            var header1 : URLRequestHeader = headers[0];
            trace("{LazyXMLLoaderTest}::method() header1", header1);
            trace("{LazyXMLLoaderTest}::method() header1.name", header1.name);
            trace("{LazyXMLLoaderTest}::method() header1.value", header1.value);
            assertEquals(header1.name, "header1");
            assertEquals(header1.value, "value1");
            var header2 : URLRequestHeader = headers[1];
            assertEquals(header2.name, "header2");
            assertEquals(header2.value, "value2");
        }
	}
}