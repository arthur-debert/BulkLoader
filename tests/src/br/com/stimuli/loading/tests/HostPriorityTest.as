package br.com.stimuli.loading.tests {
	import flash.net.URLRequest;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.display.*;
	import br.com.stimuli.kisstest.TestCase;
	import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;

public class HostPriorityTest 	extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var ioError : Event;
		
		public var completeFired : Boolean;
		public var progressFired : Boolean;
		
		// the order here should be the last to first, expected loading init!
		public var items : Array = [
			["http://d2.emptywhite.com/bulkloader-assets/small-10.jpg", {preventCache:true, priority:70}],
			["http://d2.emptywhite.com/bulkloader-assets/small-09.jpg", {preventCache:true, priority:92}],
			["http://d2.emptywhite.com/bulkloader-assets/small-08.jpg", {preventCache:true, priority:93}],
			["http://www.emptywhite.com/bulkloader-assets/small-07.jpg", {preventCache:true, priority:0}],
			["http://d1.emptywhite.com/bulkloader-assets/small-06.jpg", {preventCache:true, priority:10}],
			["http://d1.emptywhite.com/bulkloader-assets/small-05.jpg", {preventCache:true, priority:80}],
			["http://d3.emptywhite.com/bulkloader-assets/small-04.jpg", {preventCache:true, priority:90}],
			["http://d2.emptywhite.com/bulkloader-assets/small-03.jpg", {preventCache:true, priority:94}],
			["http://d2.emptywhite.com/bulkloader-assets/small-02.jpg", {preventCache:true, priority:95}],
			["http://d3.emptywhite.com/bulkloader-assets/small-01.jpg", {preventCache:true, priority:100}],
		];
		// 
		// d3, d2, d2, d3, d1,d1 www, d2, d2
		public var currentItemIndex : int = 0;
		public var timer : Timer;
		
		public function HostPriorityTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		timer = new Timer(200);
			timer.addEventListener(TimerEvent.TIMER, addNext, false, 0, true);
			timer.start();
		}

		public function addNext(evt : Event): void{
			var item : Array = items[currentItemIndex];
			if (item){
				_bulkLoader.add(item[0], item[1]);
				currentItemIndex++;
			}else{
				timer.reset();
				_bulkLoader.start();
			}
		}

        public function onIOError(evt : Event) : void{
            ioError = evt;
            // call the on complete manually 
            completeHandler(evt);
            tearDown();
        }
        
		public function completeHandler(event:Event):void {
		    completeFired = true;
		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);
			dispatchEvent(new Event(Event.INIT));
		}
		
		
		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		    progressFired = true;
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
		

		
		override public function tearDown():void {
		    _bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		public function testPriorityList():void {
			var loadingItems : Array = items.map(function(i:Array, ...rest):LoadingItem{
				return _bulkLoader.get(i[0]);
			});
			for (var i:int = 0; i < loadingItems.length -1; i++)
			{
				assertTrue(loadingItems[i].startTime >= loadingItems[i + 1].startTime);
				//trace(loadingItems[i]._parsedURL.path, loadingItems[i].startTime, loadingItems[i+1].startTime, loadingItems[i].startTime >= loadingItems[i + 1].startTime);//, loadingItems[i+1].url.url, loadingItems[i + 1].startTime);
			}
			loadingItems.sortOn("startTime");
			//trace(loadingItems.join("\n"));
		}
	
}

}

