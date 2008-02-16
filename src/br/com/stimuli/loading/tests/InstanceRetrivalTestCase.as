
package br.com.stimuli.loading.tests {
	import asunit.framework.TestCase;
    import br.com.stimuli.loading.BulkLoader;
    import flash.net.*;
    	public class InstanceRetrivalTestCase extends TestCase {
    		private var _bulkLoader:BulkLoader;
    		private var _bulkLoader2:BulkLoader;
            private var soundURL : URLRequest ;
    		/**
     		 * Constructor
     		 *
     		 * @param testMethod Name of the method to test
     		 */
     		public function InstanceRetrivalTestCase(testMethod:String) {
     			super(testMethod);
     		}

    		/**
    	 	 * Prepare for test, create instance of class that we are testing.
    	 	 * Invoked by TestCase.runMethod function.
    	 	 */
    		protected override function setUp():void {
    	 		_bulkLoader = new BulkLoader("test-loader");
    	 		soundURL = new URLRequest("http://www.emptywhite.com/bulkloader-assets/chopin.mp3");
    	 		_bulkLoader.add(soundURL, {id:"the-sound"});
    	 		_bulkLoader.add("http://www.emptywhite.com/bulkloader-assets/movie.flv", {id:"the-movie", pausedAtStart:true});
                _bulkLoader.start();
                _bulkLoader2 = BulkLoader.createUniqueNamedLoader()
    	 		
    	 	}

    		/**
    	 	 * Clean up after test, delete instance of class that we were testing.
    	 	 */
    	 	protected override function tearDown():void {
    	 		_bulkLoader.removeAll();
    	 	}

            /* ===================================================== */
            /* = Actual testes                                     = */
            /* ===================================================== */
            
            
            
            public function testOneInstanceWithSameName() : void{
                var error : Error;
                try{
                    var bl : BulkLoader  = new BulkLoader("test-loader");
                }catch (e : Error){
                    error = e;
                }
                assertNotNull("Cannot create two instances with the same name", error);
            }
            
            public function testCanAccessInstanceFromStaticRegister() : void {
                assertNotNull(BulkLoader.getLoader("test-loader"));
            }
    		
    		public function testCannotCreateLoaderWithEmpryString() : void {
    		    var error : Error;
                try{
                    var bl : BulkLoader  = new BulkLoader("");
                }catch (e : Error){
                    error = e;
                }
                assertNotNull("Cannot create BulkLoader with an empty string", error);
    		}

            public function testCannotGetInstaceFromEmptyString() : void{
                assertNull(BulkLoader.getLoader(""));
            }
            
            public function testCannotGetInstaceFromNonExistantKey() : void{
                assertNull(BulkLoader.getLoader("bad-loader"));
            }
            
            public function createManyUniqueNameInstances() : void{
                for (var i:int = 0; i<200; i++){
                    BulkLoader.createUniqueNamedLoader();
                }
            }
    	}
    
	
}
