package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.display.*;
	import asunit.framework.*;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
/**@private*/
	public class ReloadTest extends AsynchronousTestCase {
		public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		public var name : String;
		public var ioError : Event;
		
		public var firstLoaded : Boolean
		public var firstLoadedXML : XML;

		public function ReloadTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/samplexml.xml";
            
	 		_bulkLoader.add(goodURL, {id:"xml"});
            _bulkLoader.get("xml").addEventListener(BulkLoader.ERROR, onIOError);
	 		
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
        
		protected override function completeHandler(event:Event):void {
		    if (firstLoaded){
		        _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
    	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
    			super.run();
    			return;
		    }
            firstLoaded = true;
            firstLoadedXML = _bulkLoader.getXML("xml");
            _bulkLoader.reload("xml");
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		protected override function progressHandler(event:ProgressEvent):void {
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
		
		
		protected override function setUp():void {

		}
		
		protected override function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testReloadedContents():void {
		    
		    assertTrue(firstLoaded);
		    assertTrue(firstLoadedXML);
		    var secondXML : XML = _bulkLoader.getXML("xml");
		    assertEquals(firstLoadedXML.toString(), secondXML.toString());
		    assertFalse(firstLoadedXML === secondXML)
		    
		}
		
		public function testReloadKeepsItemCount() : void{
		    assertEquals(_bulkLoader.items.length, 1);
		}
	}
}