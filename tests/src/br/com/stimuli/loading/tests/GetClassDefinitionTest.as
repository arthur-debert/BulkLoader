package br.com.stimuli.loading.tests {
	import br.com.stimuli.loading.*;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import br.com.stimuli.kisstest.TestCase;
/**@private*/
	public class GetClassDefinitionTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		public var theImageItem : ImageItem;
		public var content : *;
		public var contentIsBitmap : Boolean;
		
		
		//
		public var theCompleteEvent : Event;
		
		public function GetClassDefinitionTest(name: String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		_bulkLoader.start();
	 		var ctx : LoaderContext;
	 		if (name == "testSameContextClassDefinition"){
	 		    ctx =  new LoaderContext();
	 		    ctx.applicationDomain = ApplicationDomain.currentDomain;
	 		    trace("same contexts");
	 		    _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/CompiledClassTest.swf", {"context":ctx, "id": "compiled-swf"});
	 		}else{
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/CompiledClassTest.swf", {"id": "compiled-swf"});
	 		    trace("different contexts")
	 		}

	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandlerSpecialEvent);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandlerSpecialEvent();
           // tearDown();
        }
        
        public function onImageComplete(event : Event) : void{
            content = event.target.content;
            contentIsBitmap = event.target.content is Bitmap;
            theCompleteEvent = event;
        }
		protected function completeHandlerSpecialEvent(event:BulkProgressEvent=null):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandlerSpecialEvent);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
	 		var e : Event= new Event(Event.INIT);
			dispatchEvent(e);
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
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
		
		

		
		override public function tearDown():void {
		    _bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
//		public function testSameContextClassDefinition():void {
//		    trace("should be true", (_bulkLoader.get("compiled-swf") as ImageItem).loader.contentLoaderInfo.applicationDomain == ApplicationDomain.currentDomain);
//		    assertNotNull(_bulkLoader.getClassByName("CompiledClass"));
//		}
		
		public function testLoadinItemGetDefinition() : void{
		    assertNotNull((_bulkLoader.get("compiled-swf") as ImageItem).getDefinitionByName("CompiledClass"));
		}
        }
}