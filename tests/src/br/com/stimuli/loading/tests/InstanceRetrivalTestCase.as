
package br.com.stimuli.loading.tests {
	import kisstest.TestCase;
	  import br.com.stimuli.loading.BulkLoader;
    import br.com.stimuli.loading.loadingtypes.*;
    import flash.net.*;
    import flash.events.*;
    import flash.utils.*;
    
    /**@private*/
    	public class InstanceRetrivalTestCase extends TestCase{
    	    public var _bulkLoader:BulkLoader;
    		public var _bulkLoader2:BulkLoader;
            private var soundURL : URLRequest ;
            
            public var lastProgress : Number = 0;

    		
    		public var ioError : Event;
    		public var timer : Timer;
    		public var b1Name : String;
    		public var b2Name : String;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		 
     		public function InstanceRetrivalTestCase(testMethod:String) {
     			super(testMethod);
     			this.name = testMethod;
     		}


            public override function setUp():void {
                _bulkLoader = BulkLoader.createUniqueNamedLoader();
                b1Name = _bulkLoader.name;
    	 		soundURL = new URLRequest("http://www.emptywhite.com/bulkloader-assets/chopin.mp3");
    	 		_bulkLoader.add(soundURL, {id:"the-sound"});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
                _bulkLoader.start();
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/sound-short.mp3", {id:"the-sound"});
                _bulkLoader2 = BulkLoader.createUniqueNamedLoader()
                b2Name = _bulkLoader2.name;
                _bulkLoader2.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {id:"xml"});
    	 		_bulkLoader.addEventListener(BulkLoader.COMPLETE, completeHandler);
    	 		_bulkLoader.addEventListener(BulkLoader.PROGRESS, progressHandler);
    	 		_bulkLoader2.start();
    		}

            public function onIOError(evt : Event) : void{
                ioError = evt;
                // call the on complete manually 
                completeHandler(evt);
                tearDown();
            }

    		public function completeHandler(event:Event):void {
    		    _bulkLoader.removeEventListener(BulkLoader.COMPLETE, completeHandler);
    	 		_bulkLoader.removeEventListener(BulkLoader.PROGRESS, progressHandler);

    		    if (_bulkLoader2.isFinished){
    		        if (timer){
    		            timer.removeEventListener(TimerEvent.TIMER, completeHandler, false);
    		            timer.stop();
    		        }
    		        dispatchEvent(new Event(Event.INIT));
    		    }else if (!timer){
    		        timer = new Timer(200, 0);
    		        timer.addEventListener(TimerEvent.TIMER, completeHandler, false, 0, true);
    		        timer.start();
    		    }
    			
    		}


    		/** This also works as an assertion that event progress will never be NaN
    		*/
    		 public function progressHandler(event:ProgressEvent):void {
    		    //var evt : * = event as Object;
    			var current : Number = Math.floor((event as Object).percentLoaded * 100) /100;
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
    	 	


            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
            
            public function testOneInstanceWithSameName() : void{
                var error : Error;
                try{
                    var bl : BulkLoader  = new BulkLoader(b1Name);
                }catch (e : Error){
                    error = e;
                }
                //"Cannot create two instances with the same name",
                assertNotNull( error);
            }
            
            public function testCanAccessInstanceFromStaticRegister() : void {
                assertNotNull(BulkLoader.getLoader(b1Name));
            }
            
            public function testCannotCreateLoaderWithEmpryString() : void {
                var error : Error;
                try{
                    var bl : BulkLoader  = new BulkLoader("");
                }catch (e : Error){
                    error = e;
                }
                //"Cannot create BulkLoader with an empty string", 
                assertNotNull(error);
            }

            public function testCannotGetInstaceFromEmptyString() : void{
                assertNull(BulkLoader.getLoader(""));
            }
            
            public function testCannotGetInstaceFromNonExistantKey() : void{
                assertNull(BulkLoader.getLoader("bad-loader"));
            }
            
            public function testCreateManyUniqueNameInstances() : void{
                for (var i:int = 0; i<200; i++){
                    BulkLoader.createUniqueNamedLoader();
                }
            }
            
            public function testRemoveAllLoaders() : void{
                BulkLoader.removeAllLoaders();
                assertNull(BulkLoader.getLoader("b1Name"));
                assertNull(BulkLoader.getLoader("b2Name"));
            }
            
            public function testNotLoadedItems() : void{
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/some-text.text", {"priority":-200, id:"text"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/shoes.jpg", {"priority":-200, id:"photo"});
                _bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/samplexml.xml", {"priority":200, id:"xml"});
                var notLoaded: Array = _bulkLoader.getNotLoadedItems();
                assertEquals(notLoaded.length, 3);
                assertEquals(notLoaded[0], _bulkLoader.get("xml"));
                assertEquals(notLoaded[1], _bulkLoader.get("text"));
                assertEquals(notLoaded[2], _bulkLoader.get("photo"));
            }
            
            public function testWhichLoaderHasItem() : void{
                assertEquals(BulkLoader.whichLoaderHasItem("the-movie"), _bulkLoader);
                assertFalse(BulkLoader.whichLoaderHasItem("the-movie") == _bulkLoader2);
                assertEquals(BulkLoader.whichLoaderHasItem("xml"), _bulkLoader2);
            }
            
    	}
    
	
}
