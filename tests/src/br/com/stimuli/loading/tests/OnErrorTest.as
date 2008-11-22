package br.com.stimuli.loading.tests {
	import kisstest.TestCase
	import br.com.stimuli.loading.BulkErrorEvent;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
/**@private*/
	public class OnErrorTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		public var errorEvent : BulkErrorEvent;
		
		
		public function OnErrorTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function run():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/some-text.txt";
            
	 		_bulkLoader.add(goodURL, {id:"200Item", preventCache: true});
	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/404file.xml", {id:"404Item",preventCache: true}).addEventListener(BulkLoader.COMPLETE, onGoodURLLoaded, false, 0, true);
	 		
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		_bulkLoader.addEventListener(BulkLoader.ERROR, onError);
	 		_bulkLoader.start();
		}

        public function onError(evt : Event) : void{
            errorEvent = evt as BulkErrorEvent;
            trace("event captured on test from onError");
            // call the on complete manually 
            if (_bulkLoader.itemsLoaded == 1){
                //completeHandler(evt);
                tearDown();
            }
            
        }
        
        public function onGoodURLLoaded(evt : Event): void{
            trace("on item loaded");
            if (errorEvent){
                //completeHandler(evt);
                tearDown();
            }
        }
		public function completeHandler(event:Event):void {
		    trace("COMPLETE RAN om test ", name);
			//super.run();
			dispatchEvent(new Event(Event.INIT));
		}
		

		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		}
		
		
		override public function setUp():void {

		}
		
		override public function tearDown():void {
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		
        
        public function testItemIsLoaded() : void{
            assertNotNull(_bulkLoader.get("404Item"))
        }
        
        
        public function testHasErrorDispatched() : void{
            assertNotNull(errorEvent);
            assertEquals(errorEvent.errors,_bulkLoader.get("200Item"));
        }
	}
}