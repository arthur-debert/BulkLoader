package br.com.stimuli.loading.tests {
	import br.com.stimuli.kisstest.TestCase;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.events.*;
	import flash.media.Sound;
    /**@private*/
	public class ErrorResumeTest extends TestCase { public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;
		public var sound : Sound;
		public var sound1 : Sound;
		public var itemsToTest : int = 6;
		public var ioError : Event;
		public var errorsFired : int = 0;
		public function ErrorResumeTest(name : String) : void {
		  super(name);
		  this.name  = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName(), 2 /*, BulkLoader.LOG_INFO*/);
            var startURL : String =  "http://www.emptywhite.com/bulkloader-assets/small-0";
            var item : LoadingItem;
            for (var i : int = 1 ; i < itemsToTest ; i ++){
                item = _bulkLoader.add(startURL + String(i) + ".jpg", {id:i});
                item.addEventListener(Event.COMPLETE, onItemLoaded, false, 0, true);
                if (i == 4){
                    // add a broken link to check if erros won't jam the loader
                    _bulkLoader.add(startURL + "sdsdsds0.jpg", {id:"baditem"});
                    _bulkLoader.add(startURL + "sdsdsds1.jpg", {id:"baditem2"});
                    _bulkLoader.add(startURL + "sdsdsds2.jpg", {id:"baditem3"});
                }
                
            }

        _bulkLoader.addEventListener(BulkLoader.ERROR, onIOError);
	 		_bulkLoader.start();
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
		}
        
        public function onIOError(evt : Event) : void{
            errorsFired ++;
            ioError = evt;
            // call the on complete manually
            //trace(_bulkLoader.itemsLoaded , errorsFired, _bulkLoader.itemsTotal);
            if (_bulkLoader.itemsLoaded + errorsFired >= _bulkLoader.itemsTotal -1){
               completeHandler(evt);
           } 
        } 
        
        public function onItemLoaded(evt : Event) : void{
            // check if errors + loaded items are complete:
            //trace(_bulkLoader.itemsLoaded , errorsFired, _bulkLoader.itemsTotal);
           if (_bulkLoader.itemsLoaded + errorsFired >= _bulkLoader.itemsTotal -1){
               completeHandler(evt);
           }
        }
        
		public function completeHandler(event:Event):void {
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    //var evt : * = event as Object;
			var current : Number = Math.floor((event as Object).percentLoaded * 100) /100;
			if (current > lastProgress){
			    lastProgress = current;
			    if (BulkLoaderTestSuite.LOADING_VERBOSE) trace(current * 100 , "% loaded") ;
			}
			for each(var propName : String in ["percentLoaded", "weightPercent", "ratioLoaded"] ){
			    if (isNaN(event[propName]) ){
			        trace(propName, "is not a number" );
			        assertFalse(isNaN(event[propName]));
			    }
			}
			//trace("event", (event as Object).percentLoaded, current);
		}

		
		
		override public function tearDown():void {
			// destroy the class under test instance
			_bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;
		}
		
		
		public function testAllItemsDoneLoaded() : void{
		    for (var i : int = 1 ; i < itemsToTest ; i ++){ 
		        assertNotNull(_bulkLoader.getBitmap(String(i)));
		    }
		    assertNull(_bulkLoader.get("baditem").content);
		}
		        
	}
}