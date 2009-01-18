package br.com.stimuli.loading.tests {
	import br.com.stimuli.kisstest.TestCase;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
/**@private*/
	public class TwoItemsWithTheSameURLTest extends TestCase { 
	    public var _bulkLoader : BulkLoader;
		public var lastProgress : Number = 0;

		
		
		
		
		public function TwoItemsWithTheSameURLTest(name : String) : void {
		  super(name);
		  this.name = name;
		}
		// Override the run method and begin the request for remote data
		public override function setUp():void {
            _bulkLoader = new BulkLoader(BulkLoader.getUniqueName())
            var goodURL : String = "http://www.emptywhite.com/bulkloader-assets/some-text.txt";
            
	 		_bulkLoader.add(goodURL, {id:"1", preventCache: true});
	 		_bulkLoader.add(goodURL, {id:"2", preventCache: true});
	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
	 		_bulkLoader.addEventListener(BulkLoader.ERROR, onError);
	 		_bulkLoader.start();
		}

        public function onError(evt : Event) : void{
            
            
        }
        
        public function onGoodURLLoaded(evt : Event): void{
                completeHandler(evt);
        }
		public function completeHandler(event:Event):void {
			//super.run();
			dispatchEvent(new Event(Event.INIT));
		}
		

		/** This also works as an assertion that event progress will never be NaN
		*/
		 public function progressHandler(event:ProgressEvent):void {
		}
		

		
		override public function tearDown():void {
		    _bulkLoader.clear();
			BulkLoader.removeAllLoaders();
            _bulkLoader = null;	
		}
		
		
        
        public function testItemsAreLoaded() : void{
            assertNotNull(_bulkLoader.getText("1"));
            assertNotNull(_bulkLoader.getText("2"));
        }
        
        public function testItemsAreNotTheSame() : void{
            var i1 : LoadingItem = _bulkLoader.get("1");
             var i2 : LoadingItem = _bulkLoader.get("2");
            assertFalse(_bulkLoader.get("1") == _bulkLoader.get("2")) ;
        }
        
	}
}