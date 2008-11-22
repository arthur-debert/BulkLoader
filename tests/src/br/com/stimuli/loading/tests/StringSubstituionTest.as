package br.com.stimuli.loading.tests {
	import kisstest.TestCase;
    import br.com.stimuli.loading.*;
    import br.com.stimuli.loading.loadingtypes.LoadingItem;
    import flash.net.*;
    import flash.events.*;
    /**@private*/
    	public class StringSubstituionTest extends TestCase {
    		 public var _bulkLoader:BulkLoader; 
            private var soundURL : URLRequest ;
            
            public var subs : Object;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function StringSubstituionTest(testMethod:String) {
     			super(testMethod);
     			name = testMethod;
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		override public function setUp():void {
    	 		_bulkLoader = new BulkLoader(BulkLoader.getUniqueName());
    	 		_bulkLoader.stringSubstitutions  = {
    	 		    base_path:"http://www.google.com/",
    	 		    service_path:"nuthouse",
    	 		    "stuf-with-bad-chars":"yacks"
    	 		}
    	 		dispatchEvent(new Event(Event.INIT));
    	 	}

    		/**
    	 	 * Clean up after test, delete instance of class that we were testing.
    	 	 */
    	 	override public function tearDown():void {
    	 	    _bulkLoader.clear();
                BulkLoader.removeAllLoaders();
            _bulkLoader = null;
    	 	}

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
            
    	 	public function testSimpleItem():void {
    	 	    // test stuff no no subs are ok 
    	 	    var item : LoadingItem = _bulkLoader.add("some-url.jpg");
    	 	    assertEquals(item.url.url, "some-url.jpg");
	 	    }
	 	    
            public function testSimpleAbsoluteItem():void {
                // test stuff no no subs are ok for absolute urls 
                 var item : LoadingItem = _bulkLoader.add("http://www.somesite.com/some-url.jpg");
                 assertEquals(item.url.url, "http://www.somesite.com/some-url.jpg");
             }
             
             public function testSubsWithNoBraces():void {
                 // test we are realling matching the braces
                  var item : LoadingItem = _bulkLoader.add("http://www.somesite.com/base_path");
                  assertEquals(item.url.url, "http://www.somesite.com/base_path");
              }
             
             public function testSubAtStart():void {
                 var item : LoadingItem = _bulkLoader.add("{base_path}some-url.jpg");
                 assertEquals(item.url.url, "http://www.google.com/some-url.jpg");
             }
             
             public function testSubLater() : void{
                 var item : LoadingItem = _bulkLoader.add("http://www.google.com/{service_path}/");
                  assertEquals(item.url.url, "http://www.google.com/nuthouse/");
             }
             
             public function testSubAtEnd() : void{
                 var item : LoadingItem = _bulkLoader.add("http://www.google.com/{service_path}");
                  assertEquals(item.url.url, "http://www.google.com/nuthouse");
             }
             
             public function testSubWithOneSpace() : void{
                 var item : LoadingItem = _bulkLoader.add("http://www.google.com/{ service_path}");
                  assertEquals(item.url.url, "http://www.google.com/nuthouse");
             }
             
             public function testSubWithOneSpaceAtEachEnd() : void{
                 var item : LoadingItem = _bulkLoader.add("http://www.google.com/{ service_path }");
                  assertEquals(item.url.url, "http://www.google.com/nuthouse");
             }
             
             public function testSubWithManySpaces() : void{
                  var item : LoadingItem = _bulkLoader.add("http://www.google.com/{   service_path   }");
                   assertEquals(item.url.url, "http://www.google.com/nuthouse");
              }
              
            public function testGluedSubs() : void{
               var item : LoadingItem = _bulkLoader.add("{base_path}{ service_path }");
                assertEquals(item.url.url, "http://www.google.com/nuthouse");
            }
               
             public function testGluedSubsWithCharBetween() : void{
                  var item : LoadingItem = _bulkLoader.add("{base_path}something-else/{ service_path }");
                   assertEquals(item.url.url, "http://www.google.com/something-else/nuthouse");
              }
              
              public function testMultipleCopies() : void{
                    var item : LoadingItem = _bulkLoader.add("{ service_path }{ service_path }/{ service_path }/");
                     assertEquals(item.url.url, "nuthousenuthouse/nuthouse/");
                }  
                
                public function testSubWithBadChars() : void{
                      var item : LoadingItem = _bulkLoader.add("{base_path}{stuff-with-bad-chars}/");
                       assertEquals(item.url.url, "http://www.google.com//");
                  }
    }
    
	
}
