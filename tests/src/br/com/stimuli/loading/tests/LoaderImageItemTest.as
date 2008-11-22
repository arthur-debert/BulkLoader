package br.com.stimuli.loading.tests {
	import asunit.framework.*;
	
	import br.com.stimuli.loading.*;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
/**@private*/
	public class LoaderImageItemTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public var ioError : Event;
		
		public var theImageItem : ImageItem;
		public var content : *;
		public var contentIsBitmap : Boolean;
		
		
		//
		public var theCompleteEvent : Event;
		
		public function LoaderImageItemTest(name: String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/shoes.jpg";
            var badURL : String = "http://www.emptywhite.com/bulkloader-assets/bad-image.jpg"
            var theURL : String = goodURL;
            if (this.name == 'testIOError'){
                theURL = badURL;
            }
            theImageItem = _bulkLoader.add(theURL, {id:"photo"}) as ImageItem;
	 		
            _bulkLoader.get("photo").addEventListener(BulkLoader.ERROR, onIOError);
	 		_bulkLoader.get("photo").addEventListener(BulkLoader.COMPLETE, onImageComplete);
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandlerSpecialEvent);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandlerSpecialEvent();
            tearDown();
        }
        
        public function onImageComplete(event : Event) : void{
            content = event.target.content;
            contentIsBitmap = event.target.content is Bitmap;
            theCompleteEvent = event;
        }
		protected function completeHandlerSpecialEvent(event:BulkProgressEvent=null):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandlerSpecialEvent);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			super.run();
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current : Number= Math.floor((event as Object).percentLoaded * 100) /100;
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
		
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testContentAvailableOnIndividualEvent():void {
		    assertNotNull(content);
		    assertTrue(contentIsBitmap);
		}
		
		public function testBitmapContent():void {
		    var item : Bitmap = _bulkLoader.getBitmap("photo");
		    assertNotNull(item);
		}
		
        public function testImageDimensions() : void{
            var item : Bitmap = _bulkLoader.getBitmap("photo");
		    assertTrue(item.width > 0);
		    assertTrue(item.height > 0);
        }
        
        public function testGetBitmapData() : void{
            var item : BitmapData = _bulkLoader.getBitmapData("photo");
		    assertTrue(item.width > 0);
		    assertTrue(item.height > 0);
        }
        
        public function testDefaultGetType() : void{
            var item : * = _bulkLoader.getContent("photo");
		    assertTrue(item is Bitmap);
        }
        
        public function testClearMemoryRemovesItem(): void{
            var item : Bitmap = _bulkLoader.getBitmap("photo", true);
		    assertNotNull(item);
            // now try again
            item = _bulkLoader.getBitmap("photo");
            assertNull(item);
        }
        
        public function testGetHTTPStatusFromItem() :void{
            var item : * = _bulkLoader.get("photo");
            assertTrue(item.httpStatus  > -1 );
        }
        
        public function testGetHTTPStatusFromLoader() :void{
            assertTrue(_bulkLoader.getHttpStatus("photo")  > -1 );
        }
        
        public function testIOError() : void{
            assertNotNull(ioError);
        }
        
        public function testIsImage() : void{
            assertTrue(_bulkLoader.get("photo").isImage());
        }
        
        public function testIsSWF() : void{
            assertFalse(_bulkLoader.get("photo").isSWF());
        }
        
        public function testInexistentOptionParseError() : void{
            var theBadItem : LoadingItem = _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"beginAsPaused":true});
            assertTrue(theBadItem.propertyParsingErrors.length > 0);
        }
        
        public function testCorrectOptionsParse() : void{
            assertTrue(theImageItem.propertyParsingErrors.length == 0);
        }
        
        public function testOnCompleteFired() : void{
            assertNotNull(theCompleteEvent);
            
        }
	}
}