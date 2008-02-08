package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

	public class LoaderImageItemTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public function LoaderImageItemTest(name) : void {
		  super(name);
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader("assync-test");
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {id:"photo"});
	 		
	 		
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

		protected override function completeHandler(event:Event):void {
			super.run();
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current = Math.floor((event as Object).percentLoaded * 100) /100;
			var delta : Number = current - lastProgress;
			if (current > lastProgress && delta > 0.099){
			    lastProgress = current;
			    trace(current * 100 , "% loaded") ;
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
			_bulkLoader.removeAll();	
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
	}
}