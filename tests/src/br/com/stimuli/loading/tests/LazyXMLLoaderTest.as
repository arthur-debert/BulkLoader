package br.com.stimuli.loading.tests {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.lazyloaders.*;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import br.com.stimuli.kisstest.TestCase;
/**@private*/
	public class LazyXMLLoaderTest extends TestCase { 
	    public var _bulkLoader : LazyXMLLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		public var numItemCompleteFires : int = 0;
		
		public function LazyXMLLoaderTest(name : String) : void {
		 // todo: test audio context,  loader context, events for entire loader, events for each item
		  super(name);
		  this.name = name;
		  com.adobe.serialization.json.JSON;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new LazyXMLLoader("http://www.emptywhite.com/bulkloader-assets/lazyloader.xml", BulkLoader.getUniqueName(), 2, 10);
            _bulkLoader.addEventListener(LazyBulkLoader.LAZY_COMPLETE, onLazyComplete);
            _bulkLoader.addEventListener("complete", completeHandler);
            _bulkLoader.addEventListener("progress", progressHandler);
            _bulkLoader.start();
		}

        public function onLazyComplete(evt : Event) : void{
            for each (var item : LoadingItem in _bulkLoader.items){
                item.addEventListener("complete", incrementEventCount);
            }
        }
        
        public function incrementEventCount(evt : Event) : void{
            numItemCompleteFires ++;
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
		    var percentLoaded : Number = event.bytesLoaded/ event.bytesTotal;
			var current :Number = Math.floor(percentLoaded * 100) /100;
			var o : Object = event as Object;
			//trace( o.percentLoaded, o.ratioLoaded, o.weightPercent);
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}	
		}
		

		
		override public function tearDown():void {
		    _bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
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
            assertEquals(header1.name, "header1");
            assertEquals(header1.value, "value1");
            var header2 : URLRequestHeader = headers[1];
            assertEquals(header2.name, "header2");
            assertEquals(header2.value, "value2");
        }
        
        public function testIndividualItemEventFire() : void{
            assertEquals(numItemCompleteFires, _bulkLoader.itemsTotal);
        }
	}
}